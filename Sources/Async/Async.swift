import Platform
import Fiber
import Time

// MARK: common

public var loop: FiberLoop { .current }

public func async(_ task: @escaping () -> Void) {
    fiber(task)
}

public func await(
        for descriptor: Descriptor,
        event: IOEvent,
        deadline: Time = Time.distantFuture) throws
{
    try loop.wait(
            for: descriptor,
            event: event,
            deadline: deadline)
}

// MARK: controls

@_exported import func Fiber.yield
@_exported import func Fiber.suspend
@_exported import func Fiber.sleep

// MARK: wrapper for demos

public func async(_ task: @escaping () throws -> Void) -> Void {
    fiber { try! task() }
}

// MARK: ex async.loop.terminate

extension FiberLoop {
    public func terminate() {
        self.break()
    }
}

// MARK: sync Dispatch task

#if canImport(Dispatch)

import struct Dispatch.DispatchQoS
import class Dispatch.DispatchQueue

/// Spawn DispatchQueue.global().async task and yield until it's done

public func sync<T>(
    onQueue queue: DispatchQueue = DispatchQueue.global(),
    qos: DispatchQoS = .background,
    deadline: Time = .distantFuture,
    task: @escaping () throws -> T
) throws -> T {
    return try syncTask(qos: qos, deadline: deadline, task: task)
}

#endif
