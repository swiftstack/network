import Test
import Event
import Platform

@testable import Stream
@testable import Network

test("NetworkStream") {
    Task {
        let listener = try TCP.Socket()
            .bind(to: "127.0.0.1", port: 7000)
            .listen()

        let server = try await listener.accept()
        let stream = TCP.Stream(socket: server)

        var buffer = [UInt8](repeating: 0, count: 5)
        expect(try await stream.read(to: &buffer) == 5)
        expect(buffer == [0,1,2,3,4])

        expect(try await stream.write(from: [0,1,2,3,4]) == 5)
    }

    Task {
        let client = try await TCP.Socket().connect(to: "127.0.0.1", port: 7000)
        let stream = TCP.Stream(socket: client)
        expect(try await stream.write(from: [0,1,2,3,4]) == 5)

        var buffer = [UInt8](repeating: 0, count: 5)
        expect(try await stream.read(to: &buffer) == 5)
    
        await loop.terminate()
    }

    await loop.run()
}

#if os(macOS)
test("NetworkStreamError") {
    Task {
        let listener = try TCP.Socket()
            .bind(to: "127.0.0.1", port: 7001)
            .listen()

        _ = try await listener.accept()
    }

    Task {
        let client = try await TCP.Socket().connect(to: "127.0.0.1", port: 7001)
        let stream = TCP.Stream(socket: client)
        try client.close()

        var buffer = [UInt8](repeating: 0, count: 100)
        // FIXME: hangs on linux
        await expect(throws: Socket.Error.badDescriptor) {
            _ = try await stream.read(to: &buffer)
        }
        await expect(throws: Socket.Error.badDescriptor) {
            _ = try await stream.write(from: buffer)
        }
    
        await loop.terminate()
    }

    await loop.run()
}
#endif

await run()
