import Platform

extension Socket {
    public enum Family: Sendable {
        case local, inet, inet6
    }

    public enum `Type`: Sendable {
        case stream, datagram, sequenced, raw
    }
}

extension Socket {
    public var isNonBlocking: Bool {
        get {
            return descriptor.status & O_NONBLOCK != 0
        }
        set {
            switch newValue {
            case true: descriptor.status |= O_NONBLOCK
            case false: descriptor.status &= ~O_NONBLOCK
            }
        }
    }

    public enum Option: Sendable {
        case reuseAddr, reusePort, broadcast
        #if os(macOS) || os(iOS)
        case noSignalPipe
        #endif
    }

    #if os(macOS) || os(iOS)
    var noSignalPipe: Bool {
        get { try! getOption(.noSignalPipe) }
        nonmutating
        set { try! setOption(.noSignalPipe, to: newValue) }
    }
    #endif

    var reuseAddr: Bool {
        get { try! getOption(.reuseAddr) }
        nonmutating
        set { try! setOption(.reuseAddr, to: newValue) }
    }

    var reusePort: Bool {
        get { try! getOption(.reusePort) }
        nonmutating
        set { try! setOption(.reusePort, to: newValue) }
    }

    var broadcast: Bool {
        get { try! getOption(.broadcast) }
        nonmutating
        set { try! setOption(.broadcast, to: newValue) }
    }

    // MARK: Utils

    private func getOption(_ option: Option) throws -> Bool {
        return try getValue(for: option.rawValue)
    }

    private func setOption(_ option: Option, to value: Bool) throws {
        try setValue(value, for: option.rawValue)
    }

    private func setValue(
        _ value: Bool,
        for option: Int32
    ) throws {
        var value: Int32 = value ? 1 : 0
        try setValue(&value, size: MemoryLayout<Int32>.size, for: option)
    }

    private func getValue(for option: Int32) throws -> Bool {
        var value: Int32 = 0
        var valueSize = MemoryLayout<Int32>.size
        try getValue(&value, size: &valueSize, for: option)
        return value == 0 ? false : true
    }

    private func setValue(
        _ pointer: UnsafeRawPointer,
        size: Int,
        for option: Int32
    ) throws {
        guard setsockopt(
            descriptor.rawValue,
            SOL_SOCKET,
            option,
            pointer,
            socklen_t(size)) != -1 else
        {
            throw Socket.Error()
        }
    }

    private func getValue(
        _ pointer: UnsafeMutableRawPointer,
        size: inout Int,
        for option: Int32
    ) throws {
        var actualSize = socklen_t(size)
        guard getsockopt(
            descriptor.rawValue,
            SOL_SOCKET,
            option,
            pointer,
            &actualSize) != -1 else
        {
            throw Socket.Error()
        }
        size = Int(actualSize)
    }
}
