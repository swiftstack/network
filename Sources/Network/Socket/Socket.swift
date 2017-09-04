import Platform
import struct Foundation.Date

@_exported import Async

public final class Socket {
    public enum Family {
        case local, inet, inet6
    }

    public enum SocketType {
        case stream, datagram, sequenced, raw
    }

    private var backlog: Int32 = 256

    public private(set) var descriptor: Descriptor
    public internal(set) var options: Options
    public private(set) var family: Family
    public private(set) var type: SocketType

    public var noDelay: Bool {
        get {
            return descriptor.status & O_NONBLOCK != 0
        }
        set {
            switch newValue {
            case true: descriptor.status |= O_NONBLOCK
            case false: descriptor.status &= ~O_NONBLOCK
            }
        }
    }

    public init(
        descriptor: Int32? = nil,
        family: Family = .inet,
        type: SocketType = .stream
    ) throws {
        precondition(async != nil, "async system is not registered")
        let descriptor = descriptor ?? socket(family.rawValue, type.rawValue, 0)
        guard descriptor > 0 else {
            throw SocketError()
        }
        self.type = type
        self.family = family
        self.descriptor = descriptor
        self.options = Options(for: descriptor)
    #if os(macOS)
        self.options.noSignalPipe = true
    #endif
        self.options.reuseAddr = true
        self.noDelay = true
    }

    deinit {
        try? close()
    }

    @discardableResult
    public func bind(to address: Address) throws -> Self {
        var copy = address
        guard Platform.bind(
            descriptor, rebounded(&copy), address.size) != -1 else {
                throw SocketError()
        }
        return self
    }

    @discardableResult
    public func listen() throws -> Self {
        guard Platform.listen(descriptor, backlog) != -1 else {
            throw SocketError()
        }
        return self
    }

    public func accept(deadline: Date = Date.distantFuture) throws -> Socket {
        let client = try repeatWhileInterrupted {
            try async.wait(for: descriptor, event: .read, deadline: deadline)
            return Int(Platform.accept(descriptor, nil, nil))
        }
        return try Socket(descriptor: Int32(client), family: family, type: type)
    }

    @discardableResult
    public func connect(
        to address: Address,
        deadline: Date = Date.distantFuture
    ) throws -> Self {
        var copy = address
        do {
            _ = try repeatWhileInterrupted {
                return Int(Platform.connect(
                    descriptor, rebounded(&copy), address.size))
            }
        } catch let error as SocketError where error.number == EINPROGRESS {
            try async.wait(for: descriptor, event: .write, deadline: deadline)
        }
        return self
    }

    public func close() throws {
        _ = try repeatWhileInterrupted {
            return Int(Platform.close(descriptor))
        }
    }

    public func send(
        bytes: UnsafeRawPointer,
        count: Int,
        deadline: Date = Date.distantFuture
    ) throws -> Int {
        return try repeatWhileInterrupted {
            try async.wait(for: descriptor, event: .write, deadline: deadline)
            return Platform.send(descriptor, bytes, count, noSignal)
        }
    }

    public func receive(
        to buffer: UnsafeMutableRawPointer,
        count: Int,
        deadline: Date = Date.distantFuture
    ) throws -> Int {
        return try repeatWhileInterrupted {
            try async.wait(for: descriptor, event: .read, deadline: deadline)
            return Platform.recv(descriptor, buffer, count, 0)
        }
    }

    public func send(
        bytes: UnsafeRawPointer,
        count: Int,
        to address: Address,
        deadline: Date = Date.distantFuture
    ) throws -> Int {
        var copy = address
        return try repeatWhileInterrupted {
            try async.wait(for: descriptor, event: .write, deadline: deadline)
            return Platform.sendto(
                descriptor,
                bytes,
                count,
                noSignal,
                rebounded(&copy),
                address.size)
        }
    }

    public func receive(
        to buffer: UnsafeMutableRawPointer,
        count: Int,
        from address: inout Address?,
        deadline: Date = Date.distantFuture
    ) throws -> Int {
        var storage = sockaddr_storage()
        var size = sockaddr_storage.size
        let received = try repeatWhileInterrupted {
            try async.wait(for: descriptor, event: .read, deadline: deadline)
            return Platform.recvfrom(
                descriptor, buffer, count, 0, rebounded(&storage), &size)
        }
        address = Address(storage)
        return received
    }

    @inline(__always)
    func repeatWhileInterrupted(_ task: () throws -> Int) throws -> Int {
        var result = 0
        while true {
            result = try task()
            if result == -1 &&
                (errno == EAGAIN || errno == EWOULDBLOCK || errno == EINTR) {
                continue
            }
            break
        }
        guard result != -1 else {
            throw SocketError()
        }
        return result
    }
}
