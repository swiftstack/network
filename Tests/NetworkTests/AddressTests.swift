import Test
import Fiber
import Platform
import Dispatch

@testable import Async
@testable import Network

class AddressTests: TestCase {
    override func setUp() {
        async.setUp(Fiber.self)
    }

    func testIPv4() {
        scope {
            let address = try Socket.Address(ip4: "127.0.0.1", port: 5000)

            var sockaddr = sockaddr_in()
            inet_pton(AF_INET, "127.0.0.1", &sockaddr.sin_addr)
        #if os(macOS)
            sockaddr.sin_len = sa_family_t(sockaddr_in.size)
        #endif
            sockaddr.sin_family = sa_family_t(AF_INET)
            sockaddr.sin_port = UInt16(5000).byteSwapped


            assertEqual(address, Socket.Address.ip4(sockaddr))
            assertEqual(address.size, socklen_t(MemoryLayout<sockaddr_in>.size))
            assertEqual(address.description, "127.0.0.1:5000")
        }
    }

    func testIPv6() {
        scope {
            let address = try Socket.Address(ip6: "::1", port: 5001)

            var sockaddr = sockaddr_in6()
            inet_pton(AF_INET6, "::1", &sockaddr.sin6_addr)
        #if os(macOS)
            sockaddr.sin6_len = sa_family_t(sockaddr_in6.size)
        #endif
            sockaddr.sin6_family = sa_family_t(AF_INET6)
            sockaddr.sin6_port = UInt16(5001).byteSwapped


            assertEqual(address, Socket.Address.ip6(sockaddr))
            assertEqual(address.size, socklen_t(MemoryLayout<sockaddr_in6>.size))
            assertEqual(address.description, "::1:5001")
        }
    }

    func testUnix() {
        scope {
            unlink("/tmp/testunix")
            let address = try Socket.Address(unix: "/tmp/testunix")

            var bytes = [UInt8]("/tmp/testunix".utf8)
            var sockaddr = sockaddr_un()
            let size = MemoryLayout.size(ofValue: sockaddr.sun_path)
            guard bytes.count < size else {
                errno = EINVAL
                throw SocketError()
            }
        #if os(macOS)
            sockaddr.sun_len = sa_family_t(sockaddr_un.size)
        #endif
            sockaddr.family = AF_UNIX
            memcpy(&sockaddr.sun_path, &bytes, bytes.count)

            assertEqual(address, Socket.Address.unix(sockaddr))
            assertEqual(address.size, socklen_t(MemoryLayout<sockaddr_un>.size))
            assertEqual(address.description, "/tmp/testunix")

            assertThrowsError(try Socket.Address(unix: "testunix.com"))
        }
    }

    func testIPv4Detect() {
        scope {
            let address = try Socket.Address(ip4: "127.0.0.1", port: 5002)
            let detected = try Socket.Address("127.0.0.1", port: 5002)

            assertEqual(address, detected)
        }
    }

    func testIPv6Detect() {
        scope {
            let address = try Socket.Address(ip6: "::1", port: 5003)
            let detected = try Socket.Address("::1", port: 5003)

            assertEqual(address, detected)
        }
    }

    func testUnixDetect() {
        scope {
            unlink("/tmp/testunixdetect")
            let address = try Socket.Address(unix: "/tmp/testunixdetect")
            let detected = try Socket.Address("/tmp/testunixdetect")

            assertEqual(address, detected)
        }
    }

    func testIP4DNSResolve() {
        async.task {
            scope {
                let address = try Socket.Address("duckduckgo.com", port: 80)

                guard case .ip4(let sockaddr) = address else {
                    fail("invalid address")
                    return
                }

                let ip = sockaddr.address.description
                assertEqual(ip.split(separator: ".").count, 4)
            }
            async.loop.terminate()
        }
        async.loop.run()
    }

    func testLocalAddress() {
        async.task {
            scope {
                let socket = try Socket()
                    .bind(to: "127.0.0.1", port: 5004)
                    .listen()

                _ = try socket.accept()
            }
        }

        async.task {
            scope {
                let socket = try Socket()
                _ = try socket
                    .bind(to: "127.0.0.1", port: 5005)
                    .connect(to: "127.0.0.1", port: 5004)

                var sockaddr = sockaddr_in()
                inet_pton(AF_INET, "127.0.0.1", &sockaddr.sin_addr)
                sockaddr.sin_port = UInt16(5005).byteSwapped
                sockaddr.sin_family = sa_family_t(AF_INET)
                #if os(macOS)
                sockaddr.sin_len = 16
                #endif

                assertEqual(socket.selfAddress, Socket.Address.ip4(sockaddr))
            }
            async.loop.terminate()
        }

        async.loop.run()
    }

    func testRemoteAddress() {
        async.task {
            scope {
                let socket = try Socket()
                    .bind(to: "127.0.0.1", port: 5006)
                    .listen()

                _ = try socket.accept()
            }
        }

        async.task {
            scope {
                let socket = try Socket()
                _ = try socket
                    .bind(to: "127.0.0.1", port: 5007)
                    .connect(to: "127.0.0.1", port: 5006)

                var sockaddr = sockaddr_in()
                inet_pton(AF_INET, "127.0.0.1", &sockaddr.sin_addr)
                sockaddr.sin_port = UInt16(5006).byteSwapped
                sockaddr.sin_family = sa_family_t(AF_INET)
                #if os(macOS)
                sockaddr.sin_len = 16
                #endif

                assertEqual(socket.peerAddress, Socket.Address.ip4(sockaddr))
            }
            async.loop.terminate()
        }

        async.loop.run()
    }

    func testLocal6Address() {
        async.task {
            scope {
                let socket = try Socket(family: .inet6)
                    .bind(to: "::1", port: 5008)
                    .listen()

                _ = try socket.accept()
            }
        }

        async.task {
            scope {
                let socket = try Socket(family: .inet6)
                _ = try socket
                    .bind(to: "::1", port: 5009)
                    .connect(to: "::1", port: 5008)

                var sockaddr = sockaddr_in6()
                inet_pton(AF_INET6, "::1", &sockaddr.sin6_addr)
                sockaddr.sin6_port = UInt16(5009).byteSwapped
                sockaddr.sin6_family = sa_family_t(AF_INET6)
                #if os(macOS)
                sockaddr.sin6_len = 28
                #endif

                assertEqual(socket.selfAddress, Socket.Address.ip6(sockaddr))
            }
            async.loop.terminate()
        }

        async.loop.run()
    }

    func testRemote6Address() {
        async.task {
            scope {
                let socket = try Socket(family: .inet6)
                    .bind(to: "::1", port: 5010)
                    .listen()

                _ = try socket.accept()
            }
        }

        async.task {
            scope {
                let socket = try Socket(family: .inet6)
                _ = try socket
                    .bind(to: "::1", port: 5011)
                    .connect(to: "::1", port: 5010)

                var sockaddr = sockaddr_in6()
                inet_pton(AF_INET6, "::1", &sockaddr.sin6_addr)
                sockaddr.sin6_port = UInt16(5010).byteSwapped
                sockaddr.sin6_family = sa_family_t(AF_INET6)
                #if os(macOS)
                sockaddr.sin6_len = 28
                #endif

                assertEqual(socket.peerAddress, Socket.Address.ip6(sockaddr))
            }
            async.loop.terminate()
        }

        async.loop.run()
    }
}
