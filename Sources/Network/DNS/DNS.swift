import Platform
import Foundation

struct DNS {
    static var cache = [String : [IPAddress]]()

    static var nameserver: String = {
        // FIXME: implement async reader
        let fileManager = FileManager.default
        guard fileManager.isReadableFile(atPath: "/etc/resolv.conf") else {
            fatalError("/etc/resolv.conf not found")
        }

        guard let nameserver = String(
                data: fileManager.contents(atPath: "/etc/resolv.conf")!,
                encoding: .utf8)!
            .components(separatedBy: .newlines)
            .first(where: { $0.hasPrefix("nameserver") }) else {
                fatalError("nameserver not found")
        }

        guard let address = nameserver.components(separatedBy: .whitespaces)
            .last else {
                fatalError("invalid nameserver record")
        }
        return address
    }()

    static func makeRequest(
        query: Message,
        deadline: Date = Date.distantFuture
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
        deadline: Date = Date.distantFuture
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
