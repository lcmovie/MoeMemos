import Foundation

struct TagVisitor {
    static func extract(from text: String) -> [String] {
        let expression = try! NSRegularExpression(pattern: "#([^\\s#]+)")
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return expression.matches(in: text, range: range).compactMap { match in
            guard let range = Range(match.range(at: 1), in: text) else { return nil }
            return String(text[range])
        }
    }
}
