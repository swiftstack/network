import Platform

public struct Endpoint {
    public let host: String
    public let port: UInt16
}

extension Socket {
    public var local: Endpoint {
        var addr = sockaddr()
        var length = sockaddr.size
        getsockname(descriptor, &addr, &length)
        let sin = sockaddr_in(addr)
        return Endpoint(host: sin.host, port: sin.port)
    }

    public var remote: Endpoint {
        var addr = sockaddr()
        var length = sockaddr.size
        getpeername(descriptor, &addr, &length)
        let sin = sockaddr_in(addr)
        return Endpoint(host: sin.host, port: sin.port)
    }
}
