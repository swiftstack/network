import Test
import Event
import Platform

@testable import Stream
@testable import Network

test.case("Socket") {
    let message = [UInt8]("ping".utf8)

    asyncTask {
        let socket = try Socket()
            .bind(to: "127.0.0.1", port: 3000)
            .listen()

        let client = try await socket.accept()
        var buffer = [UInt8](repeating: 0, count: message.count)
        _ = try await client.receive(to: &buffer)
        _ = try await client.send(bytes: buffer)
    }

    asyncTask {
        let socket = try await Socket()
            .connect(to: "127.0.0.1", port: 3000)

        let written = try await socket.send(bytes: message)
        expect(written == message.count)

        var response = [UInt8](repeating: 0, count: message.count)
        let read = try await socket.receive(to: &response)
        expect(read == message.count)
        expect(response == message)

        await loop.terminate()
    }

    await loop.run()
}

test.case("SocketInetStream") {
    let message = [UInt8]("ping".utf8)

    asyncTask {
        let socket = try Socket(family: .inet, type: .stream)
            .bind(to: "127.0.0.1", port: 3001)
            .listen()

        let client = try await socket.accept()
        var buffer = [UInt8](repeating: 0, count: message.count)
        _ = try await client.receive(to: &buffer)
        _ = try await client.send(bytes: buffer)
    }


    asyncTask {
        let socket = try await Socket(family: .inet, type: .stream)
            .connect(to: "127.0.0.1", port: 3001)

        let written = try await socket.send(bytes: message)
        expect(written == message.count)

        var response = [UInt8](repeating: 0, count: message.count)
        let read = try await socket.receive(to: &response)
        expect(read == message.count)
        expect(response == message)

        await loop.terminate()
    }

    await loop.run()
}

test.case("SocketInetDatagram") {
    let message = [UInt8]("ping".utf8)

    let server = try! Socket.Address("127.0.0.1", port: 3002)

    asyncTask {
        let socket = try Socket(family: .inet, type: .datagram)
            .bind(to: server)

        var buffer = [UInt8](repeating: 0, count: message.count)
        var client: Socket.Address? = nil
        _ = try await socket.receive(to: &buffer, from: &client)
        _ = try await socket.send(bytes: message, to: client!)
    }

    asyncTask {
        let socket = try Socket(family: .inet, type: .datagram)

        let written = try await socket.send(bytes: message, to: server)
        expect(written == message.count)

        var sender: Socket.Address? = nil
        var buffer = [UInt8](repeating: 0, count: message.count)
        let read = try await socket.receive(to: &buffer, from: &sender)
        expect(sender == server)
        expect(read == message.count)
        expect(buffer == message)

        await loop.terminate()
    }

    await loop.run()
}

test.case("SocketInet6Stream") {
    let message = [UInt8]("ping".utf8)

    asyncTask {
        let socket = try Socket(family: .inet6, type: .stream)
            .bind(to: "::1", port: 3003)
            .listen()

        let client = try await socket.accept()
        var buffer = [UInt8](repeating: 0, count: message.count)
        _ = try await client.receive(to: &buffer)
        _ = try await client.send(bytes: buffer)
    }

    asyncTask {
        let socket = try await Socket(family: .inet6, type: .stream)
            .connect(to: "::1", port: 3003)

        let written = try await socket.send(bytes: message)
        expect(written == message.count)

        var response = [UInt8](repeating: 0, count: message.count)
        let read = try await socket.receive(to: &response)
        expect(read == message.count)
        expect(response == message)

        await loop.terminate()
    }

    await loop.run()
}

test.case("SocketInet6Datagram") {
    let message = [UInt8]("ping".utf8)

    let server = try! Socket.Address("::1", port: 3004)

    asyncTask {
        let socket = try Socket(family: .inet6, type: .datagram)
            .bind(to: server)

        var client: Socket.Address? = nil
        var buffer = [UInt8](repeating: 0, count: message.count)
        _ = try await socket.receive(to: &buffer, from: &client)
        _ = try await socket.send(bytes: message, to: client!)
    }

    asyncTask {
        let socket = try Socket(family: .inet6, type: .datagram)

        let written = try await socket.send(bytes: message, to: server)
        expect(written == message.count)

        var sender: Socket.Address? = nil
        var buffer = [UInt8](repeating: 0, count: message.count)
        let read = try await socket.receive(to: &buffer, from: &sender)
        expect(sender == server)
        expect(read == message.count)
        expect(buffer == message)

        await loop.terminate()
    }

    await loop.run()
}

test.case("SocketUnixStream") {
    let message = [UInt8]("ping".utf8)

    unlink("/tmp/teststream.sock")
    asyncTask {
        let socket = try Socket(family: .local, type: .stream)
            .bind(to: "/tmp/teststream.sock")
            .listen()

        let client = try await socket.accept()
        var buffer = [UInt8](repeating: 0, count: message.count)
        _ = try await client.receive(to: &buffer)
        _ = try await client.send(bytes: buffer)
    }

    asyncTask {
        let socket = try await Socket(family: .local, type: .stream)
            .connect(to: "/tmp/teststream.sock")

        let written = try await socket.send(bytes: message)
        expect(written == message.count)

        var response = [UInt8](repeating: 0, count: message.count)
        let read = try await socket.receive(to: &response)
        expect(read == message.count)
        expect(response == message)

        await loop.terminate()
    }

    await loop.run()
}

test.case("SocketUnixDatagram") {
    let message = [UInt8]("ping".utf8)

    unlink("/tmp/testdatagramserver.sock")
    unlink("/tmp/testdatagramclient.sock")
    let server = try! Socket.Address("/tmp/testdatagramserver.sock")
    let client = try! Socket.Address("/tmp/testdatagramclient.sock")

    asyncTask {
        let socket = try Socket(family: .local, type: .datagram)
            .bind(to: server)

        var client: Socket.Address? = nil
        var buffer = [UInt8](repeating: 0, count: message.count)
        _ = try await socket.receive(to: &buffer, from: &client)
        _ = try await socket.send(bytes: message, to: client!)
    }

    asyncTask {
        let socket = try Socket(family: .local, type: .datagram)
            .bind(to: client)

        let written = try await socket.send(bytes: message, to: server)
        expect(written == message.count)

        var sender: Socket.Address? = nil
        var buffer = [UInt8](repeating: 0, count: message.count)
        let read = try await socket.receive(to: &buffer, from: &sender)
        expect(sender == server)
        expect(read == message.count)
        expect(buffer == message)

        await loop.terminate()
    }

    await loop.run()
}

#if os(Linux)
test.case("SocketUnixSequenced") {
    let message = [UInt8]("ping".utf8)

    unlink("/tmp/testsequenced.sock")
    asyncTask {
        let socket = try Socket(family: .local, type: .sequenced)
            .bind(to: "/tmp/testsequenced.sock")
            .listen()

        let client = try socket.accept()
        var buffer = [UInt8](repeating: 0, count: message.count)
        _ = try client.receive(to: &buffer)
        _ = try client.send(bytes: buffer)
    }

    asyncTask {
        let socket = try Socket(family: .local, type: .sequenced)
            .connect(to: "/tmp/testsequenced.sock")

        let written = try socket.send(bytes: message)
        expect(written == message.count)

        var response = [UInt8](repeating: 0, count: message.count)
        let read = try socket.receive(to: &response)
        expect(read == message.count)
        expect(response == message)

        await loop.terminate()
    }

    await loop.run()
}
#endif

test.run()
