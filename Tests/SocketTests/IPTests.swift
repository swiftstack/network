@testable import Socket

class IPTests: TestCase {
    func testIPv4() {
        let ip4 = IPv4(127,0,0,1)
        assertNotNil(ip4)
    }

    func testIPv6() {
        let ip6 = IPv6(0,0,0,0,0,0,0,1)
        assertNotNil(ip6)
    }
}
