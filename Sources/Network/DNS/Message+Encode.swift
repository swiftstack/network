extension Message {
    var bytes: [UInt8] {
        var bytes = [UInt8]()
        encode(to: &bytes)
        return bytes
    }

    func encode(to buffer: inout [UInt8]) {
        let id = UInt16(truncatingIfNeeded: self.id)
        buffer.append(UInt8(truncatingIfNeeded: id >> 8))
        buffer.append(UInt8(truncatingIfNeeded: id))

        var mask: UInt16 = 0

        mask |= type.rawValue << 15
        mask |= kind.rawValue << 11
        mask |= ((isAuthoritative ? 1 : 0) as UInt16) << 10
        mask |= ((isTruncated ? 1 : 0) as UInt16) << 9
        mask |= ((isRecursionDesired ? 1 : 0) as UInt16) << 8
        mask |= ((isRecursionAvailable ? 1 : 0) as UInt16) << 7

        buffer.append(UInt8(truncatingIfNeeded: mask >> 8))
        buffer.append(UInt8(truncatingIfNeeded: mask))

        let count = UInt16(truncatingIfNeeded: question.count)
        buffer.append(UInt8(truncatingIfNeeded: count >> 8))
        buffer.append(UInt8(truncatingIfNeeded: count))

        buffer.append(0)
        buffer.append(0)

        buffer.append(0)
        buffer.append(0)

        buffer.append(0)
        buffer.append(0)

        for questionRecord in question {
            for part in questionRecord.name.split(separator: ".") {
                buffer.append(UInt8(truncatingIfNeeded: part.utf8.count))
                buffer.append(contentsOf: [UInt8](part.utf8))
            }
            buffer.append(0)

            let type = questionRecord.type.rawValue
            buffer.append(UInt8(truncatingIfNeeded: type >> 8))
            buffer.append(UInt8(truncatingIfNeeded: type))

            let klass = ResourceClass.in.rawValue
            buffer.append(UInt8(truncatingIfNeeded: klass >> 8))
            buffer.append(UInt8(truncatingIfNeeded: klass))
        }
    }
}
