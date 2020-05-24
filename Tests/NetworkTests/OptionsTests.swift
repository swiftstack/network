import Test
import Fiber
import Platform

@testable import Async
@testable import Network

class OptionsTests: TestCase {
    override func setUp() {
        async.setUp(Fiber.self)
    }

    func testReuseAddr() throws {
        let socket = try Socket()
        expect(try socket.options.get(.reuseAddr) == true)
    }

    func testReuseAddrUnix() throws {
        unlink("/tmp/unix1")
        try Socket(family: .local).bind(to: "/tmp/unix1")
        do {
            try Socket(family: .local).bind(to: "/tmp/unix1")
        } catch {
            print(error)
        }
    }

    func testReusePort() throws {
        let socket = try Socket()
        expect(try socket.options.get(.reusePort) == false)
        try socket.options.set(.reusePort, true)
        expect(try socket.options.get(.reusePort) == true)
    }

    func testNoSignalPipe() throws {
        let socket = try Socket()
        #if os(macOS)
        expect(try socket.options.get(.noSignalPipe) == true)
        #endif
    }

    func testConfigureReusePort() throws {
        let socket = try Socket().configure { options in
            try options.set(.reusePort, true)
        }
        expect(try socket.options.get(.reuseAddr) == true)
        expect(try socket.options.get(.reusePort) == true)
    }

    func testConfigureBroadcast() throws {
        let socket = try Socket().configure { options in
            try options.set(.broadcast, true)
        }
        expect(try socket.options.get(.broadcast) == true)
    }
}
