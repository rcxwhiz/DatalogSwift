class Rule {
    let headPredicate: Predicate
    let schemes: [Predicate]

    init(headPredicate: Predicate, schemes: [Predicate]) {
        self.headPredicate = headPredicate
        self.schemes = schemes
    }
}

extension Rule: CustomStringConvertible {

    public var description: String {
        var desc = "\(headPredicate) :- "
        for scheme in schemes {
            desc.append("\(scheme),")
        }
        desc.removeLast()
        desc.append(".")
        return desc
    }
}
