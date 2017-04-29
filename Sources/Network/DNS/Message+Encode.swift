extension Message {
    var bytes: [UInt8] {
        var bytes = [UInt8]()
        encode(to: &bytes)
        return bytes
    }

    func encode(to buffer: inout [UInt8]) {
        let id = UInt16(truncatingBitPattern: self.id)
        buffer.append(UInt8(truncatingBitPattern: id >> 8))
        buffer.append(UInt8(truncatingBitPattern: id))

        var mask: UInt16 = 0

        mask |= type.rawValue << 15
        mask |= kind.rawValue << 11
        mask |= ((isAuthoritative ? 1 : 0) as UInt16) << 10
        mask |= ((isTruncated ? 1 : 0) as UInt16) << 9
        mask |= ((isRecursionDesired ? 1 : 0) as UInt16) << 8
        mask |= ((isRecursionAvailable ? 1 : 0) as UInt16) << 7

        buffer.append(UInt8(truncatingBitPattern: mask >> 8))
        buffer.append(UInt8(truncatingBitPattern: mask))

        let count = UInt16(truncatingBitPattern: question.count)
        buffer.append(UInt8(truncatingBitPattern: count >> 8))
        buffer.append(UInt8(truncatingBitPattern: count))

        buffer.append(0)
        buffer.append(0)

        buffer.append(0)
        buffer.append(0)

        buffer.append(0)
        buffer.append(0)

        for questionRecord in question {
            for part in questionRecord.name.components(separatedBy: ".") {
                buffer.append(UInt8(truncatingBitPattern: part.utf8.count))
                buffer.append(contentsOf: [UInt8](part.utf8))
            }
            buffer.append(0)

            let type = questionRecord.type.rawValue
            buffer.append(UInt8(truncatingBitPattern: type >> 8))
            buffer.append(UInt8(truncatingBitPattern: type))

            let klass = ResourceClass.in.rawValue
            buffer.append(UInt8(truncatingBitPattern: klass >> 8))
            buffer.append(UInt8(truncatingBitPattern: klass))
        }
    }
}
