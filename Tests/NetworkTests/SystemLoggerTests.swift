import Test
import Async
import Stream
import Platform
import FileSystem
@testable import Log
@testable import Network

class SystemLoggerTests: TestCase {
    var temp: Path = try! .init("/tmp/SystemLoggerTests")

    var isEnabled: Bool! = nil
    var level: Log.Message.Level! = nil
    var delegate: LogProtocol! = nil

    override func setUp() {
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

    func testSystemLogger() throws {
        let unixPath = try temp.appending(#function).string
        let message = "message"

        unlink(unixPath)

        async {
            scope {
                let socket = try Socket(family: .local, type: .datagram)
                try socket.bind(to: unixPath)
                let result = try socket.read(max: 100, as: String.self)
                expect(result == "[info] \(message)")

                // FIXME: Fiber itself uses Log outside of a fiber
                Log.use(Log.Terminal.shared)
                loop.terminate()
            }
        }

        async {
            scope {
                Log.use(try SystemLogger(unixPath: unixPath))
                Log.info(message)
            }
        }

        loop.run()
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
