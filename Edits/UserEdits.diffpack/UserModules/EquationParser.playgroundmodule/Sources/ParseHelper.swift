internal enum ParenthesisType {
    case open, closed
}

public class ParseHelper {
    public static var instance = ParseHelper()
    public func parseExpression(from expressionStr: String, numeric: Bool) {
        let formattedStr = expressionStr.replacingOccurrences(of: " ", with: "", options: .literal, range: nil).lowercased()
        try? getParenthesisIndices(expressionStr: formattedStr)
    }
    
    private func getParenthesisIndices(expressionStr: String) throws -> [Int: ParenthesisType] {
        var  parenthesisIndices: [Int: ParenthesisType] = [:]
        guard (expressionStr.countOccurences(of: Character("(")) == expressionStr.countOccurences(of: Character(")"))) else {
            fatalError("Occurrences not matched")
        }
        let indicesOfOpenings = expressionStr.indices(of: Character("("))
        for index in indicesOfOpenings {
            parenthesisIndices[index] = .open
        }
        let indicesOfClosings = expressionStr.indices(of: Character(")"))
        for index in indicesOfClosings {
            parenthesisIndices[index] = .closed
        }
        print(parenthesisIndices.keys.sorted())
        for key in parenthesisIndices.keys.sorted() {
            print("\(key): \(parenthesisIndices[key]!)")
        }
        return parenthesisIndices
    }
}
