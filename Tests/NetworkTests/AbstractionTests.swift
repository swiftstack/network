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
        func rawValue(of type: Socket.`Type`) -> Int32 {
            return type.rawValue
        }
        assertEqual(rawValue(of: .stream), SOCK_STREAM)
        assertEqual(rawValue(of: .datagram), SOCK_DGRAM)
        assertEqual(rawValue(of: .sequenced), SOCK_SEQPACKET)
        assertEqual(rawValue(of: .raw), SOCK_RAW)
    }
}
