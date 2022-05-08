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
        var desc = "Schemes(\(schemes.count)):\n"
        for scheme in schemes {
            desc.append("  \(scheme)\n")
        }
        desc.append("Facts(\(facts.count)):\n")
        for fact in facts {
            desc.append("  \(fact).\n")
        }
        desc.append("Rules(\(rules.count)):\n")
        for rule in rules {
            desc.append("  \(rule)\n")
        }
        desc.append("Queries(\(queries.count)):\n")
        for query in queries {
            desc.append("  \(query)?\n")
        }
        return desc
    }
}
