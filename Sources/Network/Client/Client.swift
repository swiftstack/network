import Stream

public class Client {
    public let host: String
    public let port: Int

    public var bufferSize = 4096

    public private(set) var socket: Socket?

    public var isConnected: Bool {
        return socket != nil
    }

    public init(host: String, port: Int) {
        self.host = host
        self.port = port
    }

    public enum Error: Swift.Error {
        case alreadyConnected
    }

    public func connect() throws -> BufferedStream<NetworkStream> {
        guard !isConnected else {
            throw Error.alreadyConnected
        }

        let socket = try Socket()
        try socket.connect(to: host, port: port)
        self.socket = socket
        return BufferedStream(baseStream: NetworkStream(socket: socket))
    }

    public func disconnect() throws {
        if let socket = self.socket {
            try socket.close()
            self.socket = nil
        }
    }
}
