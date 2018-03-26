import Test
import Platform
import AsyncDispatch

@testable import Async
@testable import Network

class OptionsTests: TestCase {
    override func setUp() {
        async.setUp(Dispatch.self)
    }

    func testReuseAddr() {
        do {
            let socket = try Socket()
            assertTrue(try socket.options.get(.reuseAddr))
        } catch {
            fail(String(describing: error))
        }
    }

    func testReuseAddrUnix() {
        unlink("/tmp/unix1")
        do {
            _ = try Socket()
                .bind(to: "/tmp/unix1")

            _ = try Socket()
                .bind(to: "/tmp/unix1")

            fail("did not throw an error")
        } catch {

        }
    }

    func testReusePort() {
        do {
            let socket = try Socket()
            assertFalse(try socket.options.get(.reusePort))
            assertNoThrow(try socket.options.set(.reusePort, true))
            assertTrue(try socket.options.get(.reusePort))
        } catch {
            fail(String(describing: error))
        }
    }

    func testNoSignalPipe() {
        do {
            let socket = try Socket()
        #if os(macOS)
            assertTrue(try socket.options.get(.noSignalPipe))
        #endif
        } catch {
            fail(String(describing: error))
        }
    }

    func testConfigureReusePort() {
        do {
            let socket = try Socket().configure { options in
                try options.set(.reusePort, true)
            }

            assertTrue(try socket.options.get(.reuseAddr))
            assertTrue(try socket.options.get(.reusePort))
        } catch {
            fail(String(describing: error))
        }
    }

    func testConfigureBroadcast() {
        do {
            let socket = try Socket().configure { options in
                try options.set(.broadcast, true)
            }

            assertTrue(try socket.options.get(.broadcast))
        } catch {
            fail(String(describing: error))
        }
    }
}
