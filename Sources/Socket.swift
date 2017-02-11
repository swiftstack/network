import Platform

@_exported import Async

open class Socket {
    private var backlog: Int32 = 256

    public var descriptor: Descriptor

    public private(set) var options: Options

    public var awaiter: IOAwaiter? {
        didSet {
            switch awaiter {
            case .some: descriptor.status |= O_NONBLOCK
            case .none: descriptor.status &= ~O_NONBLOCK
            }
        }
    }

    public init(descriptor: Int32, awaiter: IOAwaiter? = nil) {
        self.descriptor = descriptor
        self.options = Options(for: descriptor)
        self.awaiter = awaiter

    #if os(OSX)
        self.options.noSignalPipe = true
    #endif
    }

    public convenience init(awaiter: IOAwaiter? = nil) throws {
        let descriptor = socket(AF_INET, SOCK_STREAM, 0)
        guard descriptor > 0 else {
            throw SocketError()
        }
        self.init(descriptor: descriptor, awaiter: awaiter)
    }

    deinit {
        try? close(silent: true)
    }

    @discardableResult
    public func listen(at host: String, port: UInt16, reusePort: Bool = true) throws -> Socket {
        self.options.reuseAddr = true
        self.options.reusePort = reusePort

        var addr = sockaddr(sockaddr_in(host: host, port: port, family: AF_INET))
        guard Platform.bind(descriptor, &addr, sockaddr.size) != -1 else {
            throw SocketError()
        }
        guard Platform.listen(descriptor, backlog) != -1 else {
            throw SocketError()
        }
        return self
    }

    open func accept() throws -> Socket {
        var addr = sockaddr()
        var addrLen = sockaddr.size
        var client: Int32 = 0
        try awaiter?.wait(for: descriptor, event: .read)
        client = Platform.accept(descriptor, &addr, &addrLen)
        guard client != -1 else {
            throw SocketError()
        }
        return Socket(descriptor: client, awaiter: self.awaiter)
    }

    @discardableResult
    open func connect(to host: String, port: UInt16) throws -> Socket {
        var addr = sockaddr(sockaddr_in(host: host, port: port, family: AF_INET))
        guard Platform.connect(descriptor, &addr, sockaddr.size) != -1 else {
            throw SocketError()
        }
        return self
    }

    open func close(silent: Bool = false) throws {
        guard Platform.close(descriptor) != -1 || silent else {
            throw SocketError()
        }
    }

    open func read(to pointer: UnsafeMutablePointer<UInt8>, count: Int) throws -> Int {
        try awaiter?.wait(for: descriptor, event: .read)
        let read = Platform.read(descriptor, pointer, count)
        guard read != -1 else {
            throw SocketError()
        }
        return read
    }

    open func write(bytes pointer: UnsafePointer<UInt8>, count: Int) throws -> Int {
        try awaiter?.wait(for: descriptor, event: .write)
        let written = Platform.write(descriptor, pointer, count)
        guard written != -1 else {
            throw SocketError()
        }
        return written
    }
}

extension Socket {
    @inline(__always)
    public func read(to buffer: UnsafeMutableBufferPointer<UInt8>) throws -> Int {
        return try read(to: buffer.baseAddress!, count: buffer.count)
    }

    @inline(__always)
    public func write(bytes buffer: UnsafeBufferPointer<UInt8>) throws -> Int {
        return try write(bytes: buffer.baseAddress!, count: buffer.count)
    }
}

extension Socket {
    @inline(__always)
    public func read(to bytes: inout [UInt8]) throws -> Int {
        return try read(to: &bytes, count: bytes.count)
    }

    @inline(__always)
    public func write(bytes: [UInt8]) throws -> Int {
        return try write(bytes: bytes, count: bytes.count)
    }
}
