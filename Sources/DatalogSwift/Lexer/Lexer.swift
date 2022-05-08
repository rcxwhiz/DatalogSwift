import Foundation

class Lexer {

    static func lex(file: String) throws -> [Token] {

        let fileContents = try String(contentsOfFile: file)
        var tokens: [Token] = []
        let iterator = fileContents.makePeekableIterator()
        var lineNum: UInt = 1

        while let ch = iterator.next() {
            switch (ch) {
                case ",":
                    tokens.append(Token(type: .comma, value: ",", lineNum: lineNum))
                case ".":
                    tokens.append(Token(type: .period, value: ".", lineNum: lineNum))
                case "?":
                    tokens.append(Token(type: .questionMark, value: "?", lineNum: lineNum))
                case "(":
                    tokens.append(Token(type: .leftParenthesis, value: "(", lineNum: lineNum))
                case ")":
                    tokens.append(Token(type: .rightParenthesis, value: ")", lineNum: lineNum))
                case "*":
                    tokens.append(Token(type: .multiply, value: "*", lineNum: lineNum))
                case "+":
                    tokens.append(Token(type: .add, value: "+", lineNum: lineNum))
                case ":":
                    if iterator.peek() == "-" {
                        let _ = iterator.next()
                        tokens.append(Token(type: .colonDash, value: ":-", lineNum: lineNum))
                    } else {
                        tokens.append(Token(type: .colon, value: ":", lineNum: lineNum))
                    }
                case "#":
                    tokens.append(lexComment(iter: iterator, lineNum: &lineNum))
                case "'":
                    tokens.append(lexString(iter: iterator, lineNum: &lineNum))
                default:
                    if ch.isLetter {
                        tokens.append(lexID(iter: iterator, lineNum: lineNum, start: ch))
                    } else if !ch.isWhitespace {
                        tokens.append(Token(type: .undefined, value: String(ch), lineNum: lineNum))
                    }
            }
        }

        tokens.append(Token(type: .eof, value: "", lineNum: lineNum))
        return tokens
    }

    private static func lexComment(iter: PeekableIterator<String.Iterator>, lineNum: inout UInt) -> Token {
        if iter.peek() == "|" {
            return lexBlockComment(iter: iter, lineNum: &lineNum)
        }

        var commentValue = "#"
        let beginningLine = lineNum

        while let ch = iter.next() {
            if ch == "\n" {
                lineNum += 1
                break
            }
            commentValue.append(ch)
        }
        return Token(type: .comment, value: commentValue, lineNum: beginningLine)
    }

    private static func lexBlockComment(iter: PeekableIterator<String.Iterator>, lineNum: inout UInt) -> Token {
        var commentValue = "#|"
        let beginningLine = lineNum
        let _ = iter.next()

        while let ch = iter.next() {
            if ch == "|" && iter.peek() == "#" {
                let _ = iter.next()
                commentValue.append("|#")
                return Token(type: .comment, value: commentValue, lineNum: beginningLine)
            }
            if ch == "\n" {
                lineNum += 1
            }
            commentValue.append(ch)
        }

        return Token(type: .unterimnatedBlockComment, value: commentValue, lineNum: beginningLine)
    }

    private static func lexString(iter: PeekableIterator<String.Iterator>, lineNum: inout UInt) -> Token {
        var stringValue = "'"
        let beginningLine = lineNum

        while let ch = iter.next() {
            stringValue.append(ch)

            if ch == "\n" {
                lineNum += 1
            } else if ch == "'" {
                return Token(type: .string, value: stringValue, lineNum: beginningLine)
            }
        }

        return Token(type: .unterminatedString, value: stringValue, lineNum: beginningLine)
    }

    private static func lexID(iter: PeekableIterator<String.Iterator>, lineNum: UInt, start: Character) -> Token {
        var idValue = String(start)
        
        while let ch = iter.peek(), ch.isAlphanumeric {
            idValue.append(ch)
            let _ = iter.next()
        }

        switch idValue {
            case "Schemes":
                return Token(type: .schemes, value: idValue, lineNum: lineNum)
            case "Facts":
                return Token(type: .facts, value: idValue, lineNum: lineNum)
            case "Rules":
                return Token(type: .rules, value: idValue, lineNum: lineNum)
            case "Queries":
                return Token(type: .queries, value: idValue, lineNum: lineNum)
            default:
                return Token(type: .id, value: idValue, lineNum: lineNum)
        }
    }
}
