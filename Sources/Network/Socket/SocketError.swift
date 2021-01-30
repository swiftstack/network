import Platform

extension Socket {
    public enum Error: Swift.Error, Equatable, CustomStringConvertible {
        case again           // EAGAIN
        case wouldBlock      // EWOULDBLOCK
        case inProgress      // EINPROGRESS
        case interrupted     // EINTR
        case badDescriptor   // EBADF
        case invalidArgument // EINVAL
        case connectionReset // ECONNRESET
        case alreadyInUse    // EADDRINUSE
        case system(Int32)

        var shouldTryAgain: Bool {
            switch self {
            case .again, .wouldBlock, .interrupted: return true
            default: return false
            }
        }

        init() {
            switch errno {
            case EAGAIN: self = .again
            case EWOULDBLOCK: self = .wouldBlock
            case EINPROGRESS: self = .inProgress
            case EINTR: self = .interrupted
            case EBADF: self = .badDescriptor
            case EINVAL: self = .invalidArgument
            case ECONNRESET: self = .connectionReset
            case EADDRINUSE: self = .alreadyInUse
            default: self = .system(errno)
            }
        }

        public var description: String {
            switch self {
            case .again: return .init(cString: strerror(EAGAIN))
            case .wouldBlock: return .init(cString: strerror(EWOULDBLOCK))
            case .inProgress: return .init(cString: strerror(EINPROGRESS))
            case .interrupted: return .init(cString: strerror(EINTR))
            case .badDescriptor: return .init(cString: strerror(EBADF))
            case .invalidArgument: return .init(cString: strerror(EINVAL))
            case .connectionReset: return .init(cString: strerror(ECONNRESET))
            case .alreadyInUse: return .init(cString: strerror(EADDRINUSE))
            case .system(let code): return .init(cString: strerror(code))
            }
        }
    }
}
