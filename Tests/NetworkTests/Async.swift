import Async
import Platform
import Dispatch
import Foundation

class TestAsyncLoop: AsyncLoop {
    var terminate = false

    func run() {
        while !terminate {
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        }
    }

    func stop() {
        terminate = true
    }

    func run(until: Date) {
        fatalError("not implemented")
    }
}

class TestAsync: Async {
    let loop: AsyncLoop = TestAsyncLoop()

    func wait(
        for descriptor: Descriptor,
        event: IOEvent,
        deadline: Date
    ) throws {
        let event = event == .read ? Int16(POLLIN) : Int16(POLLOUT)
        var fd = pollfd(fd: descriptor.rawValue, events: event, revents: 0)
        guard poll(&fd, 1, -1) > 0 else {
            throw SystemError()
        }
    }

    func task(_ closure: @escaping AsyncTask) {
        DispatchQueue.global(qos: .userInitiated).async(execute: closure)
    }

    func syncTask<T>(
        onQueue queue: DispatchQueue,
        qos: DispatchQoS,
        deadline: Date,
        task: @escaping () throws -> T
    ) throws -> T {
        return try task()
    }

    func sleep(until deadline: Date) {
        fatalError("not implemented")
    }

    func testCancel() throws {
        fatalError("not implemented")
    }
}
