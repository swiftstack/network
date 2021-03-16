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
        var buffer = [UInt8](repeating: 0, count: max)
        let (count,_) = try await receive(to: &buffer)
        return String(decoding: buffer[..<count], as: UTF8.self)
    }
}

test.run()
