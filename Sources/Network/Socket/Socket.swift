import Time
import Platform

@_exported import Async

public final class Socket {
    public enum Family {
        case local, inet, inet6
    }

    public enum `Type` {
        case stream, datagram, sequenced, raw
    }

    public enum Option {
        case reuseAddr, reusePort, broadcast
        #if os(macOS)
        case noSignalPipe
        #endif
    }

    private var backlog: Int32 = 256

    public private(set) var descriptor: Descriptor
    public internal(set) var options: Options
    public private(set) var family: Family
    public private(set) var type: Type

    public var nonBlock: Bool {
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

    public convenience init(
        family: Family = .inet,
        type: Type = .stream
    ) throws {
        let fd = socket(family.rawValue, type.rawValue, 0)
        guard let descriptor = Descriptor(rawValue: fd) else {
            throw SocketError()
        }
        try self.init(descriptor: descriptor, family: family, type: type)
    }

    private init(
        descriptor: Descriptor,
        family: Family = .inet,
        type: Type = .stream
    ) throws {
        self.type = type
        self.family = family
        self.descriptor = descriptor
        self.options = Options(for: descriptor)
    #if os(macOS)
        try options.set(.noSignalPipe, true)
    #endif
        try options.set(.reuseAddr, true)
        self.nonBlock = true
    }

    deinit {
        try? close()
    }

    @discardableResult
    public func bind(to address: Address) throws -> Self {
        var copy = address
        guard Platform.bind(
            descriptor.rawValue, rebounded(&copy), address.size) != -1 else {
                throw SocketError()
        }
        return self
    }

    @discardableResult
    public func listen() throws -> Self {
        guard Platform.listen(descriptor.rawValue, backlog) != -1 else {
            throw SocketError()
        }
        return self
    }

    public func accept(deadline: Time = .distantFuture) throws -> Socket {
        let client = try repeatWhileInterrupted {
            try async.wait(for: descriptor, event: .read, deadline: deadline)
            return Int(Platform.accept(descriptor.rawValue, nil, nil))
        }
        guard let descriptor = Descriptor(rawValue: Int32(client)) else {
            throw SocketError()
        }
        return try Socket(descriptor: descriptor, family: family, type: type)
    }

    @discardableResult
    public func connect(
        to address: Address,
        deadline: Time = .distantFuture
    ) throws -> Self {
        var copy = address
        do {
            _ = try repeatWhileInterrupted {
                return Int(Platform.connect(
                    descriptor.rawValue, rebounded(&copy), address.size))
            }
        } catch let error as SocketError where error.number == EINPROGRESS {
            try async.wait(for: descriptor, event: .write, deadline: deadline)
        }
        return self
    }

    public func close() throws {
        _ = try repeatWhileInterrupted {
            return Int(Platform.close(descriptor.rawValue))
        }
    }

    public func send(
        bytes: UnsafeRawPointer,
        count: Int,
        deadline: Time = .distantFuture
    ) throws -> Int {
        return try repeatWhileInterrupted {
            try async.wait(for: descriptor, event: .write, deadline: deadline)
            return Platform.send(descriptor.rawValue, bytes, count, noSignal)
        }
    }

    public func receive(
        to buffer: UnsafeMutableRawPointer,
        count: Int,
        deadline: Time = .distantFuture
    ) throws -> Int {
        return try repeatWhileInterrupted {
            try async.wait(for: descriptor, event: .read, deadline: deadline)
            return Platform.recv(descriptor.rawValue, buffer, count, 0)
        }
    }

    public func send(
        bytes: UnsafeRawPointer,
        count: Int,
        to address: Address,
        deadline: Time = .distantFuture
    ) throws -> Int {
        var copy = address
        return try repeatWhileInterrupted {
            try async.wait(for: descriptor, event: .write, deadline: deadline)
            return Platform.sendto(
                descriptor.rawValue,
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
        deadline: Time = .distantFuture
    ) throws -> Int {
        var storage = sockaddr_storage()
        var size = sockaddr_storage.size
        let received = try repeatWhileInterrupted {
            try async.wait(for: descriptor, event: .read, deadline: deadline)
            return Platform.recvfrom(
                descriptor.rawValue,
                buffer,
                count,
                0,
                rebounded(&storage),
                &size)
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
