import Test
import Event
import Platform

@testable import Network

test.case("UDP IPv4 Socket") {
    let message = [UInt8]("ping".utf8)

    asyncTask {
        let server = try! Socket.Address("127.0.0.1", port: 3002)
        let socket = try UDP.Socket(family: .inet)
            .bind(to: server)

        let result = try await socket.receive(maxLength: message.count)
        _ = try await socket.send(bytes: result.bytes, to: result.from)
    }

    asyncTask {
        let server = try! Socket.Address("127.0.0.1", port: 3002)
        let socket = try UDP.Socket(family: .inet)

        let written = try await socket.send(bytes: message, to: server)
        expect(written == message.count)

        let result = try await socket.receive(maxLength: message.count)
        expect(result.from == server)
        expect(result.bytes.count == message.count)
        expect(result.bytes == message)
    } deinit: {
        await loop.terminate()
    }

    await loop.run()
}

test.case("UDP IPv6 Socket") {
    let message = [UInt8]("ping".utf8)

    asyncTask {
        let server = try! Socket.Address("::1", port: 3004)
        let socket = try UDP.Socket(family: .inet6)
            .bind(to: server)

        let result = try await socket.receive(maxLength: message.count)
        _ = try await socket.send(bytes: result.bytes, to: result.from)
    }

    asyncTask {
        let server = try! Socket.Address("::1", port: 3004)
        let socket = try UDP.Socket(family: .inet6)

        let written = try await socket.send(bytes: message, to: server)
        expect(written == message.count)

        let result = try await socket.receive(maxLength: message.count)
        expect(result.from == server)
        expect(result.bytes.count == message.count)
        expect(result.bytes == message)
    } deinit: {
        await loop.terminate()
    }

    await loop.run()
}

test.case("UDP Unix Socket") {
    let message = [UInt8]("ping".utf8)

    #if os(macOS)
    let serverSocket = "/private/tmp/testdatagramserver.sock"
    let clientSocket = "/private/tmp/testdatagramclient.sock"
    #else
    let serverSocket = "/tmp/testdatagramserver.sock"
    let clientSocket = "/tmp/testdatagramclient.sock"
    #endif

    unlink(serverSocket)
    unlink(clientSocket)

    asyncTask {
        let server = try! Socket.Address(serverSocket)
        let socket = try UDP.Socket(family: .local)
            .bind(to: server)

        let result = try await socket.receive(maxLength: message.count)
        _ = try await socket.send(bytes: result.bytes, to: result.from)
    }

    asyncTask {
        let server = try! Socket.Address(serverSocket)
        let client = try! Socket.Address(clientSocket)
        let socket = try UDP.Socket(family: .local)
            .bind(to: client)

        let written = try await socket.send(bytes: message, to: server)
        expect(written == message.count)

        let result = try await socket.receive(maxLength: message.count)
        expect(result.from == server)
        expect(result.bytes.count == message.count)
        expect(result.bytes == message)
    } deinit: {
        await loop.terminate()
    }

    await loop.run()
}

await test.run()
