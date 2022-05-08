enum TokenType {
    case comma,
    period,
    questionMark,
    leftParenthesis,
    rightParenthesis,
    colon,
    colonDash,
    multiply,
    add,
    schemes,
    facts,
    rules,
    queries,
    id,
    string,
    comment,
    undefined,
    eof,
    unterimnatedBlockComment,
    unterminatedString
}

struct Token {

    let type: TokenType
    let value: String
    let lineNum: UInt
}

extension Token: CustomStringConvertible {

    public var description: String {
        return "\(String(describing: type)), \"\(value)\", \(lineNum)"
    }
}
