import Platform

public struct Socket: Sendable {
    public let descriptor: Descriptor

    public init(family: Family = .inet, type: Type = .stream) throws {
        let fd = socket(family.rawValue, type.rawValue, 0)
        guard let descriptor = Descriptor(rawValue: fd) else {
            throw Socket.Error.badDescriptor
        }
        try self.init(descriptor: descriptor)
    }

    private init(descriptor: Descriptor) throws {
        self.descriptor = descriptor
    #if os(macOS)
        self.noSignalPipe = true
    #endif
        self.reuseAddr = true
        self.isNonBlocking = true
    }

    @discardableResult
    public func bind(to address: Address) throws -> Self {
        var copy = address
        try positiveResult {
            Platform.bind(descriptor.rawValue, rebounded(&copy), address.size)
        }
        return self
    }

    @discardableResult
    public func listen(backlog: Int = 256) throws -> Self {
        try positiveResult {
            Platform.listen(descriptor.rawValue, Int32(backlog))
        }
        return self
    }

    public func accept() throws -> Socket {
        let client = try positiveResult {
            Platform.accept(descriptor.rawValue, nil, nil)
        }
        guard let descriptor = Descriptor(rawValue: client) else {
            throw Socket.Error.badDescriptor
        }
        return try Socket(descriptor: descriptor)
    }

    @discardableResult
    public func connect(to address: Address) throws -> Self {
        var copy = address
        try positiveResult {
            Platform.connect(descriptor.rawValue, rebounded(&copy), copy.size)
        }
        return self
    }

    public func close() throws {
        try positiveResult {
            Platform.close(descriptor.rawValue)
        }
    }

    public func send(bytes: UnsafeRawPointer, count: Int) throws -> Int {
        try positiveResult {
            Platform.send(descriptor.rawValue, bytes, count, noSignal)
        }
    }

    public func receive(
        to buffer: UnsafeMutableRawPointer,
        count: Int
    ) throws -> Int {
        try positiveResult {
            Platform.recv(descriptor.rawValue, buffer, count, 0)
        }
    }

    public func send(
        bytes: UnsafeRawPointer,
        count: Int,
        to address: Address
    ) throws -> Int {
        var copy = address
        return try positiveResult {
            Platform.sendto(
                descriptor.rawValue,
                bytes,
                count,
                noSignal,
                rebounded(&copy),
                copy.size)
        }
    }

    public func receive(
        to buffer: UnsafeMutableRawPointer,
        count: Int
    ) throws -> (count: Int, from: Network.Socket.Address) {
        var storage = sockaddr_storage()
        var size = sockaddr_storage.size
        let received = try positiveResult {
            Platform.recvfrom(
                descriptor.rawValue,
                buffer,
                count,
                0,
                rebounded(&storage),
                &size)
        }
        guard let address = Address(storage) else {
            throw Error.invalidArgument
        }
        return (received, address)
    }

    @inline(__always)
    @discardableResult
    private func positiveResult<Result: SignedInteger>(
        _ task: () -> Result
    ) throws -> Result {
        let result = task()
        guard result != -1 else {
            throw Socket.Error()
        }
        return result
    }
}
