import Test
import Time
import Event
import Platform

@testable import Network

test.case("Server") {
    asyncTask {
        let server = try TCP.Server(host: "127.0.0.1", port: 5000)
        server.onClient = { socket in
            do {
                expect(try await socket.receive(maxLength: 5) == [0,1,2,3,4])
                expect(try await socket.send(bytes: [0,1,2,3,4]) == 5)
            } catch {
                fail(String(describing: error))
            }
        }
        try await server.start()
    }

    asyncTask {
        let client = try await TCP.Socket().connect(to: "127.0.0.1", port: 5000)
        expect(try await client.send(bytes: [0,1,2,3,4]) == 5)

        expect(try await client.receive(maxLength: 5) == [0,1,2,3,4])
    } deinit: {
        await loop.terminate()
    }

    await loop.run()
}

test.run()
