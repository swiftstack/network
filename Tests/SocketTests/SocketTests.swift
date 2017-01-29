import XCTest
import Dispatch
@testable import Socket

class SocketTests: XCTestCase {
    func testSocket() {
        let message = [UInt8]("Hey there!".utf8)

        DispatchQueue.global(qos: .background).async {
            do { // echo server
                let socket = try Socket()
                let client = try socket.listen(at: "127.0.0.1", port: 4444).accept()
                var buffer = [UInt8](repeating: 0, count: message.count)
                let read = try client.read(to: &buffer)
                _ = try client.write(bytes: buffer, count: read)
            } catch {
                XCTFail(String(describing: error))
            }
        }

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
