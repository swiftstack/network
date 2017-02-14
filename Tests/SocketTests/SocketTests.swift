import XCTest
import Dispatch
@testable import Socket

class SocketTests: XCTestCase {
    func testSocket() {
        let ready = AtomicCondition()
        let message = [UInt8]("ping".utf8)

        DispatchQueue.global().async {
            do {
                let socket = try Socket()
                    .bind(to: "127.0.0.1", port: 3000)
                    .listen()

                ready.signal()

                let client = try socket.accept()
                var buffer = [UInt8](repeating: 0, count: message.count)
                _ = try client.receive(to: &buffer)
                _ = try client.send(bytes: buffer)
            } catch {
                XCTFail(String(describing: error))
            }
        }

        ready.wait()

        do {
            let socket = try Socket()
                .connect(to: "127.0.0.1", port: 3000)

            let written = try socket.send(bytes: message)
            XCTAssertEqual(written, message.count)

            var response = [UInt8](repeating: 0, count: message.count)
            let read = try socket.receive(to: &response)
            XCTAssertEqual(read, message.count)
            XCTAssertEqual(response, message)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSocketInetStream() {
        let ready = AtomicCondition()
        let message = [UInt8]("ping".utf8)

        DispatchQueue.global().async {
            do {
                let socket = try Socket(family: .inet, type: .stream)
                    .bind(to: "127.0.0.1", port: 3001)
                    .listen()

                ready.signal()

                let client = try socket.accept()
                var buffer = [UInt8](repeating: 0, count: message.count)
                _ = try client.receive(to: &buffer)
                _ = try client.send(bytes: buffer)
            } catch {
                XCTFail(String(describing: error))
            }
        }

        ready.wait()

        do {
            let socket = try Socket(family: .inet, type: .stream)
                .connect(to: "127.0.0.1", port: 3001)

            let written = try socket.send(bytes: message)
            XCTAssertEqual(written, message.count)

            var response = [UInt8](repeating: 0, count: message.count)
            let read = try socket.receive(to: &response)
            XCTAssertEqual(read, message.count)
            XCTAssertEqual(response, message)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSocketInetDatagram() {
        let ready = AtomicCondition()
        let message = [UInt8]("ping".utf8)

        let server = try! Socket.Address("127.0.0.1", port: 3002)

        DispatchQueue.global().async {
            do {
                let socket = try Socket(family: .inet, type: .datagram)
                    .bind(to: server)

                ready.signal()

                var buffer = [UInt8](repeating: 0, count: message.count)
                var client: Socket.Address? = nil
                _ = try socket.receive(to: &buffer, from: &client)
                _ = try socket.send(bytes: message, to: client!)
            } catch {
                XCTFail(String(describing: error))
            }
        }

        ready.wait()

        do {
            let socket = try Socket(family: .inet, type: .datagram)

            let written = try socket.send(bytes: message, to: server)
            XCTAssertEqual(written, message.count)

            var sender: Socket.Address? = nil
            var buffer = [UInt8](repeating: 0, count: message.count)
            let read = try socket.receive(to: &buffer, from: &sender)
            XCTAssertEqual(sender, server)
            XCTAssertEqual(read, message.count)
            XCTAssertEqual(buffer, message)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSocketInet6Stream() {
        let ready = AtomicCondition()
        let message = [UInt8]("ping".utf8)

        DispatchQueue.global().async {
            do {
                let socket = try Socket(family: .inet6, type: .stream)
                    .bind(to: "::1", port: 3003)
                    .listen()

                ready.signal()

                let client = try socket.accept()
                var buffer = [UInt8](repeating: 0, count: message.count)
                _ = try client.receive(to: &buffer)
                _ = try client.send(bytes: buffer)
            } catch {
                XCTFail(String(describing: error))
            }
        }

        ready.wait()

        do {
            let socket = try Socket(family: .inet6, type: .stream)
                .connect(to: "::1", port: 3003)

            let written = try socket.send(bytes: message)
            XCTAssertEqual(written, message.count)

            var response = [UInt8](repeating: 0, count: message.count)
            let read = try socket.receive(to: &response)
            XCTAssertEqual(read, message.count)
            XCTAssertEqual(response, message)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSocketInet6Datagram() {
        let ready = AtomicCondition()
        let message = [UInt8]("ping".utf8)

        let server = try! Socket.Address("::1", port: 3004)

        DispatchQueue.global().async {
            do {
                let socket = try Socket(family: .inet6, type: .datagram)
                    .bind(to: server)

                ready.signal()

                var buffer = [UInt8](repeating: 0, count: message.count)
                _ = try socket.receive(to: &buffer, from: &client)
                _ = try socket.send(bytes: message, to: client!)
            } catch {
                XCTFail(String(describing: error))
            }
        }

        ready.wait()

        do {
            let socket = try Socket(family: .inet6, type: .datagram)

            let written = try socket.send(bytes: message, to: server)
            XCTAssertEqual(written, message.count)

            var sender: Socket.Address? = nil
            var buffer = [UInt8](repeating: 0, count: message.count)
            let read = try socket.receive(to: &buffer, from: &sender)
            XCTAssertEqual(sender, server)
            XCTAssertEqual(read, message.count)
            XCTAssertEqual(buffer, message)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSocketUnixStream() {
        let ready = AtomicCondition()
        let message = [UInt8]("ping".utf8)

        unlink("/tmp/teststream.sock")
        DispatchQueue.global().async {
            do {
                let socket = try Socket(family: .unix, type: .stream)
                    .bind(to: "/tmp/teststream.sock")
                    .listen()

                ready.signal()

                let client = try socket.accept()
                var buffer = [UInt8](repeating: 0, count: message.count)
                _ = try client.receive(to: &buffer)
                _ = try client.send(bytes: buffer)
            } catch {
                XCTFail(String(describing: error))
            }
        }

        ready.wait()

        do {
            let socket = try Socket(family: .unix, type: .stream)
                .connect(to: "/tmp/teststream.sock")

            let written = try socket.send(bytes: message)
            XCTAssertEqual(written, message.count)

            var response = [UInt8](repeating: 0, count: message.count)
            let read = try socket.receive(to: &response)
            XCTAssertEqual(read, message.count)
            XCTAssertEqual(response, message)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSocketUnixDatagram() {
        let ready = AtomicCondition()
        let message = [UInt8]("ping".utf8)

        unlink("/tmp/testdatagramserver.sock")
        unlink("/tmp/testdatagramclient.sock")
        let server = try! Socket.Address("/tmp/testdatagramserver.sock")
        let client = try! Socket.Address("/tmp/testdatagramclient.sock")

        DispatchQueue.global().async {
            do {
                let socket = try Socket(family: .unix, type: .datagram)
                    .bind(to: server)

                ready.signal()

                var client: Socket.Address? = nil
                var buffer = [UInt8](repeating: 0, count: message.count)
                _ = try socket.receive(to: &buffer, from: &client)
                _ = try socket.send(bytes: message, to: client!)
            } catch {
                XCTFail(String(describing: error))
            }
        }

        ready.wait()

        do {
            let socket = try Socket(family: .unix, type: .datagram)
                .bind(to: client)

            let written = try socket.send(bytes: message, to: server)
            XCTAssertEqual(written, message.count)

            var sender: Socket.Address? = nil
            var buffer = [UInt8](repeating: 0, count: message.count)
            let read = try socket.receive(to: &buffer, from: &sender)
            XCTAssertEqual(sender, server)
            XCTAssertEqual(read, message.count)
            XCTAssertEqual(buffer, message)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSocketUnixSequenced() {
    #if os(Linux)
        let ready = AtomicCondition()
        let message = [UInt8]("ping".utf8)

        unlink("/tmp/testsequenced.sock")
        DispatchQueue.global().async {
            do {
                let socket = try Socket(family: .unix, type: .sequenced)
                    .bind(to: "/tmp/testsequenced.sock")
                    .listen()

                ready.signal()

                let client = try socket.accept()
                var buffer = [UInt8](repeating: 0, count: message.count)
                _ = try client.receive(to: &buffer)
                _ = try client.send(bytes: buffer)
            } catch {
                XCTFail(String(describing: error))
            }
        }

        ready.wait()

        do {
            let socket = try Socket(family: .unix, type: .sequenced)
                .connect(to: "/tmp/testsequenced.sock")

            let written = try socket.send(bytes: message)
            XCTAssertEqual(written, message.count)

            var response = [UInt8](repeating: 0, count: message.count)
            let read = try socket.receive(to: &response)
            XCTAssertEqual(read, message.count)
            XCTAssertEqual(response, message)
        } catch {
            XCTFail(String(describing: error))
        }
    #endif
    }
}
