import Test
import Platform
import AsyncDispatch
@testable import Network

class OptionsTests: TestCase {
    override func setUp() {
        AsyncDispatch().registerGlobal()
    }

    func testReuseAddr() {
        do {
            let socket = try Socket()
            var options = socket.options

            assertTrue(options.reuseAddr)
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
            var options = socket.options

            assertFalse(options.reusePort)
            options.reusePort = true
            assertTrue(options.reusePort)
        } catch {
            fail(String(describing: error))
        }
    }

    func testNoSignalPipe() {
        do {
            let socket = try Socket()
            var options = socket.options
        #if os(macOS)
            assertTrue(options.noSignalPipe)
        #endif
        } catch {
            fail(String(describing: error))
        }
    }

    func testConfigureReusePort() {
        do {
            let socket = try Socket().configure { $0.reusePort = true }

            assertTrue(socket.options.reuseAddr)
            assertTrue(socket.options.reusePort)
        } catch {
            fail(String(describing: error))
        }
    }

    func testConfigureBroadcast() {
        do {
            let socket = try Socket().configure { $0.broadcast = true }

            assertTrue(socket.options.broadcast)
        } catch {
            fail(String(describing: error))
        }
    }
}
