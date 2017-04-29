import Dispatch
@testable import Network
import struct Foundation.Date

class DNSTests: TestCase {
    func testMakeRequest() {
        do {
            let query = Message(resolve: "duckduckgo.com", type: .a)
            let response = try DNS.makeRequest(query: query)

            let addresses: [ResourceData] = [
                .a(IPv4(176,34,155,20)),
                .a(IPv4(46,51,197,89)),
                .a(IPv4(176,34,135,167)),
                .a(IPv4(54,229,105,92)),
                .a(IPv4(176,34,131,233)),
                .a(IPv4(54,229,105,203))
            ]

            for answer in response.answer {
                assertEqual(answer.name, "duckduckgo.com")
                assertTrue(answer.ttl > 0)
                assertTrue(addresses.contains(answer.data))
            }

            let nsServers: [ResourceData] = [
                .ns("ns0.dnsmadeeasy.com"),
                .ns("ns1.dnsmadeeasy.com"),
                .ns("ns2.dnsmadeeasy.com"),
                .ns("ns3.dnsmadeeasy.com"),
                .ns("ns4.dnsmadeeasy.com")
            ]

            for answer in response.authority {
                assertEqual(answer.name, "duckduckgo.com")
                assertTrue(answer.ttl > 0)
                assertTrue(nsServers.contains(answer.data))
            }
        } catch {
            fail(String(describing: error))
        }
    }

    func testResolve() {
        do {
            let response = try DNS.resolve(domain: "duckduckgo.com")

            let addresses: [IPAddress] = [
                .v4(IPv4(176,34,155,20)),
                .v4(IPv4(46,51,197,89)),
                .v4(IPv4(176,34,135,167)),
                .v4(IPv4(54,229,105,92)),
                .v4(IPv4(176,34,131,233)),
                .v4(IPv4(54,229,105,203))
            ]

            for address in response {
                assertTrue(addresses.contains(address))
            }
        } catch {
            fail(String(describing: error))
        }
    }

    func testPerformance() {
        let query = Message(resolve: "duckduckgo.com", type: .a)

        measure {
            do {
                _ = try DNS.makeRequest(query: query)
            } catch {
                fail(String(describing: error))
            }
        }
    }
}
