extension Socket {
    @discardableResult
    public func bind(to address: String, port: Int) throws -> Self {
        try bind(to: try Address(address, port: port))
    }

    @discardableResult
    public func bind(to address: String) throws -> Self {
        try bind(to: try Address(unix: address))
    }

    @discardableResult
    public func connect(to address: String, port: Int) throws -> Self {
        try connect(to: try Address(address, port: port))
    }

    @discardableResult
    public func connect(to address: String) throws -> Self {
        try connect(to: try Address(address))
    }
}

extension Socket {
    public func send(bytes: UnsafeRawBufferPointer) throws -> Int {
        try send(bytes: bytes.baseAddress!, count: bytes.count)
    }

    public func send(
        bytes: UnsafeRawBufferPointer,
        to address: Address
    ) throws -> Int {
        try send(bytes: bytes.baseAddress!, count: bytes.count, to: address)
    }

    public func send(bytes: [UInt8]) throws -> Int {
        try send(bytes: bytes, count: bytes.count)
    }

    public func send(bytes: [UInt8], to address: Address) throws -> Int {
        try send(bytes: bytes, count: bytes.count, to: address)
    }

    public func receive(to buffer: inout [UInt8]) throws -> Int {
        try receive(to: &buffer, count: buffer.count)
    }

    public func receive(
        to buffer: inout [UInt8]
    ) throws -> (count: Int, from: Network.Socket.Address) {
        try receive(to: &buffer, count: buffer.count)
    }

    public func receive(
        to buffer: UnsafeMutableRawBufferPointer
    ) throws -> Int {
        try receive(to: buffer.baseAddress!, count: buffer.count)
    }

    public func receive(
        to buffer: UnsafeMutableRawBufferPointer
    ) throws -> (count: Int, from: Network.Socket.Address) {
        try receive(to: buffer.baseAddress!, count: buffer.count)
    }
}
