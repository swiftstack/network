import Test
@testable import Network

class IPTests: TestCase {
    func testIPv4() {
        let ip4 = IPv4(127,0,0,1)
        assertNotNil(ip4)
        assertEqual(ip4.description, "127.0.0.1")
    }

    func testIPv6() {
        let ip6 = IPv6(0,0,0,0,0,0,0,1)
        assertNotNil(ip6)
        assertEqual(ip6.description, "::1")
    }

    func testIPAddress() {
        var address: IPAddress
        address = .v4(IPv4(127,0,0,1))
        address = .v6(IPv6(0,0,0,0,0,0,0,1))
        assertNotNil(address)
        switch address {
        case .v4(let ip4): assertTrue(type(of: ip4) == IPv4.self)
        case .v6(let ip6): assertTrue(type(of: ip6) == IPv6.self)
        }
    }
}
