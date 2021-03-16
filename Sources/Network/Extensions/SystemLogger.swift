import Log
import Platform

public class SystemLogger: LogProtocol {
    #if os(macOS)
    var log = try! Socket.Address(unix: "/var/run/syslog")
    #else
    var log = try! Socket.Address(unix: "/dev/log")
    #endif

    var reconnectAttempts = 2
    public var socket: UDP.Socket

    public init() throws {
        self.socket = try UDP.Socket(family: .local)
    }

    deinit {
        try? socket.close()
    }

    public func handle(_ message: Log.Message) async {
        let message = "[\(message.level)] \(message.payload)"

        for _ in 0..<reconnectAttempts {
            do {
                try await write(message)
                return
            } catch {
                reconnect()
            }
        }

        print("can't log message", message)
    }

    // TODO: optimize
    func write(_ message: String) async throws {
        let data = [UInt8](message.utf8)
        var total = 0
        while total < data.count {
            let rest = [UInt8](data[total...])
            let written = try await socket.send(bytes: rest, to: log)
            guard written > 0 else {
                throw Network.Socket.Error.connectionReset
            }
            total += written
        }
    }

    func reconnect() {
        try? socket.close()
        do {
            self.socket = try UDP.Socket(family: .local)
        } catch {
            print("can't create syslog socket: \(error)")
        }
    }
}

extension SystemLogger {
    convenience // @testable
    init(unixPath path: String) throws {
        try self.init()
        self.log = try Socket.Address(unix: path)
    }
}
