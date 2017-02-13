import Platform

extension Socket {
    @discardableResult
    func configure(reusePort: Bool = false) -> Socket {
        options.reusePort = reusePort
        return self
    }

    public struct Options {
        let descriptor: Descriptor
        public init(for descriptor: Descriptor) {
            self.descriptor = descriptor
        }

        public var reuseAddr: Bool {
            get {
                return try! getValue(for: SO_REUSEADDR)
            }
            set {
                try! setValue(true, for: SO_REUSEADDR)
            }
        }

        public var reusePort: Bool {
            get {
                return try! getValue(for: SO_REUSEPORT)
            }
            set {
                try! setValue(true, for: SO_REUSEPORT)
            }
        }

    #if os(macOS)
        public var noSignalPipe: Bool {
            get {
                return try! getValue(for: SO_NOSIGPIPE)
            }
            set {
                try! setValue(true, for: SO_NOSIGPIPE)
            }
        }
    #endif

        fileprivate mutating func setValue(_ value: Bool, for option: Int32) throws {
            var value: Int32 = value ? 1 : 0
            try setValue(&value, size: MemoryLayout<Int32>.size, for: option)
        }

        fileprivate func getValue(for option: Int32) throws -> Bool {
            var value: Int32 = 0
            var valueSize = MemoryLayout<Int32>.size
            try getValue(&value, size: &valueSize, for: option)
            return value == 0 ? false : true
        }

        fileprivate mutating func setValue(_ pointer: UnsafeRawPointer, size: Int, for option: Int32) throws {
            guard setsockopt(descriptor, SOL_SOCKET, option, pointer, socklen_t(size)) != -1 else {
                throw SocketError()
            }
        }

        fileprivate func getValue(_ pointer: UnsafeMutableRawPointer, size: inout Int, for option: Int32) throws {
            var actualSize = socklen_t(size)
            guard getsockopt(descriptor, SOL_SOCKET, option, pointer, &actualSize) != -1 else {
                throw SocketError()
            }
            size = Int(actualSize)
        }
    }
}
