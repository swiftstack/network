extension DNS {
    enum Error: Swift.Error {
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
}
