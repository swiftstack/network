import Test
@testable import Network

class DNSMessageTests: TestCase {
    func testRequest() throws {
        let bytes: [UInt8] = [0xee, 0xf7, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00,
                              0x00, 0x00, 0x00, 0x00, 0x0a, 0x64, 0x75, 0x63,
                              0x6b, 0x64, 0x75, 0x63, 0x6b, 0x67, 0x6f, 0x03,
                              0x63, 0x6f, 0x6d, 0x00, 0x00, 0x01, 0x00, 0x01]

        let message = try Message(from: bytes)
        expect(message.id == 0xeef7)
        expect(message.type == .query)
        expect(message.kind == .query)
        expect(!message.isTruncated)
        expect(!message.isAuthoritative)
        expect(message.isRecursionDesired)
        expect(!message.isRecursionAvailable)
        expect(message.responseCode == .noError)

        let question = Question(name: "duckduckgo.com", type: .a)
        expect(message.question == [question])
        expect(message.answer == [ResourceRecord]())
        expect(message.authority == [ResourceRecord]())
        expect(message.additional == [ResourceRecord]())

        expect(message.bytes == bytes)
    }

    func testResponse() throws {
        let bytes: [UInt8] = [0xee, 0xf7, 0x81, 0x80, 0x00, 0x01, 0x00, 0x06,
                              0x00, 0x05, 0x00, 0x00, 0x0a, 0x64, 0x75, 0x63,
                              0x6b, 0x64, 0x75, 0x63, 0x6b, 0x67, 0x6f, 0x03,
                              0x63, 0x6f, 0x6d, 0x00, 0x00, 0x01, 0x00, 0x01,
                              0xc0, 0x0c, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00,
                              0x00, 0xb4, 0x00, 0x04, 0x2e, 0x33, 0xc5, 0x59,
                              0xc0, 0x0c, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00,
                              0x00, 0xb4, 0x00, 0x04, 0xb0, 0x22, 0x83, 0xe9,
                              0xc0, 0x0c, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00,
                              0x00, 0xb4, 0x00, 0x04, 0x36, 0xe5, 0x69, 0x5c,
                              0xc0, 0x0c, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00,
                              0x00, 0xb4, 0x00, 0x04, 0xb0, 0x22, 0x9b, 0x14,
                              0xc0, 0x0c, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00,
                              0x00, 0xb4, 0x00, 0x04, 0x36, 0xe5, 0x69, 0xcb,
                              0xc0, 0x0c, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00,
                              0x00, 0xb4, 0x00, 0x04, 0xb0, 0x22, 0x87, 0xa7,
                              0xc0, 0x0c, 0x00, 0x02, 0x00, 0x01, 0x00, 0x01,
                              0x51, 0x80, 0x00, 0x12, 0x03, 0x6e, 0x73, 0x32,
                              0x0b, 0x64, 0x6e, 0x73, 0x6d, 0x61, 0x64, 0x65,
                              0x65, 0x61, 0x73, 0x79, 0xc0, 0x17, 0xc0, 0x0c,
                              0x00, 0x02, 0x00, 0x01, 0x00, 0x01, 0x51, 0x80,
                              0x00, 0x06, 0x03, 0x6e, 0x73, 0x30, 0xc0, 0x90,
                              0xc0, 0x0c, 0x00, 0x02, 0x00, 0x01, 0x00, 0x01,
                              0x51, 0x80, 0x00, 0x06, 0x03, 0x6e, 0x73, 0x33,
                              0xc0, 0x90, 0xc0, 0x0c, 0x00, 0x02, 0x00, 0x01,
                              0x00, 0x01, 0x51, 0x80, 0x00, 0x06, 0x03, 0x6e,
                              0x73, 0x34, 0xc0, 0x90, 0xc0, 0x0c, 0x00, 0x02,
                              0x00, 0x01, 0x00, 0x01, 0x51, 0x80, 0x00, 0x06,
                              0x03, 0x6e, 0x73, 0x31, 0xc0, 0x90]

        let message = try Message(from: bytes)
        expect(message.id == 0xeef7)
        expect(message.type == .response)
        expect(message.kind == .query)
        expect(!message.isTruncated)
        expect(!message.isAuthoritative)
        expect(message.isRecursionDesired)
        expect(message.isRecursionAvailable)
        expect(message.responseCode == .noError)

        expect(message.question == [
            Question(name: "duckduckgo.com", type: .a)
        ])
        expect(message.answer == [
            ResourceRecord(
                name: "duckduckgo.com",
                ttl: 180,
                data: .a(IPv4(46,51,197,89))
            ),
            ResourceRecord(
                name: "duckduckgo.com",
                ttl: 180,
                data: .a(IPv4(176,34,131,233))
            ),
            ResourceRecord(
                name: "duckduckgo.com",
                ttl: 180,
                data: .a(IPv4(54,229,105,92))
            ),
            ResourceRecord(
                name: "duckduckgo.com",
                ttl: 180,
                data: .a(IPv4(176,34,155,20))
            ),
            ResourceRecord(
                name: "duckduckgo.com",
                ttl: 180,
                data: .a(IPv4(54,229,105,203))
            ),
            ResourceRecord(
                name: "duckduckgo.com",
                ttl: 180,
                data: .a(IPv4(176,34,135,167))
            )
        ])
        expect(message.authority == [
            ResourceRecord(
                name: "duckduckgo.com",
                ttl: 86400,
                data: .ns("ns2.dnsmadeeasy.com")
            ),
            ResourceRecord(
                name: "duckduckgo.com",
                ttl: 86400,
                data: .ns("ns0.dnsmadeeasy.com")
            ),
            ResourceRecord(
                name: "duckduckgo.com",
                ttl: 86400,
                data: .ns("ns3.dnsmadeeasy.com")
            ),
            ResourceRecord(
                name: "duckduckgo.com",
                ttl: 86400,
                data: .ns("ns4.dnsmadeeasy.com")
            ),
            ResourceRecord(
                name: "duckduckgo.com",
                ttl: 86400,
                data: .ns("ns1.dnsmadeeasy.com")
            )
        ])
        expect(message.additional == [ResourceRecord]())
    }
}
