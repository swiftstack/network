import Test
import File
import Stream
import Fiber
import Platform
@testable import Log
@testable import Async
@testable import Network

class SystemLoggerTests: TestCase {
    var temp = Path(string: "/tmp/SystemLoggerTests")

    var isEnabled: Bool! = nil
    var level: Log.Message.Level! = nil
    var delegate: LogProtocol! = nil

    override func setUp() {
        async.setUp(Fiber.self)
        try? Directory.create(at: temp)

        isEnabled = Log.isEnabled
        level = Log.level
        delegate = Log.delegate
    }

    override func tearDown() {
        try? Directory.remove(at: temp)

        Log.isEnabled = isEnabled
        Log.level = level
        Log.delegate = delegate
    }

    func testSystemLogger() {
        let unixPath = self.temp.appending(#function).string
        let message = "message"

        unlink(unixPath)

        async.task {
            scope {
                let socket = try Socket(family: .local, type: .datagram)
                try socket.bind(to: unixPath)
                let result = try socket.read(max: 100, as: String.self)
                assertEqual(result, "[info] \(message)")

                // FIXME: Fiber itself uses Log outside of a fiber
                Log.use(Log.Terminal.shared)
                async.loop.terminate()
            }
        }

        async.task {
            scope {
                Log.use(try SystemLogger(unixPath: unixPath))
                Log.info(message)
            }
        }

        async.loop.run()
    }
}

extension Socket {
    func read(max: Int, as: String.Type) throws -> String {
        var client: Socket.Address? = nil
        var buffer = [UInt8](repeating: 0, count: max)
        _ = try receive(to: &buffer, from: &client)
        return String(cString: buffer + [0])
    }
}
