import Test
import Time
import Event
import Platform

@testable import Stream
@testable import Network

test.case("NetworkStream") {
    asyncTask {
        await scope {
            let listener = try Socket()
                .bind(to: "127.0.0.1", port: 7000)
                .listen()

            let server = try await listener.accept()
            let stream = NetworkStream(socket: server)

            var buffer = [UInt8](repeating: 0, count: 5)
            expect(try await stream.read(to: &buffer) == 5)
            expect(buffer == [0,1,2,3,4])

            expect(try await stream.write(from: [0,1,2,3,4]) == 5)
        }
    }

    asyncTask {
        await scope {
            let client = try await Socket().connect(to: "127.0.0.1", port: 7000)
            let stream = NetworkStream(socket: client)
            expect(try await stream.write(from: [0,1,2,3,4]) == 5)

            var buffer = [UInt8](repeating: 0, count: 5)
            expect(try await stream.read(to: &buffer) == 5)
        }

        await loop.terminate()
    }

    await loop.run()
}

#if os(macOS)
test.case("NetworkStreamError") {
    asyncTask {
        await scope {
            let listener = try Socket()
                .bind(to: "127.0.0.1", port: 7001)
                .listen()

            _ = try await listener.accept()
        }
    }

    asyncTask {
        await scope {
            let client = try await Socket().connect(to: "127.0.0.1", port: 7001)
            let stream = NetworkStream(socket: client)
            try client.close()

            var buffer = [UInt8](repeating: 0, count: 100)
            // FIXME: hangs on linux
            expect(throws: Socket.Error.badDescriptor) {
                _ = try await stream.read(to: &buffer)
            }
            expect(throws: Socket.Error.badDescriptor) {
                _ = try await stream.write(from: buffer)
            }

            await loop.terminate()
        }
    }

    await loop.run()
}
#endif

test.run()
