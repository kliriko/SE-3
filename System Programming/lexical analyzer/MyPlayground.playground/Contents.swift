import Foundation

let digits = CharacterSet.decimalDigits
let allowedLetters = CharacterSet(charactersIn: "федоричФЕДОРИЧ")
let operators: Set<Character> = ["+", "-", "*", "/", "(", ")", "=", "<", ">"]
let keywords: Set<String> = ["if", "else", "while"]
let functions: Set<String> = ["sin", "cos"]

enum TokenType: String {
    case identifier = "IDENTIFIER"
    case number     = "NUMBER"
    case keyword    = "KEYWORD"
    case function   = "FUNCTION"
    case `operator` = "OPERATOR"
    case unknown    = "UNKNOWN"
}

struct Token {
    let value: String
    let type: TokenType
}

class Lexer {
    private var input: [Character]
    private var index = 0
    
    init(text: String) {
        self.input = Array(text)
    }
    
    private func peek() -> Character? {
        return index < input.count ? input[index] : nil
    }
    
    private func advance() {
        index += 1
    }
    
    func getNextToken() -> Token? {
        // skip whitespace
        while let ch = peek(), ch.isWhitespace {
            advance()
        }
        guard let ch = peek() else { return nil }
        
        // keywords
        if ch.isLetter && ch.isASCII {
            var buffer = ""
            while let c = peek(), c.isLetter {
                buffer.append(c)
                advance()
            }
            if keywords.contains(buffer) {
                return Token(value: buffer, type: .keyword)
            } else if functions.contains(buffer) {
                return Token(value: buffer, type: .function)
            } else {
                return Token(value: buffer, type: .unknown)
            }
        }
        
        // allowed identifiers
        if ch.unicodeScalars.allSatisfy({ allowedLetters.contains($0) }) {
            var buffer = ""
            while let c = peek(),
                  c.unicodeScalars.allSatisfy({ allowedLetters.contains($0) || digits.contains($0) }) {
                buffer.append(c)
                advance()
            }
            return Token(value: buffer, type: .identifier)
        }
        
        // number literals
        if ch.isNumber {
            var buffer = ""
            var hasDot = false
            while let c = peek() {
                if c.isNumber {
                    buffer.append(c)
                    advance()
                } else if c == ".", !hasDot {
                    buffer.append(c)
                    advance()
                    hasDot = true
                } else {
                    break
                }
            }
            return Token(value: buffer, type: .number)
        }
        
        // operators
        if operators.contains(ch) {
            advance()
            return Token(value: String(ch), type: .operator)
        }
        
        // unknown
        advance()
        return Token(value: String(ch), type: .unknown)
    }
}

let testCases = [
    "if else while",
    
    "sin(x) + cos(y)",
    
    "123 45.67 8+9.0",
    
    "ф1 фед123 р456ич",
    
    "(a+b) * (c-d) / e = f < g > h",
    
    "hello world test",
    
    "if ф123 + 45.6 else cos(фед1) > sin(2)"
]

for code in testCases {
    let lexer = Lexer(text: code)
    print("input:\n \(code)\n\nresult:")
    while let token = lexer.getNextToken() {
        print("\(token.value) → \(token.type.rawValue)")
    }
    print("\n---\n")
}
