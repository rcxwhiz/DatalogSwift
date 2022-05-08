print("Hello, world!")

do {
    // TODO this file opening is not right yet
    let tokens = try Lexer.lex(file: "test.txt")
    for token in tokens {
        print(token)
    }
    let program = try Parser.parse(tokens: tokens)
} catch {
    print(error)
}
