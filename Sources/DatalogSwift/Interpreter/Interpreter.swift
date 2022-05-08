class Interpreter {

    static func interpret(program: DatalogProgram) throws -> [Relation] {
        let database = Database()

        for scheme in program.schemes {
            try database.addRelation(scheme: scheme)
        }

        for fact in program.facts {
            let _ = try database.addFact(fact: fact)
        }

        let ruleGroups = RuleOptimizer.group(rules: program.rules)
        for ruleGroup in ruleGroups {
            var addedTuples = true
            while addedTuples {
                addedTuples = false
                for rule in ruleGroup {
                    let rightHandRelations = try rule.schemes.map { scheme in try database.relations[scheme.name]!.renamePredicate(predicate: scheme) }
                    var joinedRelation = try rightHandRelations.reduce(rightHandRelations[0], { try $0.join(relation: $1) })
                    joinedRelation = try joinedRelation.projectPredicate(predicate: rule.headPredicate)
                    for tuple in joinedRelation.tuples {
                        addedTuples = try database.addTuple(relation: rule.headPredicate.name, tuple: tuple) || addedTuples
                    }
                }
            }
        }

        return try program.queries.map { try database.query(query: $0) }
    }
}
