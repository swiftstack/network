import Platform

struct Message {
    let id: Int
    var type: MessageType
    var kind: MessageKind
    var isAuthoritative: Bool
    var isTruncated: Bool
    var isRecursionDesired: Bool
    var isRecursionAvailable: Bool
    var responseCode: ResponseCode

    let question: [Question]
    let answer: [ResourceRecord]
    let authority: [ResourceRecord]
    let additional: [ResourceRecord]

    public init(domain: String, type: ResourceType) {
        self.id = Int(Int16.random(in: 0...Int16.max))
        self.type = .query
        self.kind = .query
        self.isAuthoritative = false
        self.isTruncated = false
        self.isRecursionDesired = true
        self.isRecursionAvailable = false
        self.responseCode = .noError

        self.question = [
            Question(name: domain, type: type)
        ]
        self.answer = []
        self.authority = []
        self.additional = []
    }
}

enum MessageType: UInt16 {
    case query    = 0
    case response = 1
}

enum MessageKind: UInt16 {
    case query  = 0
    case iquery = 1
    case status = 2
}

enum DNSError: Error {
    case invalidKind
    case invalidResponseCode
    case invalidName
    case invalidResourceType
    case invalidResourceClass
    case invalidResourceRecord
    case invalidResourceNSName
    case invalidOffset
    case invalidMessage
}

enum ResponseCode: UInt16 {
    case noError        = 0
    case formatError    = 1
    case serverFailure  = 2
    case nameError      = 3
    case notImplemented = 4
    case refused        = 5
}

struct Question {
    var name: String
    var type: ResourceType
}

struct ResourceRecord {
    let name: String
    let ttl: Int
    let data: ResourceData
}

enum ResourceData {
    case a(IPv4)
    case ns(String)
    case aaaa(IPv6)
}

enum ResourceType: UInt16 {
    case a     = 1
    case ns    = 2
    case cname = 5
    case soa   = 6
    case mx    = 15
    case aaaa  = 28
}

enum ResourceClass: UInt16 {
    case `in` = 1
}

extension Question: Equatable {
    static func ==(lhs: Question, rhs: Question) -> Bool {
        return lhs.name == rhs.name
            && lhs.type == rhs.type
    }
}

extension ResourceRecord: Equatable {
    static func ==(lhs: ResourceRecord, rhs: ResourceRecord) -> Bool {
        return lhs.name == rhs.name
            && lhs.ttl == rhs.ttl
            && lhs.data == rhs.data
    }
}

extension ResourceData: Equatable {
    static func ==(lhs: ResourceData, rhs: ResourceData) -> Bool {
        switch (lhs, rhs) {
        case let (.a(lhsAddress), .a(rhsAddress)):
            return lhsAddress == rhsAddress
        case let (.ns(lhsAddress), .ns(rhsAddress)):
            return lhsAddress == rhsAddress
        case let (.aaaa(lhsAddress), .aaaa(rhsAddress)):
            return lhsAddress == rhsAddress
        default:
            return false
        }
    }
}
