enum Parameter {
    case string(value: String)
    case id(value: String)
}

class Predicate {
    let name: String
    let parameters: [Parameter]

    init(name: String, parameters: [Parameter]) {
        self.name = name
        self.parameters = parameters
    }
}

extension Predicate: CustomStringConvertible {

    public var description: String {
        var desc = "\(name)("
        for param in parameters {
            switch param {
                case .id(let value):
                    desc.append("\(value),")
                case .string(let value):
                    desc.append("\(value),")
            }
        }
        desc.removeLast()
        desc.append(")")
        return desc
    }
}
