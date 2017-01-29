import Platform

public struct SocketError: Error, CustomStringConvertible {
    let error = SystemError()
    public var number: Int {
        return Int(error.number)
    }
    public var description: String {
        return error.description
    }
}
