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
        let socket = try UDP.Socket(family: .local)
        try socket.bind(to: unixPath)
        let result = try await socket.read(max: 100, as: String.self)
        expect(result == "[info] \(message)")
    } deinit: {
        await loop.terminate()
    }

    asyncTask {
        Log.use(try SystemLogger(unixPath: unixPath))
        await Log.info(message)
    }

    await loop.run()
}

extension UDP.Socket {
    func read(max: Int, as: String.Type) async throws -> String {
        let result = try await receive(maxLength: max)
        return String(decoding: result.bytes, as: UTF8.self)
    }
}

test.run()
