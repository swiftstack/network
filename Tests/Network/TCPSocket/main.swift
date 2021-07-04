import IPC
import Test
import Event
import Platform

@testable import Stream
@testable import Network

test.case("Socket default") {
    let message = [UInt8]("ping".utf8)

    asyncTask {
        let socket = try TCP.Socket()
            .bind(to: "127.0.0.1", port: 3000)
            .listen()

        let client = try await socket.accept()
        let response = try await client.receive(maxLength: message.count)
        _ = try await client.send(bytes: response)
    }

    asyncTask {
        let socket = try await TCP.Socket()
            .connect(to: "127.0.0.1", port: 3000)

        let written = try await socket.send(bytes: message)
        expect(written == message.count)

        let response = try await socket.receive(maxLength: message.count)
        expect(response.count == message.count)
        expect(response == message)
    } deinit: {
        await loop.terminate()
    }

    await loop.run()
}

test.case("Socket IPv4") {
    let message = [UInt8]("ping".utf8)

    asyncTask {
        let socket = try TCP.Socket(family: .inet)
            .bind(to: "127.0.0.1", port: 3001)
            .listen()

        let client = try await socket.accept()
        let response = try await client.receive(maxLength: message.count)
        _ = try await client.send(bytes: response)
    }

    asyncTask {
        let socket = try await TCP.Socket(family: .inet)
            .connect(to: "127.0.0.1", port: 3001)

        let written = try await socket.send(bytes: message)
        expect(written == message.count)

        let response = try await socket.receive(maxLength: message.count)
        expect(response.count == message.count)
        expect(response == message)
    } deinit: {
        await loop.terminate()
    }

    await loop.run()
}

test.case("Socket IPv6") {
    let message = [UInt8]("ping".utf8)

    asyncTask {
        let socket = try TCP.Socket(family: .inet6)
            .bind(to: "::1", port: 3003)
            .listen()

        let client = try await socket.accept()
        let response = try await client.receive(maxLength: message.count)
        _ = try await client.send(bytes: response)
    }

    asyncTask {
        let socket = try await TCP.Socket(family: .inet6)
            .connect(to: "::1", port: 3003)

        let written = try await socket.send(bytes: message)
        expect(written == message.count)

        let response = try await socket.receive(maxLength: message.count)
        expect(response.count == message.count)
        expect(response == message)
    } deinit: {
        await loop.terminate()
    }

    await loop.run()
}

test.case("Socket Unix") {
    let message = [UInt8]("ping".utf8)

    #if os(macOS)
    let address = "/private/tmp/teststream.sock"
    #else
    let address = "/tmp/teststream.sock"
    #endif

    unlink(address)

    let serverIsReady = Condition()

    asyncTask {
        let socket = try TCP.Socket(family: .local)
            .bind(to: address)
            .listen()

        await serverIsReady.notify()

        let client = try await socket.accept()
        let response = try await client.receive(maxLength: message.count)
        _ = try await client.send(bytes: response)
    }

    asyncTask {
        await serverIsReady.wait()

        let socket = try await TCP.Socket(family: .local)
            .connect(to: address)

        let written = try await socket.send(bytes: message)
        expect(written == message.count)

        let response = try await socket.receive(maxLength: message.count)
        expect(response.count == message.count)
        expect(response == message)
    } deinit: {
        await loop.terminate()
    }

    await loop.run()
}

#if os(Linux)
test.case("Socket Unix Sequenced") {
    let message = [UInt8]("ping".utf8)

    unlink("/tmp/testsequenced.sock")

    let serverIsReady = Condition()

    asyncTask {
        let socket = try TCP.Socket(.init(family: .local, type: .sequenced))
            .bind(to: "/tmp/testsequenced.sock")
            .listen()

        await serverIsReady.notify()

        let client = try await socket.accept()
        let response = try await client.receive(maxLength: message.count)
        _ = try await client.send(bytes: response)
    }

    asyncTask {
        await serverIsReady.wait()

        let socket = try await TCP.Socket(.init(family: .local, type: .sequenced))
            .connect(to: "/tmp/testsequenced.sock")

        let written = try await socket.send(bytes: message)
        expect(written == message.count)

        let response = try await socket.receive(maxLength: message.count)
        expect(response.count == message.count)
        expect(response == message)
    } deinit: {
        await loop.terminate()
    }

    await loop.run()
}
#endif

test.run()
