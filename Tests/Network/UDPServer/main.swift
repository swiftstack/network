import Test
import Event
import Platform

@testable import Network

test.case("Server") {
    asyncTask {
        let server = try UDP.Server(host: "127.0.0.1", port: 8000)
        await server.onData { (bytes, from) in
            do {
                expect(bytes == [0,1,2,3,4])
                let socket = try UDP.Socket()
                let sent = try await socket.send(bytes: bytes, to: from)
                expect(sent == 5)
            } catch {
                fail(String(describing: error))
            }
        }
        try await server.start()
    }

    asyncTask {
        let server = try! Socket.Address("127.0.0.1", port: 8000)
        let socket = try UDP.Socket()

        // FIXME: Use IPC package
        await Task.sleep(1_000_000)

        let sent = try await socket.send(bytes: [0,1,2,3,4], to: server)
        expect(sent == 5)

        let (data, _) = try await socket.receive(maxLength: 5)
        expect(data == [0,1,2,3,4])
    } deinit: {
        await loop.terminate()
    }

    await loop.run()
}

test.case("chained api calls") {
    let address = try await UDP.Server(host: "127.0.0.1", port: 8001)
        .onData { _, _ in }
        .onError { _ in }
        .address

    expect(address == "127.0.0.1:8001")
}

test.run()
