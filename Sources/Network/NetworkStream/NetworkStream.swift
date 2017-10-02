import Stream

public class NetworkStream: Stream {
    public enum Error: Swift.Error {
        case closed
    }

    let socket: Socket

    public init(socket: Socket) {
        self.socket = socket
    }

    public func read(to buffer: UnsafeMutableRawBufferPointer) throws -> Int {
        let read = try socket.receive(to: buffer)
        guard read > 0 else {
            throw Error.closed
        }
        return read
    }

    public func write(_ bytes: UnsafeRawBufferPointer) throws -> Int {
        let written = try socket.send(
            bytes: bytes.baseAddress!,
            count: bytes.count)
        guard written > 0 else {
            throw Error.closed
        }
        return written
    }
}
