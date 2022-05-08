class PeekableIterator<Base: IteratorProtocol> : IteratorProtocol {

    var peeked: Base.Element?
    var iterator: Base

    public init(_ base: Base) {
        iterator = base
        peeked = iterator.next()
    }

    public func peek() -> Base.Element? {
        return peeked
    }

    public func next() -> Base.Element? {
        let result = peeked

        if peeked != nil {
            peeked = iterator.next()
        }

        return result
    }
}

extension Sequence {
    func makePeekableIterator() -> PeekableIterator<Self.Iterator> {
        return PeekableIterator(self.makeIterator())
    }
}
