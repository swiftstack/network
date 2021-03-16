import Time
import Event
import Platform

public enum TCP {
    public final class Socket: ConcurrentValue {
        public let socket: Network.Socket

        public var selfAddress: Network.Socket.Address? { socket.selfAddress }
        public var peerAddress: Network.Socket.Address? { socket.peerAddress }

        public init(family: Network.Socket.Family = .inet) throws {
            try socket = .init(family: family, type: .stream)
        }

        public init(_ socket: Network.Socket) throws {
            self.socket = socket
        }

        @discardableResult
        public func bind(to address: Network.Socket.Address) throws -> Self {
            try socket.bind(to: address)
            return self
        }

        @discardableResult
        public func listen(backlog: Int = 256) throws -> Self {
            try socket.listen()
            return self
        }

        public func accept(
            deadline: Time = .distantFuture
        ) async throws -> Socket {
            let client = try await awaitIfNeeded(
                event: .read,
                deadline: deadline)
            {
                try socket.accept()
            }
            return try .init(client)
        }

        @discardableResult
        public func connect(
            to address: Network.Socket.Address,
            deadline: Time = .distantFuture
        ) async throws -> Self {
            do {
                _ = try await awaitIfNeeded(event: .write, deadline: deadline) {
                    try socket.connect(to: address)
                }
            }
            catch let error as Network.Socket.Error where error == .inProgress {
                try await loop.wait(for: socket.descriptor,
                    event: .write,
                    deadline: deadline)
            }
            return self
        }

        public func close() throws {
            try socket.close()
        }

        public func send(
            bytes: UnsafeRawPointer,
            count: Int,
            deadline: Time = .distantFuture
        ) async throws -> Int {
            try await awaitIfNeeded(event: .write, deadline: deadline) {
                try socket.send(bytes: bytes, count: count)
            }
        }

        public func receive(
            to buffer: UnsafeMutableRawPointer,
            count: Int,
            deadline: Time = .distantFuture
        ) async throws -> Int {
            try await awaitIfNeeded(event: .read, deadline: deadline) {
                try socket.receive(to: buffer, count: count)
            }
        }

        fileprivate func awaitIfNeeded<T>(
            event: IOEvent,
            deadline: Time,
            _ task: () throws -> T) async throws -> T
        {
            while true {
                do {
                    return try task()
                } catch let error as Network.Socket.Error {
                    switch error {
                    case .again, .wouldBlock, .interrupted:
                        try await loop.wait(
                            for: socket.descriptor,
                            event: event,
                            deadline: deadline)
                    default:
                        throw error
                    }
                }
            }
        }
    }
}
