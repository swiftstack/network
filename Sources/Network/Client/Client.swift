public class Client {
    public let host: String
    public let port: Int

    public private(set) var socket: Socket?

    public var isConnected: Bool {
        return socket != nil
    }

    public init(host: String, port: Int) {
        self.host = host
        self.port = port
    }

    public func connect() throws -> Socket {
        if let socket = self.socket {
            return socket
        }
        let socket = try Socket()
        try socket.connect(to: host, port: port)
        self.socket = socket
        return socket
    }

    public func disconnect() throws {
        if let socket = self.socket {
            self.socket = nil
            try socket.close()
        }
    }
}
