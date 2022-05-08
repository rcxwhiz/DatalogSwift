class DatalogProgram {
    let schemes: [Predicate]
    let facts: [Predicate]
    let rules: [Rule]
    let queries: [Predicate]

    init(schemes: [Predicate], facts: [Predicate], rules: [Rule], queries: [Predicate]) {
        self.schemes = schemes
        self.facts = facts
        self.rules = rules
        self.queries = queries
    }
}
