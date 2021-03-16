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

    public func receive(
        to buffer: inout [UInt8],
        deadline: Time = .distantFuture
    ) async throws -> Int {
        try await receive(
            to: &buffer,
            count: buffer.count,
            deadline: deadline)
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
