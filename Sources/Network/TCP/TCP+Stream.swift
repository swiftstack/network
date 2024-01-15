import Platform
import Stream

extension TCP {
    public class Stream: InputStream, OutputStream {
        let socket: TCP.Socket

        public init(socket: TCP.Socket) {
            self.socket = socket
        }

        public func read(
            to buffer: UnsafeMutableRawPointer,
            byteCount: Int
        ) async throws -> Int {
            let read = try await socket.receive(to: buffer, count: byteCount)
            guard read != -1 else {
                throw SystemError()
            }
            return read
        }

        public func write(
            from buffer: UnsafeRawPointer,
            byteCount: Int
        ) async throws -> Int {
            let written = try await socket.send(bytes: buffer, count: byteCount)
            guard written != -1 else {
                throw SystemError()
            }
            return written
        }
    }
}
