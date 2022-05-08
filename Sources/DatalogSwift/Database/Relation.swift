typealias Scheme = [String]
typealias Tuple = [String]

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

    func select(index: Int, value: String) -> Relation {
        let newRelation = Relation(name: name, scheme: scheme)
        for tuple in tuples {
            if tuple[index] == value {
                let _ = newRelation.addTuple(tuple: tuple)
            }
        }
        return newRelation
    }
}

extension Relation: CustomStringConvertible {

    public var description: String {
        var desc = "\(name)\n\(scheme.joined(separator: ","))"
        for tuple in tuples {
            desc.append("\n\(tuple.joined(separator: ","))")
        }
        return desc
    }
}
