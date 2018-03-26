import Test
import Platform
import Dispatch
import AsyncDispatch

@testable import Async
@testable import Network

class NetworkStreamTests: TestCase {
    override func setUp() {
        async.setUp(Dispatch.self)
    }

    func withSocketPair(_ body: (Socket, Socket) throws -> Void) throws {
        let ready = DispatchSemaphore(value: 0)

        let listener = try Socket()
            .bind(to: "127.0.0.1", port: 7000)
            .listen()

        var server: Socket!

        async.task {
            do {
                ready.signal()
                server = try listener.accept()
                ready.signal()
            } catch {
                fail(String(describing: error))
            }
        }

        ready.wait()
        let client = try Socket().connect(to: "127.0.0.1", port: 7000)
        ready.wait()
        try body(server, client)
    }

    func testNetworkStream() {
        do {
            try withSocketPair { server, client in
                let serverStream = NetworkStream(socket: server)
                let clientStream = NetworkStream(socket: client)

                assertEqual(try clientStream.write(from: [0,1,2,3,4]), 5)
                var buffer = [UInt8](repeating: 0, count: 5)
                assertEqual(try serverStream.read(to: &buffer), 5)
                assertEqual(buffer, [0,1,2,3,4])

                assertEqual(try serverStream.write(from: [0,1,2,3,4]), 5)
                buffer = [UInt8](repeating: 0, count: 5)
                assertEqual(try clientStream.read(to: &buffer), 5)
            }
        } catch {
            fail(String(describing: error))
        }
    }

    func testNetworkStreamError() {
        do {
            try withSocketPair { server, client in
                let networkStream = NetworkStream(socket: client)
                try client.close()
                var buffer = [UInt8]()
                assertThrowsError(try networkStream.read(to: &buffer))
                assertThrowsError(try networkStream.write(from: buffer))
            }
        } catch {
            fail(String(describing: error))
        }
    }
}
