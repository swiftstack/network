import Platform

extension Socket {
    public enum Address {
        case ip4(sockaddr_in)
        case ip6(sockaddr_in6)
        case unix(sockaddr_un)
        case unspecified

        public enum Family {
            case inet, inet6, unspecified, unix

            // FIXME: extension Socket.Address.Family doesn't compile
            var rawValue: Int32 {
                switch self {
                case .inet: return AF_INET
                case .inet6: return AF_INET6
                case .unix: return AF_UNIX
                case .unspecified: return AF_UNSPEC
                }
            }
        }

        var family: Family {
            switch self {
            case .ip4: return .inet
            case .ip6: return .inet6
            case .unix: return .unix
            case .unspecified: return .unspecified
            }
        }

        var size: socklen_t {
            switch self {
            case .ip4: return sockaddr_in.size
            case .ip6: return sockaddr_in6.size
            case .unix: return sockaddr_un.size
            case .unspecified: return 0
            }
        }
    }

    public var selfAddress: Address? {
        var storage = sockaddr_storage()
        var size = UInt32(sockaddr_storage.size)
        getsockname(descriptor, rebounded(&storage), &size)
        return Address(storage, size)
    }

    public var peerAddress: Address? {
        var storage = sockaddr_storage()
        var size = UInt32(sockaddr_storage.size)
        getpeername(descriptor, rebounded(&storage), &size)
        return Address(storage, size)
    }
}

extension Socket.Address {
    init?(_ storage: sockaddr_storage, _ size: socklen_t) {
        switch Int32(storage.ss_family) {
        case Socket.Address.Family.inet.rawValue:
            self = .ip4(sockaddr_in(storage))
        case Socket.Address.Family.inet6.rawValue:
            self = .ip6(sockaddr_in6(storage))
        case Socket.Address.Family.unix.rawValue:
            self = .unix(sockaddr_un(storage))
        default:
            self = .unspecified
        }
    }
}

extension Socket.Address {
    public init(_ address: String, port: UInt16? = nil) throws {
        if let port = port {
            if let ip4 = try? Socket.Address(ip4: address, port: port) {
                self = ip4
                return
            }

            if let ip6 = try? Socket.Address(ip6: address, port: port) {
                self = ip6
                return
            }
        }

        if let unix = try? Socket.Address(unix: address) {
            self = unix
            return
        }

        // TODO: resolve domain

        errno = EINVAL
        throw SocketError()
    }

    public init(ip4 address: String, port: UInt16) throws {
        self = .ip4(try sockaddr_in(address, port))
    }

    public init(ip6 address: String, port: UInt16) throws {
        self = .ip6(try sockaddr_in6(address, port))
    }

    public init(unix address: String) throws {
        self = .unix(try sockaddr_un(address))
    }
}

extension Socket.Address: Equatable {
    public static func ==(lhs: Socket.Address, rhs: Socket.Address) -> Bool {
        switch (lhs, rhs) {
        case let (.ip4(lhs), .ip4(rhs)): return lhs == rhs
        case let (.ip6(lhs), .ip6(rhs)): return lhs == rhs
        case let (.unix(lhs), .unix(rhs)): return lhs == rhs
        default: return false
        }
    }
}
