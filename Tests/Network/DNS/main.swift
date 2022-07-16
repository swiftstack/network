import Test
import Event

@testable import Network

test.case("MakeRequest") {
    asyncTask {
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
    } deinit: {
        await loop.terminate()
    }

    await loop.run()
}

test.case("Resolve") {
    asyncTask {
        let addresses = try await DNS.resolve(domain: "example.com")
        expect(addresses.count == 1)
        expect(addresses.first == .v4(.init(93,184,216,34)))
    } deinit: {
        await loop.terminate()
    }

    await loop.run()
}

await test.run()
