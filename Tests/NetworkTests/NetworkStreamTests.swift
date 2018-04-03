import Test
import Time
import Fiber
import Platform

@testable import Async
@testable import Network

class NetworkStreamTests: TestCase {
    override func setUp() {
        async.setUp(Fiber.self)
    }

    func testNetworkStream() {
        async.task {
            scope {
                let listener = try Socket()
                    .bind(to: "127.0.0.1", port: 7000)
                    .listen()

                let server = try listener.accept()

                let serverStream = NetworkStream(socket: server)

                var buffer = [UInt8](repeating: 0, count: 5)
                assertEqual(try serverStream.read(to: &buffer), 5)
                assertEqual(buffer, [0,1,2,3,4])

                assertEqual(try serverStream.write(from: [0,1,2,3,4]), 5)
            }
        }
        async.task {
            scope {
                let client = try Socket().connect(to: "127.0.0.1", port: 7000)
                let clientStream = NetworkStream(socket: client)
                assertEqual(try clientStream.write(from: [0,1,2,3,4]), 5)

                var buffer = [UInt8](repeating: 0, count: 5)
                assertEqual(try clientStream.read(to: &buffer), 5)
            }
        }
        async.loop.run()
    }

    func testNetworkStreamError() {
        #if os(macOS)
        async.task {
            scope {
                let listener = try Socket()
                    .bind(to: "127.0.0.1", port: 7001)
                    .listen()

                _ = try listener.accept()
            }
        }

        async.task {
            scope {
                let client = try Socket().connect(to: "127.0.0.1", port: 7001)
                let clientStream = NetworkStream(socket: client)
                try client.close()

                var buffer = [UInt8](repeating: 0, count: 100)
                // FIXME: hangs on linux
                assertThrowsError(try clientStream.read(to: &buffer))
                assertThrowsError(try clientStream.write(from: buffer))
            }
        }

        async.loop.run()
        #endif
    }
}
