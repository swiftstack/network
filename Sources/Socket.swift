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
        self.awaiter = awaiter
        self.descriptor = descriptor
        self.options = Options(for: descriptor)
    #if os(OSX)
        self.options.noSignalPipe = true
    #endif
        self.options.reuseAddr = true
    }

    deinit {
        try? close(silent: true)
    }

    @discardableResult
    public func bind(to address: Address) throws -> Socket {
        var copy = address
        guard Platform.bind(descriptor, rebounded(&copy), address.size) != -1 else {
            throw SocketError()
        }
        return self
    }

    @discardableResult
    public func listen() throws -> Socket {
        guard Platform.listen(descriptor, backlog) != -1 else {
            throw SocketError()
        }
        return self
    }

    public func accept(deadline: Date = Date.distantFuture) throws -> Socket {
        try awaiter?.wait(for: descriptor, event: .read, deadline: deadline)
        let client = Platform.accept(descriptor, nil, nil)
        guard client != -1 else {
            throw SocketError()
        }
        return try Socket(descriptor: client, family: family, type: type, awaiter: awaiter)
    }

    @discardableResult
    public func connect(to address: Address, deadline: Date = Date.distantFuture) throws -> Socket {
        var copy = address
        guard Platform.connect(descriptor, rebounded(&copy), address.size) != -1 else {
            throw SocketError()
        }
        return self
    }

    public func close(silent: Bool = false) throws {
        guard Platform.close(descriptor) != -1 || silent else {
            throw SocketError()
        }
    }

    public func send(buffer: UnsafeRawPointer, count: Int, deadline: Date = Date.distantFuture) throws -> Int {
        try awaiter?.wait(for: descriptor, event: .write, deadline: deadline)
        let sended = Platform.send(descriptor, buffer, count, noSignal)
        guard sended != -1 else {
            throw SocketError()
        }
        return sended
    }

    public func receive(buffer: UnsafeMutableRawPointer, count: Int, deadline: Date = Date.distantFuture) throws -> Int {
        try awaiter?.wait(for: descriptor, event: .read, deadline: deadline)
        let received = Platform.recv(descriptor, buffer, count, 0)
        guard received != -1 else {
            throw SocketError()
        }
        return received
    }

    public func send(buffer: UnsafeRawPointer, count: Int, to address: Address, deadline: Date = Date.distantFuture) throws -> Int {
        var copy = address
        try awaiter?.wait(for: descriptor, event: .write, deadline: deadline)
        let sended = Platform.sendto(descriptor, buffer, count, noSignal, rebounded(&copy), address.size)
        guard sended != -1 else {
            throw SocketError()
        }
        return sended
    }

    public func receive(buffer: UnsafeMutableRawPointer, count: Int, from address: inout Address?, deadline: Date = Date.distantFuture) throws -> Int {
        var storage = sockaddr_storage()
        var size = sockaddr_storage.size
        try awaiter?.wait(for: descriptor, event: .read, deadline: deadline)
        let received = Platform.recvfrom(descriptor, buffer, count, 0, rebounded(&storage), &size)
        guard received != -1 else {
            throw SocketError()
        }
        address = Address(storage, size)
        return received
    }
}

extension Socket {
    @discardableResult
    public func bind(to address: String, port: UInt16) throws -> Socket {
        return try bind(to: try Address(address, port: port))
    }

    @discardableResult
    public func bind(to address: String) throws -> Socket {
        return try bind(to: try Address(unix: address))
    }

    @discardableResult
    public func connect(to address: String, port: UInt16, deadline: Date = Date.distantFuture) throws -> Socket {
        return try connect(to: try Address(address, port: port), deadline: deadline)
    }

    @discardableResult
    public func connect(to address: String, deadline: Date = Date.distantFuture) throws -> Socket {
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
