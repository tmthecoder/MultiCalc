import Foundation
enum ParsableType {
    case number, operation
}
public struct Expression {
    let operation: Operation
    public static func fromString() -> Expression {
        return Expression(operation: .number(0.0))
    }
    public static func parseOperations(expressionString: String){
        let expressionString = expressionString.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        let numRegex = try! NSRegularExpression(pattern: "\\(?-?[0-9]+\\)?")
        let matches = numRegex.matches(in: expressionString, range: NSRange(expressionString.startIndex..., in: expressionString))
        matches.map {
            print(String(expressionString[Range($0.range, in: expressionString)!]))
        }
        var seqCount = 0
        var splitDict: [Int : String] = [:] 
        
        for i in 0..<(matches.count-1) {
            let operatorLower = expressionString.index(expressionString.startIndex, offsetBy: matches[i].range.upperBound)
            let operaterUpper = expressionString.index(expressionString.startIndex, offsetBy: matches[i+1].range.lowerBound)
            let range = operatorLower..<operaterUpper
            print(expressionString[range])
        }
    }
    func simplify() {
        
    }
}
