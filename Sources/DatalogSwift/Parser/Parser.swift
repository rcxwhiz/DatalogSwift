enum ParserError: Error {
    case unexpectedToken(token: Token, expected: [TokenType])
    case unexpectedNoToken(expected: [TokenType])
}

class Parser {

    static func parse(tokens: [Token]) throws -> DatalogProgram {
        let iterator = tokens.makePeekableIterator()

        var schemes: [Predicate] = []
        var facts: [Predicate] = []
        var rules: [Rule] = []
        var queries: [Predicate] = []

        let _ = try requriedToken(iter: iterator, expectedType: .schemes)
        let _ = try requriedToken(iter: iterator, expectedType: .colon)

        if let scheme = try scheme(iter: iterator) {
            schemes.append(scheme)
        } else {
            if let token = iterator.next() {
                throw ParserError.unexpectedToken(token: token, expected: [.id])
            } else {
                throw ParserError.unexpectedNoToken(expected: [.id])
            }
        }
        schemes.append(contentsOf: try schemeList(iter: iterator))

        let _ = try requriedToken(iter: iterator, expectedType: .facts)
        let _ = try requriedToken(iter: iterator, expectedType: .colon)

        facts.append(contentsOf: try factList(iter: iterator))

        let _ = try requriedToken(iter: iterator, expectedType: .rules)
        let _ = try requriedToken(iter: iterator, expectedType: .colon)

        rules.append(contentsOf: try ruleList(iter: iterator))

        let _ = try requriedToken(iter: iterator, expectedType: .queries)
        let _ = try requriedToken(iter: iterator, expectedType: .colon)

        if let query = try query(iter: iterator) {
            queries.append(query)
        } else {
            if let token = iterator.next() {
                throw ParserError.unexpectedToken(token: token, expected: [.id])
            } else {
                throw ParserError.unexpectedNoToken(expected: [.id])
            }
        }
        queries.append(contentsOf: try queryList(iter: iterator))

        return DatalogProgram(schemes: schemes, facts: facts, rules: rules, queries: queries)
    }
}

extension Parser {

    private typealias TokenIterator = PeekableIterator<Array<Token>.Iterator>

    private static func schemeList(iter: TokenIterator) throws -> [Predicate] {
        var schemes: [Predicate] = []
        try schemeListRec(iter: iter, schemes: &schemes)
        return schemes
    }
    private static func schemeListRec(iter: TokenIterator, schemes: inout [Predicate]) throws {
        if let scheme = try scheme(iter: iter) {
            schemes.append(scheme)
            try schemeListRec(iter: iter, schemes: &schemes)
        }
    }
    
    private static func factList(iter: TokenIterator) throws -> [Predicate] {
        var facts: [Predicate] = []
        try factListRec(iter: iter, facts: &facts)
        return facts
    }
    private static func factListRec(iter: TokenIterator, facts: inout [Predicate]) throws {
        if let fact = try fact(iter: iter) {
            facts.append(fact)
            try factListRec(iter: iter, facts: &facts)
        }
    }

    private static func ruleList(iter: TokenIterator) throws -> [Rule] {
        var rules: [Rule] = []
        try ruleListRec(iter: iter, rules: &rules)
        return rules
    }
    private static func ruleListRec(iter: TokenIterator, rules: inout [Rule]) throws {
        if let rule = try rule(iter: iter) {
            rules.append(rule)
            try ruleListRec(iter: iter, rules: &rules)
        }
    }

    private static func queryList(iter: TokenIterator) throws -> [Predicate] {
        var queries: [Predicate] = []
        try queryListRec(iter: iter, queries: &queries)
        return queries
    }
    private static func queryListRec(iter: TokenIterator, queries: inout [Predicate]) throws {
        if let query = try query(iter: iter) {
            queries.append(query)
            try queryListRec(iter: iter, queries: &queries)
        }
    }

    private static func scheme(iter: TokenIterator) throws -> Predicate? {
        if let head = optionalToken(iter: iter, expectedType: .id) {
            let _ = try requriedToken(iter: iter, expectedType: .leftParenthesis)
            if let firstID = iter.next() {
                var ids: [Parameter] = []
                switch firstID.type {
                    case .id:
                        ids.append(.id(value: firstID.value))
                    default:
                        throw ParserError.unexpectedToken(token: firstID, expected: [.id])
                }
                ids.append(contentsOf: try idList(iter: iter))
                let _ = try requriedToken(iter: iter, expectedType: .rightParenthesis)
                return Predicate(name: head.value, parameters: ids)
            } else {
                throw ParserError.unexpectedNoToken(expected: [.id])
            }
        } else {
            return nil
        }
    }

    private static func fact(iter: TokenIterator) throws -> Predicate? {
        if let head = optionalToken(iter: iter, expectedType: .id) {
            let _ = try requriedToken(iter: iter, expectedType: .leftParenthesis)
            if let firstString = iter.next() {
                var strings: [Parameter] = []
                switch firstString.type {
                    case .string:
                        strings.append(.string(value: firstString.value))
                    default:
                        throw ParserError.unexpectedToken(token: firstString, expected: [.string])
                }
                strings.append(contentsOf: try stringList(iter: iter))
                let _ = try requriedToken(iter: iter, expectedType: .rightParenthesis)
                let _ = try requriedToken(iter: iter, expectedType: .period)
                return Predicate(name: head.value, parameters: strings)
            } else {
                throw ParserError.unexpectedNoToken(expected: [.string])
            }
        } else {
            return nil
        }
    }

    private static func rule(iter: TokenIterator) throws -> Rule? {
        if let headPredicate = try headPredicate(iter: iter) {
            let _ = try requriedToken(iter: iter, expectedType: .colonDash)
            var predicates = [try predicate(iter: iter, optional: false)!]
            predicates.append(contentsOf: try predicateList(iter: iter))
            let _ = try requriedToken(iter: iter, expectedType: .period)
            return Rule(headPredicate: headPredicate, schemes: predicates)
        } else {
            return nil
        }
    }

    private static func query(iter: TokenIterator) throws -> Predicate? {
        if let predicate = try predicate(iter: iter, optional: false) {
            let _ = try requriedToken(iter: iter, expectedType: .questionMark)
            return predicate
        } else {
            return nil
        }
    }

    private static func headPredicate(iter: TokenIterator) throws -> Predicate? {
        if let nameToken = optionalToken(iter: iter, expectedType: .id) {
            let _ = try requriedToken(iter: iter, expectedType: .leftParenthesis)
            var ids: [Parameter] = [.id(value: (try requriedToken(iter: iter, expectedType: .id)).value)]
            ids.append(contentsOf: try idList(iter: iter))
            let _ = try requriedToken(iter: iter, expectedType: .rightParenthesis)
            return Predicate(name: nameToken.value, parameters: ids)
        } else {
            return nil
        }
    }

    private static func predicate(iter: TokenIterator, optional: Bool) throws -> Predicate? {
        if let nameToken = optionalToken(iter: iter, expectedType: .id) {
            let _ = try requriedToken(iter: iter, expectedType: .leftParenthesis)
            var parameters = [try parameter(iter: iter)]
            parameters.append(contentsOf: try paramList(iter: iter))
            let _ = try requriedToken(iter: iter, expectedType: .rightParenthesis)
            return Predicate(name: nameToken.value, parameters: parameters)
        } else {
            if optional {
                return nil
            } else {
                if let nextToken = iter.next() {
                    throw ParserError.unexpectedToken(token: nextToken, expected: [.id])
                } else {
                    throw ParserError.unexpectedNoToken(expected: [.id])
                }
            }
        }
    }

    private static func predicateList(iter: TokenIterator) throws -> [Predicate] {
        var predicates: [Predicate] = []
        try predicateListRec(iter: iter, predicateList: &predicates)
        return predicates
    }
    private static func predicateListRec(iter: TokenIterator, predicateList: inout [Predicate]) throws {
        if let _ = optionalToken(iter: iter, expectedType: .comma) {
            if let nextPredicate = try predicate(iter: iter, optional: false) {
                predicateList.append(nextPredicate)
            }
            try predicateListRec(iter: iter, predicateList: &predicateList)
        }
    }

    private static func paramList(iter: TokenIterator) throws -> [Parameter] {
        var params: [Parameter] = []
        try paramListRec(iter: iter, paramList: &params)
        return params
    }
    private static func paramListRec(iter: TokenIterator, paramList: inout [Parameter]) throws {
        if let _ = optionalToken(iter: iter, expectedType: .comma) {
            if let token = iter.next() {
                switch token.type {
                    case .id:
                        paramList.append(.id(value: token.value))
                    case .string:
                        paramList.append(.string(value: token.value))
                    default:
                        throw ParserError.unexpectedToken(token: token, expected: [.id, .string])
                }
                try paramListRec(iter: iter, paramList: &paramList)
            }
        }
    }

    private static func stringList(iter: TokenIterator) throws -> [Parameter] {
        var strings: [Parameter] = []
        try stringListRec(iter: iter, stringList: &strings)
        return strings
    }
    private static func stringListRec(iter: TokenIterator, stringList: inout [Parameter]) throws {
        if let _ = optionalToken(iter: iter, expectedType: .comma) {
            if let token = iter.next() {
                switch token.type {
                    case .string:
                        stringList.append(.string(value: token.value))
                    default:
                        throw ParserError.unexpectedToken(token: token, expected: [.string])
                }
                try stringListRec(iter: iter, stringList: &stringList)
            } else {
                throw ParserError.unexpectedNoToken(expected: [.string])
            }
        }
    }

    private static func idList(iter: TokenIterator) throws -> [Parameter] {
        var ids: [Parameter] = []
        try idListRec(iter: iter, idList: &ids)
        return ids
    }
    private static func idListRec(iter: TokenIterator, idList: inout [Parameter]) throws {
        if let _ = optionalToken(iter: iter, expectedType: .comma) {
            if let token = iter.next() {
                switch token.type {
                    case .id:
                        idList.append(.id(value: token.value))
                    default:
                        throw ParserError.unexpectedToken(token: token, expected: [.id])
                }
                try idListRec(iter: iter, idList: &idList)
            } else {
                throw ParserError.unexpectedNoToken(expected: [.id])
            }
        }
    }

    private static func parameter(iter: TokenIterator) throws -> Parameter {
        if let token = iter.next() {
            switch token.type {
                case .id:
                    return .id(value: token.value)
                case .string:
                    return .string(value: token.value)
                default:
                    throw ParserError.unexpectedToken(token: token, expected: [.id, .string])
            }
        } else {
            throw ParserError.unexpectedNoToken(expected: [.id, .string])
        }
    }

    private static func requriedToken(iter: TokenIterator, expectedType: TokenType) throws -> Token {
        if let token = iter.next() {
            if token.type == expectedType {
                return token
            } else {
                throw ParserError.unexpectedToken(token: token, expected: [expectedType])
            }
        } else {
            throw ParserError.unexpectedNoToken(expected: [expectedType])
        }
    }

    private static func optionalToken(iter: TokenIterator, expectedType: TokenType) -> Token? {
        if let token = iter.peek(), token.type == expectedType {
            return iter.next()
        } else {
            return nil
        }
    }
}
