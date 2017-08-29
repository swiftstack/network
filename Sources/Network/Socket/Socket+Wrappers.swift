import Foundation

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
    public func connect(
        to address: String,
        port: UInt16,
        deadline: Date = Date.distantFuture
    ) throws -> Self {
        return try connect(
            to: try Address(address, port: port),
            deadline: deadline)
    }

    @discardableResult
    public func connect(
        to address: String,
        deadline: Date = Date.distantFuture
    ) throws -> Self {
        return try connect(
            to: try Address(address),
            deadline: deadline)
    }
}

extension Socket {
    public func send(
        bytes: [UInt8],
        deadline: Date = Date.distantFuture
    ) throws -> Int {
        return try send(
            buffer: bytes,
            count: bytes.count,
            deadline: deadline)
    }

    public func send(
        bytes: [UInt8],
        to address: Address,
        deadline: Date = Date.distantFuture
    ) throws -> Int {
        return try send(
            buffer: bytes,
            count: bytes.count,
            to: address,
            deadline: deadline)
    }

    public func receive(
        to bytes: inout [UInt8],
        deadline: Date = Date.distantFuture
    ) throws -> Int {
        return try receive(
            buffer: &bytes,
            count: bytes.count,
            deadline: deadline)
    }

    public func receive(
        to bytes: inout [UInt8],
        from address: inout Address?,
        deadline: Date = Date.distantFuture
    ) throws -> Int {
        return try receive(
            buffer: &bytes,
            count: bytes.count,
            from: &address,
            deadline: deadline)
    }
}
