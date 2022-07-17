import Platform

struct DNS {
    static var cache = [String : [IPAddress]]()

    static var nameservers: [String] = ["1.1.1.1"]

    static func makeRequest(
        query: Message,
        deadline: Instant? = nil
    ) async throws -> Message {
        let server = try! Socket.Address(nameservers.first!, port: 53)
        let socket = try UDP.Socket()

        _ = try await socket.send(bytes: query.bytes, to: server)
        let result = try await socket.receive(maxLength: 1024)

        return try Message(from: result.bytes)
    }

    public static func resolve(
        domain: String,
        type: ResourceType = .a,
        deadline: Instant? = nil
    ) async throws -> [IPAddress] {
        // TODO: separate by resource type
        guard cache[domain] == nil else {
            return cache[domain]!
        }

        let response = try await makeRequest(
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
