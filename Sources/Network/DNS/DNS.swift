import Time
import Platform

struct DNS {
    static var cache = [String : [IPAddress]]()

    static var nameservers: [String] = [
        "208.67.220.220",
        "208.67.222.222"
    ]

    // TODO: round-robin? till failure?
    static var nameserver: String {
        return nameservers.first!
    }

    static func makeRequest(
        query: Message,
        deadline: Time = .distantFuture
    ) throws -> Message {
        let server = try! Socket.Address(nameserver, port: 53)
        let socket = try Socket(type: .datagram)

        _ = try socket.send(bytes: query.bytes, to: server)
        var buffer = [UInt8](repeating: 0, count: 1024)
        let count = try socket.receive(to: &buffer)
        let response = [UInt8](buffer.prefix(upTo: count))

        return try Message(from: response)
    }

    public static func resolve(
        domain: String,
        type: ResourceType = .a,
        deadline: Time = .distantFuture
    ) throws -> [IPAddress] {
        // TODO: separate by resource type
        guard cache[domain] == nil else {
            return cache[domain]!
        }

        let response = try makeRequest(
            query: Message(domain: domain, type: type),
            deadline: deadline)

        let result = response.answer.reduce([IPAddress]()) { result, next in
            var result = result
            if case let .a(address) = next.data {
                result.append(.v4(address))
            } else if case let .aaaa(address) = next.data {
                result.append(.v6(address))
            }
            return result
        }

        cache[domain] = result
        return result
    }
}
