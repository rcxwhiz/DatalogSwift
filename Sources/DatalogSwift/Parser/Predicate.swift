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
