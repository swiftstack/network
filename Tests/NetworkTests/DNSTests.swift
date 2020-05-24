import Test
import Fiber

@testable import Async
@testable import Network

class DNSTests: TestCase {
    override func setUp() {
        async.setUp(Fiber.self)
    }

    func testMakeRequest() {
        async.task {
            scope {
                let query = Message(domain: "duckduckgo.com", type: .a)
                let response = try DNS.makeRequest(query: query)

                for answer in response.answer {
                    expect(answer.name == "duckduckgo.com")
                    expect(answer.ttl > 0)
                    switch answer.data {
                    case .a(_): break
                    default: fail()
                    }
                }

                let nsServers: [ResourceData] = [
                    .ns("ns0.dnsmadeeasy.com"),
                    .ns("ns1.dnsmadeeasy.com"),
                    .ns("ns2.dnsmadeeasy.com"),
                    .ns("ns3.dnsmadeeasy.com"),
                    .ns("ns4.dnsmadeeasy.com")
                ]

                for answer in response.authority {
                    expect(answer.name == "duckduckgo.com")
                    expect(answer.ttl > 0)
                    expect(nsServers.contains(answer.data))
                }
            }
        }
        async.loop.run()
    }

    func testResolve() {
        async.task {
            scope {
                let response = try DNS.resolve(domain: "duckduckgo.com")
                for address in response {
                    switch address {
                    case .v4(_): break
                    default: fail()
                    }
                }
            }
        }
        async.loop.run()
    }

    func testPerformance() {
        let query = Message(domain: "duckduckgo.com", type: .a)

        async.task {
            self.measure {
                _ = try? DNS.makeRequest(query: query)
            }
        }
        async.loop.run()
    }
}
