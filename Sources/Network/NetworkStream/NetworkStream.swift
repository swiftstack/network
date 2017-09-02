#if canImport(Stream)
import Stream

public class NetworkStream: Stream {
    let socket: Socket

    public init(socket: Socket) {
        self.socket = socket
    }

    public func read(to buffer: UnsafeMutableRawBufferPointer) throws -> Int {
        return try socket.receive(to: buffer)
    }

    public func write(_ bytes: UnsafeRawBufferPointer) throws -> Int {
        return try socket.send(bytes: bytes.baseAddress!, count: bytes.count)
    }
}
#endif
