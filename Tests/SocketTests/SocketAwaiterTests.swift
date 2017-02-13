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

    func testSocketAwaiterAccept() {
        let ready = AtomicCondition()

        DispatchQueue.global().async {
            do {
                let awaiter = TestAwaiter()
                let socket = try Socket(awaiter: awaiter)
                    .bind(to: "127.0.0.1", port: 4001)
                    .listen()

                ready.signal()

                _ = try socket.accept()
                XCTAssertEqual(awaiter.event, .read)
            } catch {
                XCTFail(String(describing: error))
            }
        }

        ready.wait()

        do {
            _ = try Socket().connect(to: "127.0.0.1", port: 4001)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSocketAwaiterWrite() {
        let ready = AtomicCondition()
        DispatchQueue.global().async {
            do {
                let socket = try Socket()
                    .configure(reusePort: true)
                    .bind(to: "127.0.0.1", port: 4002)
                    .listen()

                ready.signal()

                let client = try socket.accept()
                _ = try client.send(bytes: self.message)
            } catch {
                XCTFail(String(describing: error))
            }
        }

        ready.wait()

        do {
            let awaiter = TestAwaiter()
            let socket = try Socket(awaiter: awaiter)
                .connect(to: "127.0.0.1", port: 4002)

            _ = try socket.send(bytes: message)
            XCTAssertEqual(awaiter.event, .write)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSocketAwaiterRead() {
        let ready = AtomicCondition()

        DispatchQueue.global().async {
            do {
                let awaiter = TestAwaiter()
                let socket = try Socket(awaiter: awaiter)
                    .bind(to: "127.0.0.1", port: 4003)
                    .listen()

                ready.signal()

                _ = try socket.accept()
                XCTAssertEqual(awaiter.event, .read)
            } catch {
                XCTFail(String(describing: error))
            }
        }

        ready.wait()

        var response = [UInt8](repeating: 0, count: message.count)
        do {
            let awaiter = TestAwaiter()
            let socket = try Socket(awaiter: awaiter)
                .connect(to: "127.0.0.1", port: 4003)

            _ = try socket.receive(to: &response)
            XCTAssertEqual(awaiter.event, .read)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSocketAwaiterWriteTo() {
        let ready = AtomicCondition()
        let done = AtomicCondition()

        let server = try! Socket.Address("127.0.0.1", port: 4004)

        DispatchQueue.global().async {
            do {
                let awaiter = TestAwaiter()
                _ = try Socket(type: .datagram, awaiter: awaiter)
                    .bind(to: server)

                ready.signal()

                done.wait()
            } catch {
                XCTFail(String(describing: error))
            }
        }

        ready.wait()

        do {
            let awaiter = TestAwaiter()
            let socket = try Socket(type: .datagram, awaiter: awaiter)

            _ = try socket.send(bytes: message, to: server)
            XCTAssertEqual(awaiter.event, .write)
            done.signal()
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSocketAwaiterReadFrom() {
        let ready = AtomicCondition()
        let done = AtomicCondition()

        let server = try! Socket.Address("127.0.0.1", port: 4005)
        let client = try! Socket.Address("127.0.0.1", port: 4006)

        DispatchQueue.global().async {
            do {
                let awaiter = TestAwaiter()
                let socket = try Socket(type: .datagram, awaiter: awaiter)
                    .bind(to: server)

                ready.wait()

                _ = try socket.send(bytes: self.message, to: client)
                done.wait()
            } catch {
                XCTFail(String(describing: error))
            }
        }

        var response = [UInt8](repeating: 0, count: message.count)
        do {
            let awaiter = TestAwaiter()
            let socket = try Socket(type: .datagram, awaiter: awaiter)
                .bind(to: client)

            ready.signal()

            _ = try socket.receive(to: &response, from: server)
            XCTAssertEqual(awaiter.event, .read)
            done.signal()
        } catch {
            XCTFail(String(describing: error))
        }
    }
}
