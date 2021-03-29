import Time

extension TCP.Socket {
    @discardableResult
    public func bind(to address: String, port: Int) throws -> Self {
        try bind(to: try Network.Socket.Address(address, port: port))
    }

    @discardableResult
    public func bind(to address: String) throws -> Self {
        try bind(to: try Network.Socket.Address(unix: address))
    }

    @discardableResult
    public func connect(
        to address: String,
        port: Int,
        deadline: Time = .distantFuture
    ) async throws -> Self {
        try await connect(
            to: try Network.Socket.Address(address, port: port),
            deadline: deadline)
    }

    @discardableResult
    public func connect(
        to address: String,
        deadline: Time = .distantFuture
    ) async throws -> Self {
        try await connect(
            to: try Network.Socket.Address(address),
            deadline: deadline)
    }
}

extension TCP.Socket {
    public func send(
        bytes: UnsafeRawBufferPointer,
        deadline: Time = .distantFuture
    ) async throws -> Int {
        try await send(
            bytes: bytes.baseAddress!,
            count: bytes.count,
            deadline: deadline)
    }

    public func send(
        bytes: [UInt8],
        deadline: Time = .distantFuture
    ) async throws -> Int {
        try await send(
            bytes: bytes,
            count: bytes.count,
            deadline: deadline)
    }

    // FIXME: [Concurrency]
    public func receive(
        maxLength: Int,
        deadline: Time = .distantFuture
    ) async throws -> [UInt8] {
        let buffer = UnsafeMutableRawBufferPointer.allocate(
            byteCount: maxLength,
            alignment: MemoryLayout<UInt>.alignment)
        defer { buffer.deallocate() }
        let count = try await receive(to: buffer, deadline: deadline)
        return [UInt8](buffer[..<count])
    }

    public func receive(
        to buffer: UnsafeMutableRawBufferPointer,
        deadline: Time = .distantFuture
    ) async throws -> Int {
        try await receive(
            to: buffer.baseAddress!,
            count: buffer.count,
            deadline: deadline)
    }
}
