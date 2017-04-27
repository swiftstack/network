import Platform

public struct SocketError: Error, CustomStringConvertible {
    public let number = errno
    public let description = String(cString: strerror(errno))

    public var interrupted: Bool {
        return number == EAGAIN || number == EWOULDBLOCK || number == EINTR
    }
}
