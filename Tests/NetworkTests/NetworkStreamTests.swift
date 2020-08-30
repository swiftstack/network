import Test
import Time
import Async
import Platform

@testable import Network

class NetworkStreamTests: TestCase {
    func testNetworkStream() {
        async {
            scope {
                let listener = try Socket()
                    .bind(to: "127.0.0.1", port: 7000)
                    .listen()

                let server = try listener.accept()

                let serverStream = NetworkStream(socket: server)

                var buffer = [UInt8](repeating: 0, count: 5)
                expect(try serverStream.read(to: &buffer) == 5)
                expect(buffer == [0,1,2,3,4])

                expect(try serverStream.write(from: [0,1,2,3,4]) == 5)
            }
        }
        async {
            scope {
                let client = try Socket().connect(to: "127.0.0.1", port: 7000)
                let clientStream = NetworkStream(socket: client)
                expect(try clientStream.write(from: [0,1,2,3,4]) == 5)

                var buffer = [UInt8](repeating: 0, count: 5)
                expect(try clientStream.read(to: &buffer) == 5)
            }
        }
        loop.run()
    }

    func testNetworkStreamError() {
        #if os(macOS)
        async {
            scope {
                let listener = try Socket()
                    .bind(to: "127.0.0.1", port: 7001)
                    .listen()

                _ = try listener.accept()
            }
        }

        async {
            scope {
                let client = try Socket().connect(to: "127.0.0.1", port: 7001)
                let clientStream = NetworkStream(socket: client)
                try client.close()

                var buffer = [UInt8](repeating: 0, count: 100)
                // FIXME: hangs on linux
                expect(throws: Socket.Error.badDescriptor) {
                    _ = try clientStream.read(to: &buffer)
                }
                expect(throws: Socket.Error.badDescriptor) {
                    _ = try clientStream.write(from: buffer)
                }
            }
        }

        loop.run()
        #endif
    }
}
