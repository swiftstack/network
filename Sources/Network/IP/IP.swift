import Platform

enum IPAddress {
    case v4(IPv4)
    case v6(IPv6)
}

struct IPv4 {
    let address: in_addr

    public init(_ address: UInt32) {
        self.address = in_addr(s_addr: address)
    }

    public init(
        _ fragment1: UInt8,
        _ fragment2: UInt8,
        _ fragment3: UInt8,
        _ fragment4: UInt8
    ) {
        // FIXME: expression was to complex to be solved in reasonable time.
        let fragment1 = UInt32(fragment1)
        let fragment2 = UInt32(fragment2) << 8
        let fragment3 = UInt32(fragment3) << 16
        let fragment4 = UInt32(fragment4) << 24
        self.init(fragment1 | fragment2 | fragment3 | fragment4)
    }
}

struct IPv6 {
    let address: in6_addr

    public init(
        _ fragment1: UInt16,
        _ fragment2: UInt16,
        _ fragment3: UInt16,
        _ fragment4: UInt16,
        _ fragment5: UInt16,
        _ fragment6: UInt16,
        _ fragment7: UInt16,
        _ fragment8: UInt16
    ) {
        self.address = in6_addr(
            (
                fragment1.bigEndian,
                fragment2.bigEndian,
                fragment3.bigEndian,
                fragment4.bigEndian,
                fragment5.bigEndian,
                fragment6.bigEndian,
                fragment7.bigEndian,
                fragment8.bigEndian
            )
        )
    }
}

extension IPv4: CustomStringConvertible {
    var description: String {
        return address.description
    }
}

extension IPv6: CustomStringConvertible {
    var description: String {
        return address.description
    }
}

extension IPv4: Equatable {
    static func ==(lhs: IPv4, rhs: IPv4) -> Bool {
        return lhs.address == rhs.address
    }
}

extension IPv6: Equatable {
    static func ==(lhs: IPv6, rhs: IPv6) -> Bool {
        return lhs.address == rhs.address
    }
}

extension IPAddress: Equatable {
    static func ==(lhs: IPAddress, rhs: IPAddress) -> Bool {
        switch (lhs, rhs) {
        case let (.v4(lhs), v4(rhs)): return lhs == rhs
        case let (.v6(lhs), v6(rhs)): return lhs == rhs
        default: return false
        }
    }
}
