import Test
import Platform
@testable import Network

class AbstractionTests: TestCase {
    func testFamily() {
        assertEqual(Socket.Family.local.rawValue, PF_LOCAL)
        assertEqual(Socket.Family.inet.rawValue, PF_INET)
        assertEqual(Socket.Family.inet6.rawValue, PF_INET6)
    }

    func testSocketType() {
        assertEqual(Socket.SocketType.stream.rawValue, SOCK_STREAM)
        assertEqual(Socket.SocketType.datagram.rawValue, SOCK_DGRAM)
        assertEqual(Socket.SocketType.sequenced.rawValue, SOCK_SEQPACKET)
        assertEqual(Socket.SocketType.raw.rawValue, SOCK_RAW)
    }
}
