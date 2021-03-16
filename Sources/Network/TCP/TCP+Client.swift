import Stream

extension TCP {
    public class Client {
        public let host: String
        public let port: Int

        var stream: Stream?

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

        @discardableResult
        public func connect() async throws -> Stream {
            guard !isConnected else {
                throw Error.alreadyConnected
            }
            let socket = try TCP.Socket()
            try await socket.connect(to: host, port: port)
            let stream = Stream(socket: socket)
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
}
