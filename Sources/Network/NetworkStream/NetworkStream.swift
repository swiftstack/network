import Stream

public class NetworkStream: Stream {
    public enum Error: Swift.Error {
        case closed
    }

    let socket: Socket

    public init(socket: Socket) {
        self.socket = socket
    }

    public func read(
        to buffer: UnsafeMutableRawPointer, byteCount: Int
    ) throws -> Int {
        let read = try socket.receive(to: buffer, count: byteCount)
        guard read > 0 else {
            throw Error.closed
        }
        return read
    }

    public func write(
        from buffer: UnsafeRawPointer,
        byteCount: Int
    ) throws -> Int {
        let written = try socket.send(bytes: buffer, count: byteCount)
        guard written > 0 else {
            throw Error.closed
        }
        return written
    }
}
