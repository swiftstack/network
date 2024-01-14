import Log
import Platform

extension TCP {
    public actor Server {
        public let socket: TCP.Socket

        public nonisolated var address: String {
            return socket.selfAddress!.description
        }

        public typealias OnClientHandler = (TCP.Socket) async -> Void
        public typealias OnErrorHandler = (Swift.Error) async -> Void

        lazy var onClientHandler: OnClientHandler = handleClient
        lazy var onErrorHandler: OnErrorHandler = handleError

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
        public func onClient(_ handler: @escaping OnClientHandler) async -> Self {
            self.onClientHandler = handler
            return self
        }

        @discardableResult
        public func onError(_ handler: @escaping OnErrorHandler) async -> Self {
            self.onErrorHandler = handler
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
                    await self.onClientHandler(client)
                } catch {
                    await onErrorHandler(error)
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
            case let error as Network.Socket.Error where error == .connectionReset: break
            /* log other errors */
            default: await Log.error(String(describing: error))
            }
        }
    }
}
