typealias Scheme = [String]
typealias Tuple = [String]

enum RelationError: Error {
    case outOfRangeError(index: Int, size: Int)
    case mismatchedSchemeError(schemeSize: Int, existingSchemeSize: Int)
    case StringInSchemeError(str: String)
}

class Relation {

    let name: String
    let scheme: Scheme
    var tuples: Set<Tuple>

    init(name: String, scheme: Scheme) {
        self.name = name
        self.scheme = scheme
        self.tuples = []
    }

    func addTuple(tuple: Tuple) -> Bool {
        return tuples.insert(tuple).inserted
    }

    func select(selections: [Int: String]) throws -> Relation {
        for index in selections.keys {
            if index < 0 || index >= scheme.count {
                throw RelationError.outOfRangeError(index :index, size: scheme.count)
            }
        }
        let newRelation = Relation(name: name, scheme: scheme)
        for tuple in tuples {
            var add = true
            for (index, value) in selections {
                if tuple[index] != value {
                    add = false
                    break
                }
            }
            if add {
                let _ = newRelation.addTuple(tuple: tuple)
            }
        }
        return newRelation
    }

    func selectDuplicates(indicies: Set<Int>) throws -> Relation {
        for index in indicies {
            if index < 0 || index >= scheme.count {
                throw RelationError.outOfRangeError(index :index, size: scheme.count)
            }
        }
        let newRelation = Relation(name: name, scheme: scheme)
        for tuple in tuples {
            let items = indicies.map { tuple[$0] }
            if items.allSatisfy({ $0 == items.first }) {
                let _ = newRelation.addTuple(tuple: tuple)
            }
        }
        return newRelation
    }

    func projectPredicate(predicate: Predicate) throws -> Relation {
        var scheme: Scheme = []
        for param in predicate.parameters {
            switch param {
                case .id(let value):
                    scheme.append(value)
                case .string(let value):
                    throw RelationError.StringInSchemeError(str: value)
            }
        }
        return try projectScheme(scheme: scheme)
    }

    func projectScheme(scheme: Scheme) throws -> Relation {
        var indecies: Set<Int> = []
        for i in 0..<self.scheme.count {
            if scheme.contains(self.scheme[i]) {
                indecies.insert(i)
            }
        }
        return try project(indicies: indecies)
    }

    func project(indicies: Set<Int>) throws -> Relation {
        for index in indicies {
            if index < 0 || index >= scheme.count {
                throw RelationError.outOfRangeError(index :index, size: scheme.count)
            }
        }
        let sortedIndicies = indicies.sorted()
        let newScheme = sortedIndicies.map { scheme[$0] }
        let newRelation = Relation(name: name, scheme: newScheme)
        for tuple in tuples {
            let _ = newRelation.addTuple(tuple: sortedIndicies.map { tuple[$0] })
        }
        return newRelation
    }

    func renamePredicate(predicate: Predicate) throws -> Relation {
        var scheme: Scheme = []
        for param in predicate.parameters {
            switch param {
                case .id(let value):
                    scheme.append(value)
                case .string(let value):
                    throw RelationError.StringInSchemeError(str: value)
            }
        }
        return try rename(scheme: scheme)
    }

    func rename(scheme: Scheme) throws -> Relation {
        if self.scheme.count != scheme.count {
            throw RelationError.mismatchedSchemeError(schemeSize: scheme.count, existingSchemeSize: self.scheme.count)
        }
        let newRelation = Relation(name: name, scheme: scheme)
        for tuple in tuples {
            let _ = newRelation.addTuple(tuple: tuple)
        }
        return newRelation
    }

    func join(relation: Relation) throws -> Relation {
        // TODO add some code here to handle the case that the relations are the same

        var matchingIndicies: [(Int, Int)] = []
        for i in 0..<scheme.count {
            for j in 0..<relation.scheme.count {
                if scheme[i] == relation.scheme[j] {
                    matchingIndicies.append((i, j))
                }
            }
        }

        var newScheme = scheme
        for i in 0..<relation.scheme.count {
            var add = true
            for matchingIndex in matchingIndicies {
                if i == matchingIndex.1 {
                    add = false
                    break
                }
            }
            if add {
                newScheme.append(relation.scheme[i])
            }
        }
        let newRelation = Relation(name: name, scheme: newScheme)

        for tuple in tuples {
            for otherTuple in relation.tuples {
                if let newTuple = try joinArrays(ar1: tuple, ar2: otherTuple, matching: matchingIndicies) {
                    let _ = newRelation.addTuple(tuple: newTuple)
                }
            }
        }

        return newRelation
    }
}

extension Relation {
    private func joinArrays<Element>(ar1: [Element], ar2: [Element], matching: [(Int, Int)]) throws -> [Element]? where Element: Equatable {
        for indexPair in matching {
            if indexPair.0 < 0 || indexPair.0 >= ar1.count {
                throw RelationError.outOfRangeError(index: indexPair.0, size: ar1.count)
            }
            if indexPair.1 < 0 || indexPair.1 >= ar2.count {
                throw RelationError.outOfRangeError(index: indexPair.1, size: ar2.count)
            }
        }

        for indexPair in matching {
            if ar1[indexPair.0] != ar2[indexPair.1] {
                return nil
            }
        }

        var newAr = ar1
        for i in 0..<ar2.count {
            var add = true
            for matchingIndex in matching {
                if i == matchingIndex.1 {
                    add = false
                    break
                }
            }
            if add {
                newAr.append(ar2[i])
            }
        }

        return newAr
    }
}

extension Relation: CustomStringConvertible {

    public var description: String {
        var desc = "\(name) (\(tuples.count))"
        for tuple in tuples {
            desc.append("\n")
            for i in 0..<scheme.count {
                desc.append("\(scheme[i])=\(tuple[i]),")
            }
            desc.removeLast()
        }
        return desc
    }
}
