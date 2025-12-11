import SwiftUI
import PlaygroundSupport

// Модель даних
struct Point: Identifiable {
    let id = UUID()
    let name: String
    let x: Double
    let y: Double
}

struct ShapeCommand: Identifiable {
    let id = UUID()
    let name: String
    let points: [Point]
}

// Лексичний аналіз
struct LexicalTokens {
    var keywords: [String] = []
    var figureName: String?
    var rawText: String
    var pointMatches: [NSTextCheckingResult] = []
}

func lexicalAnalyze(line: String, coordRegex: NSRegularExpression) -> LexicalTokens {
    let lower = line.lowercased()
    var tokens = LexicalTokens(rawText: line)
    
    if lower.contains("побудувати") {
        tokens.keywords.append("побудувати")
    }
    if lower.contains("з точк") {
        tokens.keywords.append("з точками")
    }
    
    if lower.contains("ромб") { tokens.figureName = "ромб" }
    else if lower.contains("трапеція") || lower.contains("трапецію") { tokens.figureName = "трапеція" }
    else if lower.contains("паралелограм") { tokens.figureName = "паралелограм" }
    else if lower.contains("прямокутник") { tokens.figureName = "прямокутник" }
    
    tokens.pointMatches = coordRegex.matches(in: line, range: NSRange(line.startIndex..., in: line))
    
    return tokens
}

// Синтаксичний аналізатор
func syntacticAnalyze(line: String, tokens: LexicalTokens, lineNo: Int, coordRegex: NSRegularExpression, coordinateRange: ClosedRange<Double>) -> (ShapeCommand?, [String]) {
    var errors: [String] = []
    var shape: ShapeCommand?
    
    // Перевірка на ключове слово
    guard tokens.keywords.contains("побудувати") else {
        errors.append("Рядок \(lineNo): команда має починатись з 'побудувати'.")
        return (nil, errors)
    }
    
    // Назва фігури
    guard let figure = tokens.figureName else {
        errors.append("Рядок \(lineNo): не вказана або невідома фігура.")
        return (nil, errors)
    }
    
    // Слово "з" без подальшого контексту
    let lower = line.lowercased()
    if let zWordRange = lower.range(of: #"\bз\b"#, options: .regularExpression) {
        // Отримуємо підрядок після слова "з"
        let afterZ = line[zWordRange.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
        // Якщо після "з" немає нічого — це помилка
        if afterZ.isEmpty {
            errors.append("Рядок \(lineNo): після слова 'з' очікується додаткова інформація (наприклад 'з точками A B C D' або 'з точками A(x,y) ...'), але нічого не вказано.")
            return (nil, errors)
        }
        // Якщо після 'з' є тільки розділові знаки — теж помилка
        let cleaned = afterZ.trimmingCharacters(in: CharacterSet(charactersIn: ".,;:"))
        if cleaned.isEmpty {
            errors.append("Рядок \(lineNo): після 'з' має бути список імен або координат, натомість знайдено лише розділові символи.")
            return (nil, errors)
        }
    }
    
    // Парсинг координат (якщо є)
    var coordPoints: [Point] = []
    if !tokens.pointMatches.isEmpty {
        for m in tokens.pointMatches {
            guard let nameRange = Range(m.range(at: 1), in: line),
                  let xRange = Range(m.range(at: 2), in: line),
                  let yRange = Range(m.range(at: 3), in: line),
                  let x = Double(String(line[xRange])),
                  let y = Double(String(line[yRange])) else {
                errors.append("Рядок \(lineNo): неправильний формат координат.")
                return (nil, errors)
            }
            if !(coordinateRange.contains(x) && coordinateRange.contains(y)) {
                errors.append("Рядок \(lineNo): координати виходять за межі 0–200.")
                return (nil, errors)
            }
            coordPoints.append(Point(name: String(line[nameRange]), x: x, y: y))
        }
        if coordPoints.count == 4 {
            shape = ShapeCommand(name: figure, points: coordPoints)
            return (shape, errors)
        } else {
            errors.append("Рядок \(lineNo): для \(figure) очікується 4 точки.")
            return (nil, errors)
        }
    }
    
    // Якщо координат немає — шукаємо імена точок після "з точками"
    if tokens.keywords.contains("з точками") {
        guard let range = lower.range(of: "з точк") else {
            errors.append("Рядок \(lineNo): не знайдено імен точок.")
            return (nil, errors)
        }
        
        var after = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
        after = after.replacingOccurrences(of: "ами", with: "")
        after = after.replacingOccurrences(of: "ками", with: "")
        after = after.replacingOccurrences(of: "точками", with: "")
        after = after.replacingOccurrences(of: "точки", with: "")
        after = after.replacingOccurrences(of: "точка", with: "")
        
        let rawNames = after
            .split(separator: " ")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        if rawNames.count != 4 {
            errors.append("Рядок \(lineNo): потрібно 4 імені точок, знайдено \(rawNames.count).")
            return (nil, errors)
        }
        
        let defaultCoords = defaultPoints(for: figure, names: rawNames)
        shape = ShapeCommand(name: figure, points: defaultCoords)
        return (shape, errors)
    }
    
    // Якщо просто "побудувати ромб" — без точок
    let pts = defaultPoints(for: figure, names: ["A","B","C","D"])
    shape = ShapeCommand(name: figure, points: pts)
    return (shape, errors)
}


// Стандартні координати
func defaultPoints(for shape: String, names: [String]) -> [Point] {
    let coords: [(Double,Double)]
    switch shape.lowercased() {
    case "ромб":
        coords = [(50,50),(100,100),(150,50),(100,0)]
    case "паралелограм":
        coords = [(20,20),(120,20),(150,100),(50,100)]
    case "прямокутник":
        coords = [(20,20),(120,20),(120,80),(20,80)]
    case "трапеція":
        coords = [(20,20),(160,20),(130,100),(40,100)]
    default:
        coords = [(50,50),(150,50),(150,150),(50,150)]
    }
    return zip(names, coords).map { Point(name: $0.0, x: $0.1.0, y: $0.1.1) }
}

// Інтерфейс
struct ContentView: View {
    @State private var commandText: String =
"""
побудувати ромб
побудувати трапецію
побудувати паралелограм з точками Q W E R
побудувати ромб з точками A(50,50) B(100,100) C(150,50) D(100,0)
побудувати прямокутник з точками A(10,10) B(60,10) C(60,40) D(10,40)
"""
        // рядки з помилками
//    """
    
//    """
    @State private var shapes: [ShapeCommand] = []
    @State private var errors: [String] = []
    
    let coordinateRange: ClosedRange<Double> = 0...200
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Поле для команд:")
                .font(.headline)
            TextEditor(text: $commandText)
                .font(.system(.body, design: .monospaced))
                .frame(height: 140)
                .border(Color.gray)
            
            Button("Намалювати") {
                parseCommands()
            }
            .buttonStyle(.borderedProminent)
            
            HStack {
                Canvas { context, size in
                    drawGrid(context: context, size: size)
                    for shape in shapes {
                        drawShape(context: context, shape: shape, size: size)
                    }
                }
                .frame(width: 400, height: 400)
                .border(Color.gray)
                
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Помилки:")
                            .font(.headline)
                        ForEach(errors, id: \.self) { err in
                            Text("• \(err)").foregroundColor(.red)
                        }
                    }
                }
                .frame(width: 300, height: 400)
                .border(Color.gray)
            }
        }
        .padding()
        .onAppear { parseCommands() }
    }
    
    private func parseCommands() {
        shapes.removeAll()
        errors.removeAll()
        
        let lines = commandText.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
        let coordRegex = try! NSRegularExpression(pattern: #"([A-Za-zА-Яа-яЇїІіЄєҐґ0-9]+)\((\d+),(\d+)\)"#)
        
        for (i, line) in lines.enumerated() {
            let tokens = lexicalAnalyze(line: line, coordRegex: coordRegex)
            let (shape, errs) = syntacticAnalyze(line: line, tokens: tokens, lineNo: i+1, coordRegex: coordRegex, coordinateRange: coordinateRange)
            errors.append(contentsOf: errs)
            if let s = shape { shapes.append(s) }
        }
    }
    
    // Малювання
    private func drawGrid(context: GraphicsContext, size: CGSize) {
        let scaleX = size.width / CGFloat(coordinateRange.upperBound)
        let scaleY = size.height / CGFloat(coordinateRange.upperBound)
        
        // Сітка
        let grid = Path { p in
            for i in stride(from: 0, through: 200, by: 20) {
                p.move(to: CGPoint(x: CGFloat(i) * scaleX, y: 0))
                p.addLine(to: CGPoint(x: CGFloat(i) * scaleX, y: size.height))
                p.move(to: CGPoint(x: 0, y: size.height - CGFloat(i) * scaleY))
                p.addLine(to: CGPoint(x: size.width, y: size.height - CGFloat(i) * scaleY))
            }
        }
        context.stroke(grid, with: .color(.gray.opacity(0.2)))
        
        // Осі
        let axes = Path { p in
            p.move(to: CGPoint(x: 0, y: size.height))
            p.addLine(to: CGPoint(x: size.width, y: size.height))
            p.move(to: CGPoint(x: 0, y: size.height))
            p.addLine(to: CGPoint(x: 0, y: 0))
        }
        context.stroke(axes, with: .color(.black), lineWidth: 1.2)
        
        // Підписи координат
        for tick in stride(from: 0, through: 200, by: 50) {
            let label = Text("\(tick)").font(.system(size: 8))
            context.draw(label, at: CGPoint(x: CGFloat(tick) * scaleX, y: size.height + 8))
            if tick > 0 {
                context.draw(label, at: CGPoint(x: -10, y: size.height - CGFloat(tick) * scaleY))
            }
        }
    }
    
    private func drawShape(context: GraphicsContext, shape: ShapeCommand, size: CGSize) {
        let scaleX = size.width / CGFloat(coordinateRange.upperBound)
        let scaleY = size.height / CGFloat(coordinateRange.upperBound)
        
        func transform(_ p: Point) -> CGPoint {
            CGPoint(x: CGFloat(p.x) * scaleX, y: size.height - CGFloat(p.y) * scaleY)
        }
        
        let path = Path { p in
            if let first = shape.points.first {
                p.move(to: transform(first))
                for pt in shape.points.dropFirst() { p.addLine(to: transform(pt)) }
                p.closeSubpath()
            }
        }
        context.stroke(path, with: .color(.blue), lineWidth: 2)
        
        for pt in shape.points {
            let cg = transform(pt)
            let circle = Path(ellipseIn: CGRect(x: cg.x - 4, y: cg.y - 4, width: 8, height: 8))
            context.fill(circle, with: .color(.red))
            context.draw(Text(pt.name).font(.system(size: 10)), at: CGPoint(x: cg.x + 10, y: cg.y - 10))
            context.draw(Text("(\(Int(pt.x)),\(Int(pt.y)))").font(.system(size: 8)).foregroundColor(.gray), at: CGPoint(x: cg.x + 10, y: cg.y + 6))
        }
    }
}

PlaygroundPage.current.setLiveView(ContentView())
