do {
    // TODO this file opening is not right yet
    let tokens = try Lexer.lex(file: "./test.txt")
    let program = try Parser.parse(tokens: tokens)
    let queryResults = try Interpreter.interpret(program: program)
    for result in queryResults {
        print(result)
    }
} catch {
    print(error)
}
