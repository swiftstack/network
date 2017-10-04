import Platform

extension Socket {
    @discardableResult
    public func configure(
        _ configurator: (inout Options) throws -> Void
    ) rethrows -> Self {
        try configurator(&options)
        return self
    }

    public struct Options {
        let descriptor: Descriptor

        public init(for descriptor: Descriptor) {
            self.descriptor = descriptor
        }

        public func get(_ option: Option) throws -> Bool {
            return try getValue(for: option.rawValue)
        }

        public func set(_ option: Option, _ value: Bool) throws {
            try setValue(value, for: option.rawValue)
        }

        fileprivate func setValue(
            _ value: Bool,
            for option: Int32
        ) throws {
            var value: Int32 = value ? 1 : 0
            try setValue(&value, size: MemoryLayout<Int32>.size, for: option)
        }

        fileprivate func getValue(for option: Int32) throws -> Bool {
            var value: Int32 = 0
            var valueSize = MemoryLayout<Int32>.size
            try getValue(&value, size: &valueSize, for: option)
            return value == 0 ? false : true
        }

        fileprivate func setValue(
            _ pointer: UnsafeRawPointer,
            size: Int,
            for option: Int32
        ) throws {
            guard setsockopt(
                descriptor.rawValue,
                SOL_SOCKET,
                option,
                pointer,
                socklen_t(size)) != -1 else {
                    throw SocketError()
            }
        }

        fileprivate func getValue(
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
                &actualSize) != -1 else {
                    throw SocketError()
            }
            size = Int(actualSize)
        }
    }
}
