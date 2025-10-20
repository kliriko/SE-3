import SwiftUI
import PlaygroundSupport

// MARK: - Лексичний аналізатор

enum TokenType: Equatable {
    case keyword(String)
    case identifier(String)
    case comma
    case leftParen
    case rightParen
    case eof
}

struct Token {
    let type: TokenType
    let value: String
}

class Lexer {
    private let input: String
    private var position = 0
    private var currentChar: Character?
    
    private let keywords = [
        "ПРОВЕСТИ", "ПРОВЕСТ", "ПРЯМУ", "ПРЯМ", "ЧЕРЕЗ",
        "ДВІ", "ДВ", "ТОЧКИ", "ТОЧК", "ПОБУДУВАТИ", "ПОБУДУВА",
        "ПЕРПЕНДИКУЛЯР", "ДО", "В", "У",
        "ТРИКУТНИК", "ПО", "ТРЬОМ", "ТРЬОХ",
        "ВЕРШИНАМ", "ВЕРШИН", "ПАРАЛЕЛЬНУ", "ПАРАЛЕЛЬН", "ПРЯМОЇ"
    ]
    
    init(_ input: String) {
        self.input = input.uppercased()
        self.currentChar = input.isEmpty ? nil : Array(self.input)[0]
    }
    
    private func advance() {
        position += 1
        if position >= input.count {
            currentChar = nil
        } else {
            currentChar = Array(input)[position]
        }
    }
    
    private func skipWhitespace() {
        while currentChar != nil && currentChar!.isWhitespace {
            advance()
        }
    }
    
    private func readWord() -> String {
        var result = ""
        while currentChar != nil && (currentChar!.isLetter || currentChar == "І" || currentChar == "Ї" || currentChar == "Є") {
            result.append(currentChar!)
            advance()
        }
        return result
    }
    
    func getNextToken() -> Token {
        while currentChar != nil {
            if currentChar!.isWhitespace {
                skipWhitespace()
                continue
            }
            
            if currentChar == "," {
                advance()
                return Token(type: .comma, value: ",")
            }
            
            if currentChar == "(" {
                advance()
                return Token(type: .leftParen, value: "(")
            }
            
            if currentChar == ")" {
                advance()
                return Token(type: .rightParen, value: ")")
            }
            
            if currentChar!.isLetter || currentChar == "І" || currentChar == "Ї" || currentChar == "Є" {
                let word = readWord()
                
                let isKeyword = keywords.contains { kw in
                    word.hasPrefix(kw) || kw.hasPrefix(word)
                }
                
                if isKeyword {
                    return Token(type: .keyword(word), value: word)
                }
                
                return Token(type: .identifier(word), value: word)
            }
            
            advance()
        }
        
        return Token(type: .eof, value: "")
    }
}

// MARK: - Синтаксичний аналізатор

enum ASTNode: CustomStringConvertible {
    case drawLine(point1: String, point2: String)
    case drawPerpendicular(line: (String, String), point: String, intersection: String)
    case drawTriangle(point1: String, point2: String, point3: String)
    case drawParallel(line: (String, String), throughPoint: String)
    
    var description: String {
        switch self {
        case .drawLine(let p1, let p2):
            return "DrawLine(\(p1), \(p2))"
        case .drawPerpendicular(let line, let point, _):
            return "DrawPerpendicular((\(line.0)\(line.1)), at: \(point))"
        case .drawTriangle(let p1, let p2, let p3):
            return "DrawTriangle(\(p1), \(p2), \(p3))"
        case .drawParallel(let line, let point):
            return "DrawParallel((\(line.0)\(line.1)), through: \(point))"
        }
    }
}

class Parser {
    private var currentToken: Token
    private let lexer: Lexer
    var log: String = ""
    private var needsSkipWhitespace = false
    
    init(_ lexer: Lexer) {
        self.lexer = lexer
        self.currentToken = lexer.getNextToken()
    }
    
    private func matchesKeyword(_ keyword: String) -> Bool {
        if case .keyword(let kw) = currentToken.type {
            return kw.hasPrefix(keyword) || keyword.hasPrefix(kw)
        }
        return false
    }
    
    private func eat(_ expectedType: TokenType) {
        log += "Eating: \(currentToken.value) "
        currentToken = lexer.getNextToken()
        needsSkipWhitespace = true
    }
    
    private func eatKeyword(_ keyword: String) {
        if matchesKeyword(keyword) {
            eat(.keyword(""))
        }
    }
    
    private func parseIdentifier() -> String {
        skipWhitespaceIfNeeded()
        
        if case .identifier(let id) = currentToken.type {
            log += "ID: \(id) "
            let result = id
            eat(.identifier(""))
            return result
        }
        
        // Якщо наступний токен - букви, але не keyword
        if case .keyword(let kw) = currentToken.type, kw.allSatisfy({ $0.isLetter }) {
            log += "ID: \(kw) "
            let result = kw
            eat(.keyword(""))
            return result
        }
        
        return ""
    }

    private func skipWhitespaceIfNeeded() {
        while case .keyword(let kw) = currentToken.type, kw == "" || kw.allSatisfy({ $0.isWhitespace }) {
            currentToken = lexer.getNextToken()
        }
    }
    
    func parse() -> [ASTNode] {
        var nodes: [ASTNode] = []
        
        while case .keyword = currentToken.type {
            log += "\n[Parsing command] "
            
            if matchesKeyword("ПРОВЕСТ") {
                log += "Found ПРОВЕСТИ -> "
                let node = parseDrawLine()
                nodes.append(node)
                log += "Result: \(node.description)"
            } else if matchesKeyword("ПОБУДУВА") {
                log += "Found ПОБУДУВАТИ -> "
                eatKeyword("ПОБУДУВА") // ✅ ВИПРАВЛЕНО: з'їсти ПОБУДУВАТИ
                
                // ✅ ВИПРАВЛЕНО: перевірка ПЕРШЕ, потім решта
                if matchesKeyword("ПЕРПЕНДИКУЛЯР") {
                    log += "ПЕРПЕНДИКУЛЯР -> "
                    let node = parsePerpendicular()
                    nodes.append(node)
                    log += "Result: \(node.description)"
                } else if matchesKeyword("ПАРАЛЕЛЬН") {
                    log += "ПАРАЛЕЛЬНУ -> "
                    let node = parseParallel()
                    nodes.append(node)
                    log += "Result: \(node.description)"
                } else if matchesKeyword("ТРИКУТНИК") {
                    log += "ТРИКУТНИК -> "
                    let node = parseTriangle()
                    nodes.append(node)
                    log += "Result: \(node.description)"
                }
            } else {
                eat(.keyword(""))
            }
        }
        
        return nodes
    }
    
    private func parseDrawLine() -> ASTNode {
        eatKeyword("ПРОВЕСТ")
        eatKeyword("ПРЯМ")
        eatKeyword("ЧЕРЕЗ")
        eatKeyword("ДВ")
        eatKeyword("ТОЧК")
        
        let point1 = parseIdentifier()
        eat(.comma)
        let point2 = parseIdentifier()
        
        return .drawLine(point1: point1, point2: point2)
    }
    
    private func parsePerpendicular() -> ASTNode {
        eatKeyword("ПЕРПЕНДИКУЛЯР")
        eatKeyword("ДО")
        eatKeyword("ПРЯМ")

        eat(.leftParen)
        let p1 = parseIdentifier()  // A
        let p2 = parseIdentifier()  // B
        eat(.rightParen)

        eatKeyword("В")
        eatKeyword("ТОЧК")

        // 🔧 Після "ТОЧКІ" потрібно зчитати наступний токен — це і буде D
        let point = parseIdentifier()

        return .drawPerpendicular(line: (p1, p2), point: point, intersection: point)
    }

    
    private func parseTriangle() -> ASTNode {
        eatKeyword("ТРИКУТНИК")
        eatKeyword("ПО")
        eatKeyword("ТРЬОМ")
        eatKeyword("ВЕРШИН")
        
        let p1 = parseIdentifier()
        eat(.comma)
        let p2 = parseIdentifier()
        eat(.comma)
        let p3 = parseIdentifier()
        
        return .drawTriangle(point1: p1, point2: p2, point3: p3)
    }
    
    private func parseParallel() -> ASTNode {
        eatKeyword("ПАРАЛЕЛЬН")
        eatKeyword("ПРЯМ")
        eatKeyword("ДО")
        eatKeyword("ПРЯМ")

        eat(.leftParen)
        let p1 = parseIdentifier()
        let p2 = parseIdentifier()
        eat(.rightParen)

        eatKeyword("ЧЕРЕЗ")
        eatKeyword("ТОЧК")

        // 🔧 Зчитати E після "ТОЧКУ"
        let point = parseIdentifier()

        return .drawParallel(line: (p1, p2), throughPoint: point)
    }

}

// MARK: - Геометрія

struct Point: Hashable {
    let x: CGFloat
    let y: CGFloat
    let name: String
}

struct Line: Identifiable {
    let id = UUID()
    let from: Point
    let to: Point
}

struct Triangle: Identifiable {
    let id = UUID()
    let p1: Point
    let p2: Point
    let p3: Point
}

class GeometryInterpreter: ObservableObject {
    @Published var points: [Point] = []
    @Published var lines: [Line] = []
    @Published var triangles: [Triangle] = []
    
    private var pointMap: [String: Point] = [:]
    var executionLog: String = ""
    
    init() {
        setupDefaultPoints()
    }
    
    private func setupDefaultPoints() {
        let defaultPoints = [
            ("A", CGPoint(x: 100, y: 100)),
            ("B", CGPoint(x: 400, y: 100)),
            ("C", CGPoint(x: 250, y: 300)),
            ("D", CGPoint(x: 250, y: 150)),
            ("E", CGPoint(x: 150, y: 200))
        ]
        
        for (name, pos) in defaultPoints {
            let point = Point(x: pos.x, y: pos.y, name: name)
            points.append(point)
            pointMap[name] = point
        }
    }
    
    func execute(nodes: [ASTNode]) {
        lines.removeAll()
        triangles.removeAll()
        executionLog = ""
        
        executionLog += "Executing \(nodes.count) commands:\n"
        
        for (index, node) in nodes.enumerated() {
            executionLog += "\n[\(index + 1)] \(node.description)\n"
            
            switch node {
            case .drawLine(let p1, let p2):
                drawLine(from: p1, to: p2)
                
            case .drawPerpendicular(let line, let point, let intersection):
                drawPerpendicular(to: line, at: point, intersection: intersection)
                
            case .drawTriangle(let p1, let p2, let p3):
                drawTriangle(p1: p1, p2: p2, p3: p3)
                
            case .drawParallel(let line, let throughPoint):
                drawParallel(to: line, through: throughPoint)
            }
        }
        
        executionLog += "\n\nФінальний стан:"
        executionLog += "\nЛіній: \(lines.count)"
        executionLog += "\nТрикутників: \(triangles.count)"
    }
    
    private func drawLine(from p1: String, to p2: String) {
        guard let point1 = pointMap[p1], let point2 = pointMap[p2] else {
            executionLog += "  ❌ Точки не знайдено: \(p1), \(p2)\n"
            return
        }
        let line = Line(from: point1, to: point2)
        lines.append(line)
        executionLog += "  ✅ Лінія додана: \(p1)(\(point1.x),\(point1.y)) → \(p2)(\(point2.x),\(point2.y))\n"
    }
    
    private func drawPerpendicular(to line: (String, String), at pointName: String, intersection: String) {
        guard let p1 = pointMap[line.0],
              let p2 = pointMap[line.1],
              let point = pointMap[pointName] else {
            executionLog += "  ❌ Точки не знайдено\n"
            return
        }
        
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        let perpDx = -dy
        let perpDy = dx
        let length = sqrt(perpDx * perpDx + perpDy * perpDy)
        let normPerpDx = perpDx / length * 100
        let normPerpDy = perpDy / length * 100
        
        let newPointName = intersection == pointName ? pointName + "'" : intersection
        let newPoint = Point(x: point.x + normPerpDx, y: point.y + normPerpDy, name: newPointName)
        
        if !points.contains(where: { $0.name == newPoint.name }) {
            points.append(newPoint)
            pointMap[newPoint.name] = newPoint
        }
        
        let perpendicularLine = Line(from: point, to: newPoint)
        lines.append(perpendicularLine)
        executionLog += "  ✅ Перпендикуляр: \(pointName) → \(newPointName)\n"
    }
    
    private func drawTriangle(p1: String, p2: String, p3: String) {
        guard let point1 = pointMap[p1],
              let point2 = pointMap[p2],
              let point3 = pointMap[p3] else {
            executionLog += "  ❌ Точки не знайдено\n"
            return
        }
        
        let triangle = Triangle(p1: point1, p2: point2, p3: point3)
        triangles.append(triangle)
        executionLog += "  ✅ Трикутник: \(p1), \(p2), \(p3)\n"
    }
    
    private func drawParallel(to line: (String, String), through pointName: String) {
        guard let p1 = pointMap[line.0],
              let p2 = pointMap[line.1],
              let point = pointMap[pointName] else {
            executionLog += "  ❌ Точки не знайдено\n"
            return
        }
        
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        let newPointName = pointName + "'"
        let newPoint = Point(x: point.x + dx, y: point.y + dy, name: newPointName)
        
        if !points.contains(where: { $0.name == newPoint.name }) {
            points.append(newPoint)
            pointMap[newPoint.name] = newPoint
        }
        
        let parallelLine = Line(from: point, to: newPoint)
        lines.append(parallelLine)
        executionLog += "  ✅ Паралельна: \(pointName) → \(newPointName)\n"
    }
}

// MARK: - UI

struct GeometryCanvas: View {
    @ObservedObject var interpreter: GeometryInterpreter
    
    var body: some View {
        ZStack {
            Color.white
            
            ForEach(interpreter.triangles) { triangle in
                Path { path in
                    path.move(to: CGPoint(x: triangle.p1.x, y: triangle.p1.y))
                    path.addLine(to: CGPoint(x: triangle.p2.x, y: triangle.p2.y))
                    path.addLine(to: CGPoint(x: triangle.p3.x, y: triangle.p3.y))
                    path.closeSubpath()
                }
                .fill(Color.blue.opacity(0.2))
                
                Path { path in
                    path.move(to: CGPoint(x: triangle.p1.x, y: triangle.p1.y))
                    path.addLine(to: CGPoint(x: triangle.p2.x, y: triangle.p2.y))
                    path.addLine(to: CGPoint(x: triangle.p3.x, y: triangle.p3.y))
                    path.closeSubpath()
                }
                .stroke(Color.blue, lineWidth: 2)
            }
            
            ForEach(interpreter.lines) { line in
                Path { path in
                    path.move(to: CGPoint(x: line.from.x, y: line.from.y))
                    path.addLine(to: CGPoint(x: line.to.x, y: line.to.y))
                }
                .stroke(Color.black, lineWidth: 2)
            }
            
            ForEach(interpreter.points, id: \.name) { point in
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(point.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .offset(x: 15, y: -15)
                }
                .position(x: point.x, y: point.y)
            }
        }
        .frame(width: 500, height: 500)
        .border(Color.gray, width: 1)
    }
}

struct ContentView: View {
    @StateObject private var interpreter = GeometryInterpreter()
    @State private var inputText = """
    ПРОВЕСТИ ПРЯМУ ЧЕРЕЗ ДВІ ТОЧКИ A, B
    ПОБУДУВАТИ ТРИКУТНИК ПО ТРЬОМ ВЕРШИНАМ A, B, C
    ПОБУДУВАТИ ПЕРПЕНДИКУЛЯР ДО ПРЯМОЇ (AB) В ТОЧЦІ D
    ПОБУДУВАТИ ПАРАЛЕЛЬНУ ПРЯМУ ДО ПРЯМОЇ (AB) ЧЕРЕЗ ТОЧКУ E
    """
    @State private var parserLog = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Геометричний інтерпретатор")
                .font(.title)
                .fontWeight(.bold)
            
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Введіть команди:")
                        .font(.headline)
                    
                    TextEditor(text: $inputText)
                        .font(.system(.body, design: .monospaced))
                        .frame(width: 350, height: 250)
                        .border(Color.gray, width: 1)
                    
                    Button("Виконати") {
                        executeCommands()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    ScrollView {
                        Text(parserLog)
                            .font(.system(size: 9, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.3), width: 1)
                    
                    Text("Приклади команд:")
                        .font(.caption)
                    Text("""
                    • ПРОВЕСТИ ПРЯМУ ЧЕРЕЗ ДВІ ТОЧКИ A, B
                    • ПОБУДУВАТИ ТРИКУТНИК ПО ТРЬОМ ВЕРШИНАМ A, B, C
                    • ПОБУДУВАТИ ПЕРПЕНДИКУЛЯР ДО ПРЯМОЇ (AB) В ТОЧЦІ C
                    • ПОБУДУВАТИ ПАРАЛЕЛЬНУ ПРЯМУ ДО ПРЯМОЇ (AB) ЧЕРЕЗ ТОЧКУ D
                    """)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.secondary)
                }
                
                VStack(spacing: 10) {
                    Text("Малюнок:")
                        .font(.headline)
                    
                    GeometryCanvas(interpreter: interpreter)
                    
                    Text("Ліній: \(interpreter.lines.count), Трикутників: \(interpreter.triangles.count)")
                        .font(.caption)
                        .padding(5)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(5)
                }
            }
        }
        .padding()
    }
    
    private func executeCommands() {
        parserLog = "=== ПОЧАТОК АНАЛІЗУ ===\n\n"
        
        let lines = inputText.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        var allNodes: [ASTNode] = []
        
        for (index, line) in lines.enumerated() {
            parserLog += "Рядок \(index + 1): \(line)\n"
            
            let lexer = Lexer(line)
            let parser = Parser(lexer)
            let nodes = parser.parse()
            
            parserLog += parser.log + "\n"
            parserLog += "Розпізнано: \(nodes.map { $0.description }.joined(separator: ", "))\n\n"
            
            allNodes.append(contentsOf: nodes)
        }
        
        parserLog += "\n=== ВИКОНАННЯ ===\n"
        interpreter.execute(nodes: allNodes)
        parserLog += interpreter.executionLog
        
        print(parserLog)
    }
}

PlaygroundPage.current.setLiveView(ContentView())
