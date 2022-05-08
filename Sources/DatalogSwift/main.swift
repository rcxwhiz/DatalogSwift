do {
    // TODO this file opening is not right yet
    let tokens = try Lexer.lex(file: "./test.txt")
    let program = try Parser.parse(tokens: tokens)
    print(program)
} catch {
    print(error)
}
