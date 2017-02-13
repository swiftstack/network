import XCTest
@testable import Socket

class OptionsTests: XCTestCase {
    func testReuseAddr() {
        do {
            let socket = try Socket()
            var options = socket.options

            XCTAssertTrue(options.reuseAddr)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testReuseAddrUnix() {
        unlink("/tmp/unix1")
        do {
            _ = try Socket()
                .bind(to: "/tmp/unix1")

            _ = try Socket()
                .bind(to: "/tmp/unix1")

            XCTFail("did not throw an error")
        } catch {

        }
    }

    func testReusePort() {
        do {
            let socket = try Socket()
            var options = socket.options

            XCTAssertFalse(options.reusePort)
            options.reusePort = true
            XCTAssertTrue(options.reusePort)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testNoSignalPipe() {
        do {
            let socket = try Socket()
            var options = socket.options
        #if os(macOS)
            XCTAssertTrue(options.noSignalPipe)
        #endif
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testConfigureReusePort() {
        do {
            let socket = try Socket().configure(reusePort: true)

            XCTAssertTrue(socket.options.reuseAddr)
            XCTAssertTrue(socket.options.reusePort)
        } catch {
            XCTFail(String(describing: error))
        }
    }
}
