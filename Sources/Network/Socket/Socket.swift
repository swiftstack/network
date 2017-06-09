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

    public var awaiter: IOAwaiter? {
        didSet {
            switch awaiter {
            case .some: noDelay = true
            case .none: noDelay = false
            }
        }
    }

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

    public init(descriptor: Int32? = nil, family: Family = .inet, type: SocketType = .stream, awaiter: IOAwaiter? = nil) throws {
        let descriptor = descriptor ?? socket(family.rawValue, type.rawValue, 0)
        guard descriptor > 0 else {
            throw SocketError()
        }
        self.type = type
        self.family = family
        self.descriptor = descriptor
        self.options = Options(for: descriptor)
    #if os(OSX)
        self.options.noSignalPipe = true
    #endif
        self.options.reuseAddr = true

        if awaiter != nil {
            self.awaiter = awaiter
            self.noDelay = true
        }
    }

    deinit {
        try? close(silent: true)
    }

    @discardableResult
    public func bind(to address: Address) throws -> Self {
        var copy = address
        guard Platform.bind(descriptor, rebounded(&copy), address.size) != -1 else {
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
            try awaiter?.wait(for: descriptor, event: .read, deadline: deadline)
            return Int(Platform.accept(descriptor, nil, nil))
        }
        return try Socket(descriptor: Int32(client), family: family, type: type, awaiter: awaiter)
    }

    @discardableResult
    public func connect(to address: Address, deadline: Date = Date.distantFuture) throws -> Self {
        var copy = address
        do {
            _ = try repeatWhileInterrupted {
                return Int(Platform.connect(descriptor, rebounded(&copy), address.size))
            }
        } catch let error as SocketError where error.number == EINPROGRESS {
            try awaiter?.wait(for: descriptor, event: .write, deadline: deadline)
        }
        return self
    }

    public func close(silent: Bool = false) throws {
        _ = try repeatWhileInterrupted {
            return Int(Platform.close(descriptor))
        }
    }

    public func send(buffer: UnsafeRawPointer, count: Int, deadline: Date = Date.distantFuture) throws -> Int {
        return try repeatWhileInterrupted {
            try awaiter?.wait(for: descriptor, event: .write, deadline: deadline)
            return Platform.send(descriptor, buffer, count, noSignal)
        }
    }

    public func receive(buffer: UnsafeMutableRawPointer, count: Int, deadline: Date = Date.distantFuture) throws -> Int {
        return try repeatWhileInterrupted {
            try awaiter?.wait(for: descriptor, event: .read, deadline: deadline)
            return Platform.recv(descriptor, buffer, count, 0)
        }
    }

    public func send(buffer: UnsafeRawPointer, count: Int, to address: Address, deadline: Date = Date.distantFuture) throws -> Int {
        var copy = address
        return try repeatWhileInterrupted {
            try awaiter?.wait(for: descriptor, event: .write, deadline: deadline)
            return Platform.sendto(descriptor, buffer, count, noSignal, rebounded(&copy), address.size)
        }
    }

    public func receive(buffer: UnsafeMutableRawPointer, count: Int, from address: inout Address?, deadline: Date = Date.distantFuture) throws -> Int {
        var storage = sockaddr_storage()
        var size = sockaddr_storage.size
        let received = try repeatWhileInterrupted {
            try awaiter?.wait(for: descriptor, event: .read, deadline: deadline)
            return Platform.recvfrom(descriptor, buffer, count, 0, rebounded(&storage), &size)
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

extension Socket {
    @discardableResult
    public func bind(to address: String, port: UInt16) throws -> Self {
        return try bind(to: try Address(address, port: port))
    }

    @discardableResult
    public func bind(to address: String) throws -> Self {
        return try bind(to: try Address(unix: address))
    }

    @discardableResult
    public func connect(to address: String, port: UInt16, deadline: Date = Date.distantFuture) throws -> Self {
        return try connect(to: try Address(address, port: port), deadline: deadline)
    }

    @discardableResult
    public func connect(to address: String, deadline: Date = Date.distantFuture) throws -> Self {
        return try connect(to: try Address(address), deadline: deadline)
    }
}

extension Socket {
    public func send(bytes: [UInt8], deadline: Date = Date.distantFuture) throws -> Int {
        return try send(buffer: bytes, count: bytes.count, deadline: deadline)
    }

    public func send(bytes: [UInt8], to address: Address, deadline: Date = Date.distantFuture) throws -> Int {
        return try send(buffer: bytes, count: bytes.count, to: address, deadline: deadline)
    }

    public func receive(to bytes: inout [UInt8], deadline: Date = Date.distantFuture) throws -> Int {
        return try receive(buffer: &bytes, count: bytes.count, deadline: deadline)
    }

    public func receive(to bytes: inout [UInt8], from address: inout Address?, deadline: Date = Date.distantFuture) throws -> Int {
        return try receive(buffer: &bytes, count: bytes.count, from: &address, deadline: deadline)
    }
}
