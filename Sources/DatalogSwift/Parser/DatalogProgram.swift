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

extension DatalogProgram: CustomStringConvertible {

    public var description: String {
        var desc = "Schemes(\(schemes.count)):"
        for scheme in schemes {
            desc.append("\n  \(scheme)")
        }
        desc.append("\nFacts(\(facts.count)):")
        for fact in facts {
            desc.append("\n  \(fact).")
        }
        desc.append("\nRules(\(rules.count)):")
        for rule in rules {
            desc.append("\n  \(rule)")
        }
        desc.append("\nQueries(\(queries.count)):")
        for query in queries {
            desc.append("\n  \(query)?")
        }
        return desc
    }
}
