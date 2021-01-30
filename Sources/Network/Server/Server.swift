import Log
import Platform

public class Server {
    var handle: Task.Handle<Void>?

    public let socket: Socket

    public var onClient: (Socket) async -> Void = { _ in }
    public var onError: (Error) async -> Void = { _ in }

    public var address: String {
        return socket.selfAddress!.description
    }

    public init(host: String, port: Int) throws {
        let socket = try Socket()
        try socket.bind(to: host, port: port)
        self.socket = socket
        self.onClient = handleClient
        self.onError = handleError
    }

    convenience
    public init(host: String, reusePort: Int) throws {
        try self.init(host: host, port: reusePort)
        try socket.options.set(.reusePort, true)
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
                let client = try await socket.accept()
                await onClient(client)
            } catch {
                await onError(error)
            }
        }
    }

    func handleClient (_ socket: Socket) async {
        try? socket.close()
        await Log.warning("unhandled client")
    }

    func handleError (_ error: Error) async {
        switch error {
        /* connection reset by peer */
        /* do nothing, it's fine. */
        case let error as Socket.Error where error == .connectionReset: break
        /* log other errors */
        default: await Log.error(String(describing: error))
        }
    }
}
