import Log
import Platform

extension UDP {
    public actor Server {
        public let socket: UDP.Socket

        public nonisolated var address: String {
            return socket.selfAddress!.description
        }

        public typealias Address = Network.Socket.Address
        public typealias OnDataHandler = ([UInt8], Address) async -> Void
        public typealias OnErrorHandler = (Swift.Error) async -> Void

        lazy var onDataHandler: OnDataHandler = handleData
        lazy var onErrorHandler: OnErrorHandler = handleError

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
        public func onData(_ handler: @escaping OnDataHandler) async -> Self {
            self.onDataHandler = handler
            return self
        }

        @discardableResult
        public func onError(_ handler: @escaping OnErrorHandler) async -> Self {
            self.onErrorHandler = handler
            return self
        }

        public func start() async throws {
            await startAsync()
        }

        func startAsync() async {
            while true {
                do {
                    let (bytes, from) = try await socket.receive(maxLength: 16348)
                    await self.onDataHandler(bytes, from)
                } catch {
                    await onErrorHandler(error)
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
