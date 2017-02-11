import XCTest
import Platform
import Dispatch
@testable import Socket

class SocketAwaiterTests: XCTestCase {
    class TestAwaiter: IOAwaiter {
        var event: IOEvent? = nil
        func wait(for descriptor: Descriptor, event: IOEvent) throws {
            self.event = event
        }
    }

    let message = [UInt8]("ping".utf8)

    override func setUp() {
        let condition = AtomicCondition()
        DispatchQueue.global().async {
            do {
                let socket = try Socket()
                try socket.listen(at: "127.0.0.1", port: 4445)
                condition.signal()
                let client = try socket.accept()
                _ = try client.write(bytes: self.message)
            } catch {
                XCTFail(String(describing: error))
            }
        }
        condition.wait()
    }

    func testSocketAwaiterAccept() {
        let condition = AtomicCondition()

        DispatchQueue.global().async {
            do {
                let awaiter = TestAwaiter()
                let socket = try Socket(awaiter: awaiter)
                try socket.listen(at: "127.0.0.1", port: 4445)
                condition.signal()
                _ = try socket.accept()
                XCTAssertEqual(awaiter.event, .read)
            } catch {
                XCTFail(String(describing: error))
            }
        }

        condition.wait()

        do {
            let socket = try Socket()
            _ = try socket.connect(to: "127.0.0.1", port: 4445)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSocketAwaiterWrite() {
        do {
            let awaiter = TestAwaiter()
            let socket = try Socket(awaiter: awaiter)
            _ = try socket.connect(to: "127.0.0.1", port: 4445)
            _ = try socket.write(bytes: message)
            XCTAssertEqual(awaiter.event, .write)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSocketAwaiterRead() {
        var response = [UInt8](repeating: 0, count: message.count)
        do {
            let awaiter = TestAwaiter()
            let socket = try Socket(awaiter: awaiter)
            _ = try socket.connect(to: "127.0.0.1", port: 4445)
            _ = try socket.read(to: &response)
            XCTAssertEqual(awaiter.event, .read)
        } catch {
            XCTFail(String(describing: error))
        }
    }
}
