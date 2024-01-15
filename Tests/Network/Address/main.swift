import Test
import Event
import Platform

@testable import Network

test("IPv4") {
    let address = try Socket.Address(ip4: "127.0.0.1", port: 4000)

    var sockaddr = sockaddr_in()
    inet_pton(AF_INET, "127.0.0.1", &sockaddr.sin_addr)
#if os(macOS)
    sockaddr.sin_len = sa_family_t(sockaddr_in.size)
#endif
    sockaddr.sin_family = sa_family_t(AF_INET)
    sockaddr.sin_port = UInt16(4000).byteSwapped

    expect(address == Socket.Address.ip4(sockaddr))
    expect(address.size == socklen_t(MemoryLayout<sockaddr_in>.size))
    expect(address.description == "127.0.0.1:4000")
}

test("IPv6") {
    let address = try Socket.Address(ip6: "::1", port: 4001)

    var sockaddr = sockaddr_in6()
    inet_pton(AF_INET6, "::1", &sockaddr.sin6_addr)
#if os(macOS)
    sockaddr.sin6_len = sa_family_t(sockaddr_in6.size)
#endif
    sockaddr.sin6_family = sa_family_t(AF_INET6)
    sockaddr.sin6_port = UInt16(4001).byteSwapped

    expect(address == Socket.Address.ip6(sockaddr))
    expect(address.size == socklen_t(MemoryLayout<sockaddr_in6>.size))
    expect(address.description == "::1:4001")
}

test("Unix") {
    unlink("/tmp/testunix")
    let address = try Socket.Address(unix: "/tmp/testunix")

    var bytes = [UInt8]("/tmp/testunix".utf8)
    var sockaddr = sockaddr_un()
    let size = MemoryLayout.size(ofValue: sockaddr.sun_path)
    guard bytes.count < size else {
        throw Socket.Error.invalidArgument
    }
#if os(macOS)
    sockaddr.sun_len = sa_family_t(sockaddr_un.size)
#endif
    sockaddr.family = AF_UNIX
    memcpy(&sockaddr.sun_path, &bytes, bytes.count)

    expect(address == Socket.Address.unix(sockaddr))
    expect(address.size == socklen_t(MemoryLayout<sockaddr_un>.size))
    expect(address.description == "/tmp/testunix")

    expect(throws: Socket.Error.invalidArgument) {
        _ = try Socket.Address(unix: "testunix.com")
    }
}

test("IPv4Detect") {
    let address = try Socket.Address(ip4: "127.0.0.1", port: 4002)
    let detected = try Socket.Address("127.0.0.1", port: 4002)
    expect(address == detected)
}

test("IPv6Detect") {
    let address = try Socket.Address(ip6: "::1", port: 4003)
    let detected = try Socket.Address("::1", port: 4003)
    expect(address == detected)
}

test("UnixDetect") {
    unlink("/tmp/testunixdetect")
    let address = try Socket.Address(unix: "/tmp/testunixdetect")
    let detected = try Socket.Address("/tmp/testunixdetect")
    expect(address == detected)
}

test("LocalAddress") {
    Task {
        let socket = try TCP.Socket()
            .bind(to: "127.0.0.1", port: 4004)
            .listen()

        _ = try await socket.accept()
    }

    Task {
        let socket = try TCP.Socket()
        _ = try await socket
            .bind(to: "127.0.0.1", port: 4005)
            .connect(to: "127.0.0.1", port: 4004)

        var sockaddr = sockaddr_in()
        inet_pton(AF_INET, "127.0.0.1", &sockaddr.sin_addr)
        sockaddr.sin_port = UInt16(4005).byteSwapped
        sockaddr.sin_family = sa_family_t(AF_INET)
        #if os(macOS)
        sockaddr.sin_len = 16
        #endif

        expect(socket.selfAddress == Socket.Address.ip4(sockaddr))

        await loop.terminate()
    }

    await loop.run()
}

test("RemoteAddress") {
    Task {
        let socket = try TCP.Socket()
            .bind(to: "127.0.0.1", port: 4006)
            .listen()

        _ = try await socket.accept()
    }

    Task {
        let socket = try TCP.Socket()
        _ = try await socket
            .bind(to: "127.0.0.1", port: 4007)
            .connect(to: "127.0.0.1", port: 4006)

        var sockaddr = sockaddr_in()
        inet_pton(AF_INET, "127.0.0.1", &sockaddr.sin_addr)
        sockaddr.sin_port = UInt16(4006).byteSwapped
        sockaddr.sin_family = sa_family_t(AF_INET)
        #if os(macOS)
        sockaddr.sin_len = 16
        #endif

        expect(socket.peerAddress == Socket.Address.ip4(sockaddr))

        await loop.terminate()
    }

    await loop.run()
}

test("Local6Address") {
    Task {
        let socket = try TCP.Socket(family: .inet6)
            .bind(to: "::1", port: 4008)
            .listen()

        _ = try await socket.accept()
    }

    Task {
        let socket = try TCP.Socket(family: .inet6)
        _ = try await socket
            .bind(to: "::1", port: 4009)
            .connect(to: "::1", port: 4008)

        var sockaddr = sockaddr_in6()
        inet_pton(AF_INET6, "::1", &sockaddr.sin6_addr)
        sockaddr.sin6_port = UInt16(4009).byteSwapped
        sockaddr.sin6_family = sa_family_t(AF_INET6)
        #if os(macOS)
        sockaddr.sin6_len = 28
        #endif

        expect(socket.selfAddress == Socket.Address.ip6(sockaddr))

        await loop.terminate()
    }

    await loop.run()
}

test("Remote6Address") {
    Task {
        let socket = try TCP.Socket(family: .inet6)
            .bind(to: "::1", port: 4010)
            .listen()

        _ = try await socket.accept()
    }

    Task {
        let socket = try TCP.Socket(family: .inet6)
        _ = try await socket
            .bind(to: "::1", port: 4011)
            .connect(to: "::1", port: 4010)

        var sockaddr = sockaddr_in6()
        inet_pton(AF_INET6, "::1", &sockaddr.sin6_addr)
        sockaddr.sin6_port = UInt16(4010).byteSwapped
        sockaddr.sin6_family = sa_family_t(AF_INET6)
        #if os(macOS)
        sockaddr.sin6_len = 28
        #endif

        expect(socket.peerAddress == Socket.Address.ip6(sockaddr))

        await loop.terminate()
    }

    await loop.run()
}

await run()
