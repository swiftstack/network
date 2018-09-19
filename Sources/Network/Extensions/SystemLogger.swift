import Log

public class SystemLogger: LogProtocol {
    #if os(macOS)
    var log = try! Socket.Address(unix: "/var/run/syslog")
    #else
    var log = try! Socket.Address(unix: "/dev/log")
    #endif

    var reconnectAttempts = 2
    public var socket: Socket

    public init() throws {
        self.socket = try Socket(family: .local, type: .datagram)
    }

    deinit {
        try? socket.close()
    }

    public func handle(_ message: Log.Message) {
        let message = "[\(message.level)] \(message.payload)"

        for _ in 0..<reconnectAttempts {
            do {
                try write(message)
                return
            } catch {
                reconnect()
            }
        }

        print("can't log message", message)
    }

    func write(_ message: String) throws {
        let data = [UInt8](message.utf8)
        var total = 0
        while total < data.count {
            let written = try socket.send(bytes: data, to: log)
            guard written > 0 else {
                throw SocketError()
            }
            total += written
        }
    }

    func reconnect() {
        try? socket.close()
        do {
            self.socket = try Socket(family: .local, type: .datagram)
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
