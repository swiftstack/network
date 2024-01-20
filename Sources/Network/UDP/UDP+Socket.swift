import Event
import Platform

public enum UDP {
    public final class Socket: Sendable {
        public let socket: Network.Socket

        public var selfAddress: Network.Socket.Address? { socket.selfAddress }

        public init(family: Network.Socket.Family = .inet) throws {
            try socket = .init(family: family, type: .datagram)
        }

        private init(socket: Network.Socket) throws {
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

        public func close() throws {
            try socket.close()
        }

        public func send(
            bytes: UnsafeRawPointer,
            count: Int,
            to address: Network.Socket.Address,
            deadline: Instant? = nil
        ) async throws -> Int {
            try await awaitIfNeeded(event: .write, deadline: deadline) {
                try socket.send(bytes: bytes, count: count, to: address)
            }
        }

        public func receive(
            to buffer: UnsafeMutableRawPointer,
            count: Int,
            deadline: Instant? = nil
        ) async throws -> (count: Int, from: Network.Socket.Address) {
            try await awaitIfNeeded(event: .read, deadline: deadline) {
                try socket.receive(to: buffer, count: count)
            }
        }

        fileprivate func awaitIfNeeded<T>(
            event: IOEvent,
            deadline: Instant?,
            _ task: () throws -> T
        ) async throws -> T {
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
