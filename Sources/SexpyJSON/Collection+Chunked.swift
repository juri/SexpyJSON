extension Collection where Index: Strideable {
    /// Iterate over collection elements in chunks of 2.
    ///
    /// - Note: Assumes you have ensured the collection has an even number of elements. Will crash otherwise.
    func chunk2() -> Chunk2Sequence<Self> {
        Chunk2Sequence(collection: self)
    }
}

/// Chunked iterator for collections with chunk size of 2.
struct Chunk2Sequence<C>: Sequence, IteratorProtocol where C: Collection, C.Index: Strideable {
    private let collection: C
    private var indexIterator: StrideToIterator<C.Index>

    init(collection: C) {
        self.collection = collection
        self.indexIterator = stride(from: collection.startIndex, to: collection.endIndex, by: 2).makeIterator()
    }

    mutating func next() -> (C.Element, C.Element)? {
        guard let nextStart = self.indexIterator.next() else { return nil }
        return (self.collection[nextStart], self.collection[nextStart.advanced(by: 1)])
    }
}
