import Test
@testable import Network

test.case("IPv4") {
    let ip4 = IPv4(127,0,0,1)
    expect(ip4.description == "127.0.0.1")
}

test.case("IPv6") {
    let ip6 = IPv6(0,0,0,0,0,0,0,1)
    expect(ip6.description == "::1")
}

test.case("IPAddress") {
    let _: IPAddress = .v4(IPv4(127,0,0,1))
    let _: IPAddress = .v6(IPv6(0,0,0,0,0,0,0,1))
}

await test.run()
