import Test
import Platform

@testable import Network

test("Socket") {
    let socket = try Socket().bind(to: "127.0.0.1", port: 3000)
    expect(socket.selfAddress == .ip4(try .init("127.0.0.1", 3000)))
    expect(socket.isNonBlocking)
}

test("socket.reuseAddr") {
    let socket = try Socket()
    expect(socket.reuseAddr == true)
}

test("unix socket.reuseAddr") {
    unlink("/tmp/unix1")
    try Socket(family: .local).bind(to: "/tmp/unix1")
    expect(throws: Socket.Error.alreadyInUse) {
        try Socket(family: .local).bind(to: "/tmp/unix1")
    }
}

test("socket.reusePort") {
    let socket = try Socket()
    expect(socket.reusePort == false)
    socket.reusePort = true
    expect(socket.reusePort == true)
}

#if os(macOS)
test("socket.noSignalPipe") {
    let socket = try Socket()
    expect(socket.noSignalPipe == true)
}
#endif

test("socket.broadcast") {
    let socket = try Socket()
    expect(socket.broadcast == false)
    socket.broadcast = true
    expect(socket.broadcast == true)
}

await run()
