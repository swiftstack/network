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

        var buffer = [UInt8](repeating: 0, count: message.count)
        let (_, client) = try await socket.receive(to: &buffer)
        _ = try await socket.send(bytes: message, to: client!)
    }

    asyncTask {
        let server = try! Socket.Address("127.0.0.1", port: 3002)
        let socket = try UDP.Socket(family: .inet)

        let written = try await socket.send(bytes: message, to: server)
        expect(written == message.count)

        var buffer = [UInt8](repeating: 0, count: message.count)
        let (read, sender) = try await socket.receive(to: &buffer)
        expect(sender == server)
        expect(read == message.count)
        expect(buffer == message)
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

        var buffer = [UInt8](repeating: 0, count: message.count)
        let (_, client) = try await socket.receive(to: &buffer)
        _ = try await socket.send(bytes: message, to: client!)
    }

    asyncTask {
        let server = try! Socket.Address("::1", port: 3004)
        let socket = try UDP.Socket(family: .inet6)

        let written = try await socket.send(bytes: message, to: server)
        expect(written == message.count)

        var buffer = [UInt8](repeating: 0, count: message.count)
        let (read, sender) = try await socket.receive(to: &buffer)
        expect(sender == server)
        expect(read == message.count)
        expect(buffer == message)
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

        var buffer = [UInt8](repeating: 0, count: message.count)
        let (_, client) = try await socket.receive(to: &buffer)
        _ = try await socket.send(bytes: message, to: client!)
    }

    asyncTask {
        let server = try! Socket.Address(serverSocket)
        let client = try! Socket.Address(clientSocket)
        let socket = try UDP.Socket(family: .local)
            .bind(to: client)

        let written = try await socket.send(bytes: message, to: server)
        expect(written == message.count)

        var buffer = [UInt8](repeating: 0, count: message.count)
        let (read, sender) = try await socket.receive(to: &buffer)
        expect(sender == server)
        expect(read == message.count)
        expect(buffer == message)
    } deinit: {
        await loop.terminate()
    }

    await loop.run()
}

test.run()
