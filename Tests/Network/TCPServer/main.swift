import Test
import Event
import Platform

@testable import Network

test("Server") {
    Task {
        let server = try TCP.Server(host: "127.0.0.1", port: 5000)
        await server.onClient { socket in
            do {
                expect(try await socket.receive(maxLength: 5) == [0,1,2,3,4])
                expect(try await socket.send(bytes: [0,1,2,3,4]) == 5)
            } catch {
                fail(String(describing: error))
            }
        }
        try await server.start()
    }

    Task {
        let client = try await TCP.Socket().connect(to: "127.0.0.1", port: 5000)
        expect(try await client.send(bytes: [0,1,2,3,4]) == 5)

        expect(try await client.receive(maxLength: 5) == [0,1,2,3,4])
        await loop.terminate()
    }

    await loop.run()
}

test("chained api calls") {
    let address = try await TCP.Server(host: "127.0.0.1", port: 5001)
        .onClient { _ in }
        .onError { _ in }
        .address

    expect(address == "127.0.0.1:5001")
}

await run()
