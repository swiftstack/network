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

enum ResponseCode: UInt16 {
    case noError        = 0
    case formatError    = 1
    case serverFailure  = 2
    case nameError      = 3
    case notImplemented = 4
    case refused        = 5
}

struct Question: Equatable {
    var name: String
    var type: ResourceType
}

struct ResourceRecord: Equatable {
    let name: String
    let ttl: Int
    let data: ResourceData
}

enum ResourceData: Equatable {
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
