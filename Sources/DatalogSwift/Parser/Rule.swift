class Rule {
    let headPredicate: Predicate
    let schemes: [Predicate]

    init(headPredicate: Predicate, schemes: [Predicate]) {
        self.headPredicate = headPredicate
        self.schemes = schemes
    }
}
