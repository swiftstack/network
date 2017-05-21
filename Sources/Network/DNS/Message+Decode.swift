extension Message {
    init(from bytes: [UInt8]) throws {
        let headerSize = 12
        guard bytes.count >= headerSize else {
            throw DNSError.invalidMessage
        }

        // MARK: Header

        let id = Int(UInt16(bytes[0]) << 8 | UInt16(bytes[1]))

        let mask = UInt16(bytes[2]) << 8 | UInt16(bytes[3])

        let rawType = (mask & 0b1000_0000_0000_0000) >> 15
        let rawKind = (mask & 0b0111_1000_0000_0000) >> 11
        let isAuthoritative = (mask & 0b0000_0100_0000_0000) >> 10
        let isTruncated = (mask & 0b0000_0010_0000_0000) >> 9
        let isRecursionDesired = (mask & 0b0000_0001_0000_0000) >> 8
        let isRecursionAvailable = (mask & 0b0000_0000_1000_0000) >> 7
        let rawResponseCode = (mask & 0b0000_0000_0000_1111)

        let type = MessageType(rawValue: rawType)!

        guard let kind = MessageKind(rawValue: rawKind) else {
            throw DNSError.invalidKind
        }
        guard let responseCode = ResponseCode(rawValue: rawResponseCode) else {
            throw DNSError.invalidResponseCode
        }

        let questionCount = Int(bytes[4]) << 8 | Int(bytes[5])
        let answerCount = Int(bytes[6]) << 8 | Int(bytes[7])
        let authorityCount = Int(bytes[8]) << 8 | Int(bytes[9])
        let additionalCount = Int(bytes[10]) << 8 | Int(bytes[11])

        // MARK: ResourceRecords

        var offset = headerSize

        func decodeName(
            from bytes: [UInt8],
            offset: inout Int
        ) throws -> String {
            var nameParts = [String]()
            while true {
                guard offset < bytes.count else {
                    throw DNSError.invalidName
                }

                let count = Int(bytes[offset])
                offset += 1
                if count == 0 {
                    break
                }

                if count & 0b1100_0000 != 0 {
                    var nameOffset = (count ^ 0b1100_0000) << 8
                        | Int(bytes[offset])
                    offset += 1
                    guard nameOffset < offset else {
                        throw DNSError.invalidOffset
                    }
                    let name = try decodeName(from: bytes, offset: &nameOffset)
                    nameParts.append(name)
                    return nameParts.joined(separator: ".")
                }

                guard offset + count <= bytes.count else {
                    throw DNSError.invalidName
                }
                let part = [UInt8](bytes[offset..<offset + count]) + [0]
                nameParts.append(String(cString: part))
                offset += count
            }
            return nameParts.joined(separator: ".")
        }

        func decodeType(
            from bytes: [UInt8],
            offset: inout Int
        ) throws -> ResourceType {
            let rawType = UInt16(bytes[offset]) << 8 | UInt16(bytes[offset+1])
            guard let type = ResourceType(rawValue: rawType) else {
                throw DNSError.invalidResourceType
            }
            offset += 2
            return type
        }

        func decodeClass(
            from bytes: [UInt8],
            offset: inout Int
        ) throws -> ResourceClass {
            let rawClass = UInt16(bytes[offset]) << 8 | UInt16(bytes[offset+1])
            guard let klass = ResourceClass(rawValue: rawClass) else {
                throw DNSError.invalidResourceClass
            }
            offset += 2
            return klass
        }

        var questions = [Question]()
        for _ in 0..<questionCount {
            let name = try decodeName(from: bytes, offset: &offset)
            let type = try decodeType(from: bytes, offset: &offset)
            _ = try decodeClass(from: bytes, offset: &offset)
            questions.append(Question(name: name, type: type))
        }

        func decodeTTL(
            from bytes: [UInt8], offset: inout Int
        ) throws -> Int {
            // FIXME: expression was to complex
            let byte1 = Int(bytes[offset]) << 24
            let byte2 = Int(bytes[offset+1]) << 16
            let byte3 = Int(bytes[offset+2]) << 8
            let byte4 = Int(bytes[offset+3])
            offset += 4
            return byte1 | byte2 | byte3 | byte4
        }

        func decodeResourceRecord(
            from bytes: [UInt8], offset: inout Int
        ) throws -> ResourceRecord {
            let name = try decodeName(from: bytes, offset: &offset)
            let type = try decodeType(from: bytes, offset: &offset)
            _ = try decodeClass(from: bytes, offset: &offset)
            let ttl = try decodeTTL(from: bytes, offset: &offset)

            let length = Int(bytes[offset]) << 8 | Int(bytes[offset+1])
            offset += 2

            guard bytes.count >= offset + length else {
                throw DNSError.invalidResourceRecord
            }

            let data: ResourceData
            switch (type, length) {
            case (.a, 4):
                data = .a(IPv4(
                    bytes[offset],
                    bytes[offset+1],
                    bytes[offset+2],
                    bytes[offset+3]))
            case (.aaaa, 16):
                data = .aaaa(IPv6(
                    UInt16(bytes[offset]) | UInt16(bytes[offset+1]),
                    UInt16(bytes[offset+2]) | UInt16(bytes[offset+3]),
                    UInt16(bytes[offset+4]) | UInt16(bytes[offset+5]),
                    UInt16(bytes[offset+6]) | UInt16(bytes[offset+7]),
                    UInt16(bytes[offset+8]) | UInt16(bytes[offset+9]),
                    UInt16(bytes[offset+10]) | UInt16(bytes[offset+11]),
                    UInt16(bytes[offset+12]) | UInt16(bytes[offset+13]),
                    UInt16(bytes[offset+14]) | UInt16(bytes[offset+15])))
            case (.ns, _):
                var copyOffset = offset
                let name = try decodeName(from: bytes, offset: &copyOffset)
                data = .ns(name)
                guard copyOffset == offset + length else {
                    throw DNSError.invalidResourceNSName
                }
            default:
                throw DNSError.invalidResourceRecord
            }
            offset += length

            return ResourceRecord(name: name, ttl: ttl, data: data)
        }

        var answers = [ResourceRecord]()
        for _ in 0..<answerCount {
            answers.append(
                try decodeResourceRecord(from: bytes, offset: &offset))
        }

        var authorities = [ResourceRecord]()
        for _ in 0..<authorityCount {
            authorities.append(
                try decodeResourceRecord(from: bytes, offset: &offset))
        }

        var additional = [ResourceRecord]()
        for _ in 0..<additionalCount {
            additional.append(
                try decodeResourceRecord(from: bytes, offset: &offset))
        }

        self.id = id
        self.type = type
        self.kind = kind
        self.isAuthoritative = isAuthoritative == 1
        self.isTruncated = isTruncated == 1
        self.isRecursionDesired = isRecursionDesired == 1
        self.isRecursionAvailable = isRecursionAvailable == 1
        self.responseCode = responseCode

        self.question = questions
        self.answer = answers
        self.authority = authorities
        self.additional = additional
    }
}
