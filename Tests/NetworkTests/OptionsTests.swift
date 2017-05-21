import Test
import Platform
@testable import Network

class OptionsTests: TestCase {
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
            let socket = try Socket().configure(reusePort: true)

            assertTrue(socket.options.reuseAddr)
            assertTrue(socket.options.reusePort)
        } catch {
            fail(String(describing: error))
        }
    }
}
