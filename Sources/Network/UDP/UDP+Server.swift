import Log
import Platform

extension UDP {
    public actor Server {
        public let socket: UDP.Socket

        public nonisolated var address: String {
            return socket.selfAddress!.description
        }

        public typealias Address = Network.Socket.Address
        public typealias OnData = ([UInt8], Address) async -> Void
        public typealias OnError = (Swift.Error) async -> Void

        lazy var onData: OnData = handleData
        lazy var onError: OnError = handleError

        public init(host: String, port: Int) throws {
            self.socket = try UDP.Socket()
            try self.socket.bind(to: host, port: port)
        }

        public init(host: String, reusePort: Int) throws {
            try self.init(host: host, port: reusePort)
            socket.socket.reusePort = true
        }

        deinit {
            try? socket.close()
        }

        @discardableResult
        public func onData(_ handler: @escaping OnData) async -> Self {
            self.onData = handler
            return self
        }

        @discardableResult
        public func onError(_ handler: @escaping OnError) async -> Self {
            self.onError = handler
            return self
        }

        public func start() async throws {
            await startAsync()
        }

        func startAsync() async {
            while true {
                do {
                    let (bytes, from) = try await socket
                        .receive(maxLength: 16348)
                    await self.onData(bytes, from)
                } catch {
                    await onError(error)
                }
            }
        }

        func handleData (bytes: [UInt8], from: Network.Socket.Address) async {
            await Log.warning("unhandled client: \(from)")
        }

        func handleError (_ error: Swift.Error) async {
            await Log.error(String(describing: error))
        }
    }
}
