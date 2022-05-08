enum DatabaseError: Error {
    case RelationNotFoundError(name: String)
    case RelationExistsError(name: String)
    case InvalidScheme(scheme: Predicate)
    case InvalidFact(fact: Predicate)
}

class Database {

    var relations: [String: Relation] = [:]

    func addRelation(scheme: Predicate) throws {
        if let _ = relations[scheme.name] {
            throw DatabaseError.RelationExistsError(name: scheme.name)
        }
        var s: Scheme = []
        for param in scheme.parameters {
            switch param {
                case .id(let value):
                    s.append(value)
                default:
                    throw DatabaseError.InvalidScheme(scheme: scheme)
            }
        }
        relations[scheme.name] = Relation(name: scheme.name, scheme: s)
    }

    func addFact(fact: Predicate) throws -> Bool {
        var t: Tuple = []
        for param in fact.parameters {
            switch param {
                case .string(let value):
                    t.append(value)
                default:
                    throw DatabaseError.InvalidFact(fact: fact)
            }
        }
        return try addTuple(relation: fact.name, tuple: t)
    }

    func addTuple(relation: String, tuple: Tuple) throws -> Bool {
        if let relation = relations[relation] {
            return relation.addTuple(tuple: tuple)
        } else {
            throw DatabaseError.RelationNotFoundError(name: relation)
        }
    }

    func query(query: Predicate) throws -> Relation {
        if let relation = relations[query.name] {
            var selection: [Int: String] = [:]
            var projection: Set<Int> = []
            var rename: Scheme = []
            for i in 0..<query.parameters.count {
                switch query.parameters[i] {
                    case .id(let value):
                        projection.insert(i)
                        rename.append(value)
                    case .string(let value):
                        selection[i] = value
                }
            }
            var d = try relation.select(selections: selection)
            d = try d.project(indicies: projection)
            d = try d.rename(scheme: rename)
            return d
        } else {
            throw DatabaseError.RelationNotFoundError(name: query.name)
        }
    }
}
