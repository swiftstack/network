import Stream

public class Client {
    public let host: String
    public let port: Int

    public private(set) var stream: NetworkStream?

    public var isConnected: Bool {
        return stream != nil
    }

    public init(host: String, port: Int) {
        self.host = host
        self.port = port
    }

    public enum Error: Swift.Error {
        case alreadyConnected
    }

    public func connect() async throws -> NetworkStream {
        guard !isConnected else {
            throw Error.alreadyConnected
        }
        let socket = try Socket()
        try await socket.connect(to: host, port: port)
        let stream = NetworkStream(socket: socket)
        self.stream = stream
        return stream
    }

    public func disconnect() throws {
        if let stream = self.stream {
            try stream.socket.close()
            self.stream = nil
        }
    }
}
