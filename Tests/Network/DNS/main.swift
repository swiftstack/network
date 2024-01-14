import Test
import Event

@testable import Network

test("MakeRequest") {
    Task {
        let query = Message(domain: "example.com", type: .a)
        let response = try await DNS.makeRequest(query: query)

        expect(response.answer.count == 1)

        for answer in response.answer {
            expect(answer.name == "example.com")
            expect(answer.ttl > 0)
            expect(answer.data == .a(.init(93,184,216,34)))
        }

        expect(response.authority == [])
        expect(response.additional == [])
    
        await loop.terminate()
    }

    await loop.run()
}

test("Resolve") {
    Task {
        let addresses = try await DNS.resolve(domain: "example.com")
        expect(addresses.count == 1)
        expect(addresses.first == .v4(.init(93,184,216,34)))
    
        await loop.terminate()
    }

    await loop.run()
}

await run()
