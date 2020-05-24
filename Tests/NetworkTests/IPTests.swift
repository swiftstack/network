import Test
@testable import Network

class IPTests: TestCase {
    func testIPv4() {
        let ip4 = IPv4(127,0,0,1)
        expect(ip4.description == "127.0.0.1")
    }

    func testIPv6() {
        let ip6 = IPv6(0,0,0,0,0,0,0,1)
        expect(ip6.description == "::1")
    }

    func testIPAddress() {
        let _: IPAddress = .v4(IPv4(127,0,0,1))
        let _: IPAddress = .v6(IPv6(0,0,0,0,0,0,0,1))
    }
}
