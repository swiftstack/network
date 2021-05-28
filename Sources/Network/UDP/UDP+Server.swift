import Log
import Platform

extension UDP {
    public actor Server {
        public let socket: UDP.Socket

        @actorIndependent(unsafe)
        public var onData: (
            _ bytes: [UInt8],
            _ from: Network.Socket.Address
        ) async -> Void = { _, _  in }

        @actorIndependent(unsafe)
        public var onError: (Swift.Error) async -> Void = { _ in }

        @actorIndependent
        public var address: String {
            return socket.selfAddress!.description
        }

        public init(host: String, port: Int) throws {
            let socket = try UDP.Socket()
            try socket.bind(to: host, port: port)
            self.socket = socket
            self.onData = handleData
            self.onError = handleError
        }

        convenience
        public init(host: String, reusePort: Int) throws {
            try self.init(host: host, port: reusePort)
            socket.socket.reusePort = true
        }

        deinit {
            try? socket.close()
        }

        public func start() async throws {
            try socket.listen()
            await startAsync()
        }

        func startAsync() async {
            while true {
                do {
                    let result = try await socket.receive(maxLength: 16348)
                    await self.onData(result.data, result.from)
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
