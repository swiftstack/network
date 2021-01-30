import Test
import Platform

@testable import Network

test.case("ReuseAddr") {
    let socket = try Socket()
    expect(try socket.options.get(.reuseAddr) == true)
}

test.case("ReuseAddrUnix") {
    unlink("/tmp/unix1")
    try Socket(family: .local).bind(to: "/tmp/unix1")
    expect(throws: Socket.Error.alreadyInUse) {
        try Socket(family: .local).bind(to: "/tmp/unix1")
    }
}

test.case("ReusePort") {
    let socket = try Socket()
    expect(try socket.options.get(.reusePort) == false)
    try socket.options.set(.reusePort, true)
    expect(try socket.options.get(.reusePort) == true)
}

test.case("NoSignalPipe") {
    let socket = try Socket()
    #if os(macOS)
    expect(try socket.options.get(.noSignalPipe) == true)
    #endif
}

test.case("ConfigureReusePort") {
    let socket = try Socket().configure { options in
        try options.set(.reusePort, true)
    }
    expect(try socket.options.get(.reuseAddr) == true)
    expect(try socket.options.get(.reusePort) == true)
}

test.case("ConfigureBroadcast") {
    let socket = try Socket().configure { options in
        try options.set(.broadcast, true)
    }
    expect(try socket.options.get(.broadcast) == true)
}

test.run()
