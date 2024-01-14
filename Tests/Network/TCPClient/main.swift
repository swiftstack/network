import Test
import Event
import Platform

@testable import Stream
@testable import Network

test("Client") {
    Task {
        let socket = try TCP.Socket()
            .bind(to: "127.0.0.1", port: 6000)
            .listen()

        let client = try await socket.accept()
        let bytes = try await client.receive(maxLength: 5)
        _ = try await client.send(bytes: bytes)
    }

    Task {
        let client = TCP.Client(host: "127.0.0.1", port: 6000)
        let stream = try await client.connect()
        expect(try await stream.write(from: [0,1,2,3,4]) == 5)

        var buffer = [UInt8](repeating: 0, count: 5)
        expect(try await stream.read(to: &buffer) == 5)
    
        await loop.terminate()
    }

    await loop.run()
}

await run()
