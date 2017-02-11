import XCTest
import Platform
import Dispatch
@testable import Socket

class SocketTests: XCTestCase {
    func testSocket() {
        let condition = AtomicCondition()
        let message = [UInt8]("Hey there!".utf8)

        DispatchQueue.global().async {
            do {
                let socket = try Socket()
                try socket.listen(at: "127.0.0.1", port: 4444)
                condition.signal()
                let client = try socket.accept()
                var buffer = [UInt8](repeating: 0, count: message.count)
                let read = try client.read(to: &buffer)
                _ = try client.write(bytes: buffer, count: read)
            } catch {
                XCTFail(String(describing: error))
            }
        }

        condition.wait()

        do {
            let socket = try Socket()
            _ = try socket.connect(to: "127.0.0.1", port: 4444)
            let written = try socket.write(bytes: message)
            XCTAssertEqual(written, message.count)
            var response = [UInt8](repeating: 0, count: message.count)
            let read = try socket.read(to: &response)
            XCTAssertEqual(read, message.count)
            XCTAssertEqual(response, message)
        } catch {
            XCTFail(String(describing: error))
        }
    }
}
