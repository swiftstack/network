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
        deadline: Instant? = nil
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
        deadline: Instant? = nil
    ) async throws -> Int {
        try await send(
            bytes: bytes,
            count: bytes.count,
            to: address,
            deadline: deadline)
    }

    public func receive(
        maxLength: Int,
        deadline: Instant? = nil
    ) async throws -> (bytes: [UInt8], from: Network.Socket.Address) {
        let buffer = UnsafeMutableRawBufferPointer.allocate(
            byteCount: maxLength,
            alignment: MemoryLayout<UInt>.alignment)
        defer { buffer.deallocate() }
        let result = try await receive(to: buffer, deadline: deadline)
        return (bytes: [UInt8](buffer[..<result.count]), from: result.from)
    }

    public func receive(
        to buffer: UnsafeMutableRawBufferPointer,
        deadline: Instant? = nil
    ) async throws -> (count: Int, from: Network.Socket.Address) {
        try await receive(
            to: buffer.baseAddress!,
            count: buffer.count,
            deadline: deadline)
    }
}
