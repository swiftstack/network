import Test
import Platform
import Dispatch
import AsyncDispatch
@testable import Network

class AddressTests: TestCase {
    override func setUp() {
        AsyncDispatch().registerGlobal()
    }

    func testIPv4() {
        do {
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
        } catch {
            fail(String(describing: error))
        }
    }

    func testIPv6() {
        do {
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
        } catch {
            fail(String(describing: error))
        }
    }

    func testUnix() {
        do {
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

            assertThrowsError(try Socket.Address(unix: "testunix.com"))
        } catch {
            fail(String(describing: error))
        }
    }

    func testIPv4Detect() {
        do {
            let address = try Socket.Address(ip4: "127.0.0.1", port: 5002)
            let detected = try Socket.Address("127.0.0.1", port: 5002)

            assertEqual(address, detected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testIPv6Detect() {
        do {
            let address = try Socket.Address(ip6: "::1", port: 5003)
            let detected = try Socket.Address("::1", port: 5003)

            assertEqual(address, detected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testUnixDetect() {
        do {
            unlink("/tmp/testunixdetect")
            let address = try Socket.Address(unix: "/tmp/testunixdetect")
            let detected = try Socket.Address("/tmp/testunixdetect")

            assertEqual(address, detected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testIP4DNSResolve() {
        do {
            let address = try Socket.Address("duckduckgo.com", port: 80)

            guard case .ip4(let sockaddr) = address else {
                fail("invalid address")
                return
            }

            let knownAddresses = [
                "176.34.155.20",
                "46.51.197.89",
                "176.34.135.167",
                "54.229.105.92",
                "176.34.131.233",
                "54.229.105.203"
            ]

            assertTrue(knownAddresses.contains(sockaddr.address))
        } catch {
            fail(String(describing: error))
        }
    }

    func testLocalAddress() {
        let ready = DispatchSemaphore(value: 0)
        let done = DispatchSemaphore(value: 0)

        DispatchQueue.global().async {
            do {
                let socket = try Socket()
                    .bind(to: "127.0.0.1", port: 5004)
                    .listen()

                ready.signal()

                _ = try socket.accept()
                done.wait()
            } catch {
                fail(String(describing: error))
            }
        }

        ready.wait()

        do {
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

            done.signal()
        } catch {
            fail(String(describing: error))
        }
    }

    func testRemoteAddress() {
        let ready = DispatchSemaphore(value: 0)
        let done = DispatchSemaphore(value: 0)

        DispatchQueue.global().async {
            do {
                let socket = try Socket()
                    .bind(to: "127.0.0.1", port: 5006)
                    .listen()

                ready.signal()

                _ = try socket.accept()
                done.wait()
            } catch {
                fail(String(describing: error))
            }
        }

        ready.wait()

        do {
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
            done.signal()
        } catch {
            fail(String(describing: error))
        }
    }

    func testLocal6Address() {
        let ready = DispatchSemaphore(value: 0)
        let done = DispatchSemaphore(value: 0)

        DispatchQueue.global().async {
            do {
                let socket = try Socket(family: .inet6)
                    .bind(to: "::1", port: 5008)
                    .listen()

                ready.signal()

                _ = try socket.accept()
                done.wait()
            } catch {
                fail(String(describing: error))
            }
        }

        ready.wait()

        do {
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
            done.signal()
        } catch {
            fail(String(describing: error))
        }
    }

    func testRemote6Address() {
        let ready = DispatchSemaphore(value: 0)
        let done = DispatchSemaphore(value: 0)

        DispatchQueue.global().async {
            do {
                let socket = try Socket(family: .inet6)
                    .bind(to: "::1", port: 5010)
                    .listen()

                ready.signal()

                _ = try socket.accept()
                done.wait()
            } catch {
                fail(String(describing: error))
            }
        }

        ready.wait()

        do {
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
            done.signal()
        } catch {
            fail(String(describing: error))
        }
    }
}
