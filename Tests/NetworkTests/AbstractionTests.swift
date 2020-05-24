import Test
import Platform
@testable import Network

class AbstractionTests: TestCase {
    func testFamily() {
        expect(Socket.Family.local.rawValue == PF_LOCAL)
        expect(Socket.Family.inet.rawValue == PF_INET)
        expect(Socket.Family.inet6.rawValue == PF_INET6)
    }

    func testSocketType() {
        func rawValue(of type: Socket.`Type`) -> Int32 {
            return type.rawValue
        }
        expect(rawValue(of: .stream) == SOCK_STREAM)
        expect(rawValue(of: .datagram) == SOCK_DGRAM)
        expect(rawValue(of: .sequenced) == SOCK_SEQPACKET)
        expect(rawValue(of: .raw) == SOCK_RAW)
    }
}
