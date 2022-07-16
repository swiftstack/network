import Platform

// MARK: raw values

#if os(Linux)
    let SOCK_STREAM = Int32(Glibc.SOCK_STREAM.rawValue)
    let SOCK_DGRAM = Int32(Glibc.SOCK_DGRAM.rawValue)
    let SOCK_SEQPACKET = Int32(Glibc.SOCK_SEQPACKET.rawValue)
    let SOCK_RAW = Int32(Glibc.SOCK_RAW.rawValue)
    let noSignal = Int32(MSG_NOSIGNAL)
#else
    let noSignal = Int32(0)
#endif

extension Socket.Family {
    var rawValue: Int32 {
        switch self {
        case .local: return PF_LOCAL
        case .inet: return PF_INET
        case .inet6: return PF_INET6
        }
    }
}

extension Socket.`Type` {
    var rawValue: Int32 {
        switch self {
        case .stream: return SOCK_STREAM
        case .datagram: return SOCK_DGRAM
        case .sequenced: return SOCK_SEQPACKET
        case .raw: return SOCK_RAW
        }
    }
}

extension Socket.Option {
    var rawValue: Int32 {
        #if os(macOS) || os(iOS)
            switch self {
            case .reuseAddr: return SO_REUSEADDR
            case .reusePort: return SO_REUSEPORT
            case .noSignalPipe: return SO_NOSIGPIPE
            case .broadcast: return SO_BROADCAST
            }
        #else
            switch self {
            case .reuseAddr: return SO_REUSEADDR
            case .reusePort: return SO_REUSEPORT
            case .broadcast: return SO_BROADCAST
            }
        #endif
    }
}
