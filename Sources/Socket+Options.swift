import Platform

extension Socket {
    public struct Options {
        let descriptor: Descriptor
        public init(for descriptor: Descriptor) {
            self.descriptor = descriptor
        }

        public subscript(option: Int32) -> Bool? {
            get {
                var value: Int32 = 0
                var valueSize = socklen_t(MemoryLayout<Int32>.size)
                guard getsockopt(descriptor, SOL_SOCKET, option, &value, &valueSize) != -1 else {
                    return nil
                }
                return value == 0 ? false : true
            }
            set {
                var value: Int32 = newValue == true ? 1 : 0
                let valueSize = socklen_t(MemoryLayout<Int32>.size)
                _ = setsockopt(descriptor, SOL_SOCKET, option, &value, valueSize)
            }
        }
    }
}
