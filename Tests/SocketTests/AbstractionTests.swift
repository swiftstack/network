import Platform
@testable import Socket

class AbstractionTests: TestCase {
    func testFamily() {
        assertEqual(Socket.Family.inet.rawValue, AF_INET)
        assertEqual(Socket.Family.inet6.rawValue, AF_INET6)
        assertEqual(Socket.Family.unix.rawValue, AF_UNIX)
        assertEqual(Socket.Family.unspecified.rawValue, AF_UNSPEC)
    }

    func testSocketType() {
        assertEqual(Socket.SocketType.stream.rawValue, SOCK_STREAM)
        assertEqual(Socket.SocketType.datagram.rawValue, SOCK_DGRAM)
    }
}
