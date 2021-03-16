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

    public func receive(
        to buffer: inout [UInt8],
        deadline: Time = .distantFuture
    ) async throws -> (count: Int, from: Network.Socket.Address?) {
        try await receive(
            to: &buffer,
            count: buffer.count,
            deadline: deadline)
    }

    public func receive(
        to buffer: UnsafeMutableRawBufferPointer,
        deadline: Time = .distantFuture
    ) async throws -> (count: Int, from: Network.Socket.Address?) {
        try await receive(
            to: buffer.baseAddress!,
            count: buffer.count,
            deadline: deadline)
    }
}
