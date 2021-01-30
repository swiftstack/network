import Test
import Event

@testable import Network

test.case("MakeRequest") {
    asyncTask {
        await scope {
            let query = Message(domain: "swiftstack.io", type: .a)
            let response = try await DNS.makeRequest(query: query)

            expect(response.answer.count == 1)

            for answer in response.answer {
                expect(answer.name == "swiftstack.io")
                expect(answer.ttl > 0)
                expect(answer.data == .a(.init(116,203,222,133)))
            }

            expect(response.authority == [])
            expect(response.additional == [])

            await loop.terminate()
        }
    }
    await loop.run()
}

test.case("Resolve") {
    asyncTask {
        await scope {
            let addresses = try await DNS.resolve(domain: "swiftstack.io")
            expect(addresses.count == 1)
            expect(addresses.first == .v4(.init(116,203,222,133)))

            await loop.terminate()
        }
    }
    await loop.run()
}

//test.case("Socket.Address") {
//    let address = try Socket.Address("swiftstack.io", port: 80)
//
//    guard case .ip4(let sockaddr) = address else {
//        fail("invalid address")
//        return
//    }
//
//    let ip = sockaddr.address.description
//    expect(ip.split(separator: ".").count == 4)
//}

test.run()
