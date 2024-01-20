import Platform

// MARK: convert

func rebounded<T>(
    _ pointer: UnsafePointer<T>
) -> UnsafePointer<sockaddr> {
    UnsafeRawPointer(pointer).assumingMemoryBound(to: sockaddr.self)
}

func rebounded<T>(
    _ pointer: UnsafeMutablePointer<T>
) -> UnsafeMutablePointer<sockaddr> {
    UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: sockaddr.self)
}

extension in_addr {
    init?(_ address: String) throws {
        var addr = in_addr()
        switch inet_pton(AF_INET, address, &addr) {
        case 1: self = addr
        case 0: return nil
        case -1: throw Network.Socket.Error() // TODO: define possible errors
        default: preconditionFailure("inet_pton: unexpected return code")
        }
    }
}

extension in6_addr {
    init?(_ address: String) throws {
        var addr6 = in6_addr()
        switch inet_pton(AF_INET6, address, &addr6) {
        case 1: self = addr6
        case 0: return nil
        case -1: throw Network.Socket.Error() // TODO: define possible errors
        default: preconditionFailure("inet_pton: unexpected return code")
        }
    }
}

// MARK: convenience initializers

extension sockaddr_in {
    init(_ storage: sockaddr_storage) {
        var storage = storage
        var sockaddr = sockaddr_in()
        memcpy(&sockaddr, &storage, Int(sockaddr_in.size))
        self = sockaddr
    }
}

extension sockaddr_in6 {
    init(_ storage: sockaddr_storage) {
        var storage = storage
        var sockaddr = sockaddr_in6()
        memcpy(&sockaddr, &storage, Int(sockaddr_in6.size))
        self = sockaddr
    }
}

extension sockaddr_un {
    init(_ storage: sockaddr_storage) {
        var storage = storage
        var sockaddr = sockaddr_un()
        memcpy(&sockaddr, &storage, Int(sockaddr_un.size))
        self = sockaddr
    }
}

// MARK: convenience properties

extension sockaddr_storage {
    static var size: socklen_t {
        socklen_t(MemoryLayout<sockaddr_storage>.size)
    }
}

extension sockaddr_in {
    var address: String {
        self.sin_addr.description
    }

    var port: UInt16 {
        get { return self.sin_port.bigEndian }
        set { self.sin_port = in_port_t(newValue).bigEndian }
    }

    var family: Int32 {
        get { return Int32(self.sin_family) }
        set { self.sin_family = sa_family_t(newValue) }
    }

    static var size: socklen_t {
        socklen_t(MemoryLayout<sockaddr_in>.size)
    }

    public init(_ address: in_addr, _ port: UInt16) throws {
        var sockaddr = sockaddr_in()
    #if os(macOS)
        sockaddr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    #endif
        sockaddr.family = AF_INET
        sockaddr.sin_addr = address
        sockaddr.port = port
        self = sockaddr
    }

    public init(_ address: String, _ port: Int) throws {
        guard
            let address = try in_addr(address),
            let port = UInt16(exactly: port)
        else {
            throw Socket.Error.invalidArgument
        }
        try self.init(address, port)
    }
}

extension sockaddr_in6 {
    var address: String {
        sin6_addr.description
    }

    var port: UInt16 {
        get { self.sin6_port.bigEndian }
        set { self.sin6_port = in_port_t(newValue).bigEndian }
    }

    var family: Int32 {
        get { Int32(self.sin6_family) }
        set { self.sin6_family = sa_family_t(newValue) }
    }

    static var size: socklen_t {
        socklen_t(MemoryLayout<sockaddr_in6>.size)
    }

    public init(_ address: in6_addr, _ port: UInt16) throws {
        var sockaddr = sockaddr_in6()
    #if os(macOS)
        sockaddr.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
    #endif
        sockaddr.family = AF_INET6
        sockaddr.sin6_addr = address
        sockaddr.port = port
        self = sockaddr
    }

    public init(_ address: String, _ port: Int) throws {
        guard
            let address = try in6_addr(address),
            let port = UInt16(exactly: port)
        else {
            throw Socket.Error.invalidArgument
        }
        try self.init(address, port)
    }
}

extension sockaddr_un {
    var address: String {
        var path = self.sun_path
        let size = MemoryLayout.size(ofValue: path)
        var bytes = [Int8](repeating: 0, count: size)
        memcpy(&bytes, &path, size-1)
        return String(cString: bytes)
    }

    var family: Int32 {
        get { Int32(self.sun_family) }
        set { self.sun_family = sa_family_t(newValue) }
    }

    static var size: socklen_t {
        socklen_t(MemoryLayout<sockaddr_un>.size)
    }

    public init(_ address: String) throws {
        guard address.starts(with: "/") else {
            throw Socket.Error.invalidArgument
        }
        var bytes = [UInt8](address.utf8)
        var sockaddr = sockaddr_un()
        let size = MemoryLayout.size(ofValue: sockaddr.sun_path)
        guard bytes.count < size else {
            throw Socket.Error.invalidArgument
        }
    #if os(macOS)
        sockaddr.sun_len = UInt8(sockaddr_un.size)
    #endif
        sockaddr.family = AF_UNIX
        memcpy(&sockaddr.sun_path, &bytes, bytes.count)
        self = sockaddr
    }
}

// MARK: CustomStringConvertible

#if swift(>=5.10)
extension sockaddr_in: @retroactive CustomStringConvertible {}
extension sockaddr_in6: @retroactive CustomStringConvertible {}
extension in_addr: @retroactive CustomStringConvertible {}
extension in6_addr: @retroactive CustomStringConvertible {}
#else
extension sockaddr_in: CustomStringConvertible {}
extension sockaddr_in6: CustomStringConvertible {}
extension in_addr: CustomStringConvertible {}
extension in6_addr: CustomStringConvertible {}
#endif

extension sockaddr_in {
    public var description: String {
        "\(address):\(port)"
    }
}

extension sockaddr_in6 {
    public var description: String {
        "\(address):\(port)"
    }
}

extension in_addr {
    public var description: String {
        var bytes = [Int8](repeating: 0, count: Int(INET_ADDRSTRLEN) + 1)
        var addr = self
        guard
            inet_ntop(AF_INET, &addr, &bytes, socklen_t(INET_ADDRSTRLEN)) != nil
        else {
            return ""
        }
        return String(cString: bytes)
    }
}

extension in6_addr {
    public var description: String {
        var bytes = [Int8](repeating: 0, count: Int(INET6_ADDRSTRLEN) + 1)
        var addr = self
        guard
            inet_ntop(AF_INET6, &addr, &bytes, socklen_t(INET6_ADDRSTRLEN))
                != nil
        else {
            return ""
        }
        return String(cString: bytes)
    }
}

extension in6_addr {
    init(
        _ addr16:
            (UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16)
    ) {
        #if os(Linux)
            self = in6_addr(
                __in6_u: in6_addr.__Unnamed_union___in6_u(
                    __u6_addr16: (addr16)
                )
            )
        #else
            self = in6_addr(
                __u6_addr: in6_addr.__Unnamed_union___u6_addr(
                    __u6_addr16: (addr16)
                )
            )
        #endif
    }
}

// Equatable

#if swift(>=5.10)
extension sockaddr_in: @retroactive Equatable {}
extension sockaddr_in6: @retroactive Equatable {}
extension sockaddr_un: @retroactive Equatable {}
extension in_addr: @retroactive Equatable {}
extension in6_addr: @retroactive Equatable {}
#else
extension sockaddr_in: Equatable {}
extension sockaddr_in6: Equatable {}
extension sockaddr_un: Equatable {}
extension in_addr: Equatable {}
extension in6_addr: Equatable {}
#endif

protocol NativeStructEquatable {}
extension sockaddr_in: NativeStructEquatable {}
extension sockaddr_in6: NativeStructEquatable {}
extension sockaddr_un: NativeStructEquatable {}
extension in_addr: NativeStructEquatable {}
extension in6_addr: NativeStructEquatable {}

extension NativeStructEquatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        withUnsafeBytes(of: lhs) { lhs in
            withUnsafeBytes(of: rhs) { rhs in
                lhs.elementsEqual(rhs)
            }
        }
    }
}
