import XCTest
@testable import Socket

class AbstractionTests: XCTestCase {
    func testFamily() {
        XCTAssertEqual(Socket.Family.inet.rawValue, AF_INET)
        XCTAssertEqual(Socket.Family.inet6.rawValue, AF_INET6)
        XCTAssertEqual(Socket.Family.unix.rawValue, AF_UNIX)
        XCTAssertEqual(Socket.Family.unspecified.rawValue, AF_UNSPEC)
    }

    func testSocketType() {
        XCTAssertEqual(Socket.SocketType.stream.rawValue, SOCK_STREAM)
        XCTAssertEqual(Socket.SocketType.datagram.rawValue, SOCK_DGRAM)
    }
}
