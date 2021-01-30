import Test
import Event
import Stream
import Platform

@testable import Log
@testable import Network

test.case("SystemLogger") {
    let unixPath = "/tmp/SystemLoggerTest"
    let message = "message"

    unlink(unixPath)

    asyncTask {
        await scope {
            let socket = try Socket(family: .local, type: .datagram)
            try socket.bind(to: unixPath)
            let result = try await socket.read(max: 100, as: String.self)
            expect(result == "[info] \(message)")
        }
        await loop.terminate()
    }

    asyncTask {
        await scope {
            Log.use(try SystemLogger(unixPath: unixPath))
            await Log.info(message)
        }
    }

    await loop.run()
}

extension Socket {
    func read(max: Int, as: String.Type) async throws -> String {
        var client: Socket.Address? = nil
        var buffer = [UInt8](repeating: 0, count: max)
        _ = try await receive(to: &buffer, from: &client)
        return String(cString: buffer + [0])
    }
}

test.run()
