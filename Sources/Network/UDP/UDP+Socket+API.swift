import Time

extension UDP.Socket {
    @discardableResult
    public func bind(to address: String, port: Int) throws -> Self {
        try bind(to: try Network.Socket.Address(address, port: port))
    }

    @discardableResult
    public func bind(to address: String) throws -> Self {
        try bind(to: try Network.Socket.Address(unix: address))
    }
}

extension UDP.Socket {
    public func send(
        bytes: UnsafeRawBufferPointer,
        to address: Network.Socket.Address,
        deadline: Time = .distantFuture
    ) async throws -> Int {
        try await send(
            bytes: bytes.baseAddress!,
            count: bytes.count,
            to: address,
            deadline: deadline)
    }

    public func send(
        bytes: [UInt8],
        to address: Network.Socket.Address,
        deadline: Time = .distantFuture
    ) async throws -> Int {
        try await send(
            bytes: bytes,
            count: bytes.count,
            to: address,
            deadline: deadline)
    }

    // FIXME: [Concurrency]
    // compiler crash with -> (bytes: [UInt8], from: Address) tuple
    public func receive(
        maxLength: Int,
        deadline: Time = .distantFuture
    ) async throws -> Result<[UInt8]> {
        let buffer = UnsafeMutableRawBufferPointer.allocate(
            byteCount: maxLength,
            alignment: MemoryLayout<UInt>.alignment)
        defer { buffer.deallocate() }
        let result = try await receive(to: buffer, deadline: deadline)
        return .init(data: [UInt8](buffer[..<result.data]), from: result.from)
    }

    // FIXME: [Concurrency]
    // compiler crash with -> (count: Int, from: Address) tuple
    public func receive(
        to buffer: UnsafeMutableRawBufferPointer,
        deadline: Time = .distantFuture
    ) async throws -> Result<Int> {
        try await receive(
            to: buffer.baseAddress!,
            count: buffer.count,
            deadline: deadline)
    }
}
