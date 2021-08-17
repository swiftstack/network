# AIO

Asynchronous non-blocking io with syncronous API. **No callbacks.**

## Package.swift

 ```swift
.package(url: "https://github.com/swiftstack/aio.git", .branch("dev"))
```

# Network

Zero-cost socket abstraction designed for cooperative multitasking.

## Usage

You can find this code and more in [examples](https://github.com/swiftstack/examples).

### Sync
```swift
let socket = try Socket()
```

### Async
```swift
import Async
import Network

async {
    let socket = try Socket()
    // use non-blocking api
}

loop.run()
```

```swift
let hello = [UInt8]("Hello, World!".utf8)
let empty = [UInt8](repeating: 0, count: hello.count + 1)
```

### TCP
```swift
async {
    let socket = try Socket()
        .bind(to: "127.0.0.1", port: 1111)
        .listen()

    let client = try socket.accept()
    _ = try client.send(bytes: hello)
}

async {
    let socket = try Socket()
        .connect(to: "127.0.0.1", port: 1111)

    var buffer = empty
    _ = try socket.receive(to: &buffer)
}
```

### UDP
```swift
let udpServerAddress = try Socket.Address("127.0.0.1", port: 2222)

async {
    let socket = try Socket(type: .datagram)
        .bind(to: udpServerAddress)

    var buffer = empty
    var client: Socket.Address? = nil
    _ = try socket.receive(to: &buffer, from: &client)
    _ = try socket.send(bytes: hello, to: client!)
}

async {
    let socket = try Socket(type: .datagram)

    var buffer = empty
    _ = try socket.send(bytes: hello, to: udpServerAddress)
    _ = try socket.receive(to: &buffer)
}
```

### TCP IPv6
```swift
async {
    let socket = try Socket(family: .inet6)
        .bind(to: "::1", port: 3333)
        .listen()

    let client = try socket.accept()
    _ = try client.send(bytes: hello)
}

async {
    let socket = try Socket(family: .inet6)
        .connect(to: "::1", port: 3333)

    var buffer = empty
    _ = try socket.receive(to: &buffer)
}
```

### UNIX
```swift
#if os(Linux)
let type: Socket.SocketType = .sequenced
#else
let type: Socket.SocketType = .stream
#endif

unlink("/tmp/socketexample.sock")

async {
    let socket = try Socket(family: .unix, type: type)
        .bind(to: "/tmp/socketexample.sock")
        .listen()

    let client = try socket.accept()
    _ = try client.send(bytes: hello)
}

async {
    let socket = try Socket(family: .unix, type: type)
        .connect(to: "/tmp/socketexample.sock")

    var buffer = empty
    _ = try socket.receive(to: &buffer)
}
```

## Socket API

```swift
final class Socket {
    enum Family {
        case inet, inet6, unspecified, unix
    }

    enum SocketType {
        case stream, datagram, sequenced
    }

    enum Address {
        init(_: String, port: UInt16? = nil) throws
        init(ip4: String, port: UInt16) throws
        init(ip6: String, port: UInt16) throws
        init(unix: String) throws
    }

    init(family: Family = .tcp, type: SocketType = .stream) throws

    func bind(to: Address) throws -> Socket
    func listen() throws -> Socket

    func accept(deadline: Time = .distantFuture) throws -> Socket
    func connect(to: Address, deadline: Time = .distantFuture) throws -> Socket

    func close() throws

    func send(bytes: UnsafeRawPointer, count: Int, deadline: Time = .distantFuture) throws -> Int
    func send(bytes: UnsafeRawPointer, count: Int, to: Address, deadline: Time = .distantFuture) throws -> Int

    func receive(to: UnsafeMutableRawPointer, count: Int, deadline: Time = .distantFuture) throws -> Int
    func receive(to: UnsafeMutableRawPointer, count: Int, from: inout Address?, deadline: Time = .distantFuture) throws -> Int
}

extension Socket {
    func bind(to: String, port: UInt16) throws -> Socket
    func bind(to: String) throws -> Socket

    func connect(to: String, port: UInt16, deadline: Time = .distantFuture) throws -> Socket
    func connect(to: String, deadline: Time = .distantFuture) throws -> Socket

    func send(bytes: [UInt8], deadline: Time = .distantFuture) throws -> Int
    func send(bytes: [UInt8], to: Address, deadline: Time = .distantFuture) throws -> Int

    func receive(to: inout [UInt8], deadline: Time = .distantFuture) throws -> Int
    func receive(to: inout [UInt8], from: inout Address?, deadline: Time = .distantFuture) throws -> Int
}
```
