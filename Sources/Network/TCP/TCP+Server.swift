import Log
import Platform

extension TCP {
    public actor Server {
        public let socket: TCP.Socket

        public nonisolated var address: String {
            return socket.selfAddress!.description
        }

        public typealias OnClient = (TCP.Socket) async -> Void
        public typealias OnError = (Swift.Error) async -> Void

        lazy var onClient: OnClient = handleClient
        lazy var onError: OnError = handleError

        public init(host: String, port: Int) throws {
            let socket = try TCP.Socket()
            try socket.bind(to: host, port: port)
            self.socket = socket
        }

        public init(host: String, reusePort: Int) throws {
            try self.init(host: host, port: reusePort)
            socket.socket.reusePort = true
        }

        deinit {
            try? socket.close()
        }

        @discardableResult
        public func onClient(_ handler: @escaping OnClient) async -> Self {
            self.onClient = handler
            return self
        }

        @discardableResult
        public func onError(_ handler: @escaping OnError) async -> Self {
            self.onError = handler
            return self
        }

        public func start() async throws {
            try socket.listen()
            await startAsync()
        }

        func startAsync() async {
            while true {
                do {
                    let client = try await socket.accept()
                    await self.onClient(client)
                } catch {
                    await onError(error)
                }
            }
        }

        func handleClient (_ socket: Socket) async {
            try? socket.close()
            await Log.warning("unhandled client")
        }

        func handleError (_ error: Swift.Error) async {
            switch error {
            /* connection reset by peer */
            /* do nothing, it's fine. */
            case let error as Network.Socket.Error
            where error == .connectionReset: break
            /* log other errors */
            default: await Log.error(String(describing: error))
            }
        }
    }
}
