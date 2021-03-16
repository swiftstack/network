import Test
import Time
import Event
import Platform

@testable import Stream
@testable import Network

test.case("Client") {
    asyncTask {
        let socket = try TCP.Socket()
            .bind(to: "127.0.0.1", port: 6000)
            .listen()

        let client = try await socket.accept()
        var buffer = [UInt8](repeating: 0, count: 5)
        _ = try await client.receive(to: &buffer)
        _ = try await client.send(bytes: [0,1,2,3,4])
    }

    asyncTask {
        let client = TCP.Client(host: "127.0.0.1", port: 6000)
        let stream = try await client.connect()
        expect(try await stream.write(from: [0,1,2,3,4]) == 5)

        var buffer = [UInt8](repeating: 0, count: 5)
        expect(try await stream.read(to: &buffer) == 5)
    } deinit: {
        await loop.terminate()
    }

    await loop.run()
}

test.run()
