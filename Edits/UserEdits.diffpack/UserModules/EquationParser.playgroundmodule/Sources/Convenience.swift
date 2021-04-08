import Foundation

extension String {
    func countOccurences(of character: Character) -> Int {
        var occurences = 0
        for char in self {
            if char == character {
                occurences += 1
            }
        }
        return occurences
    }
    
    func indices(of character: Character) -> [Int] {
        var indices: [Int] = []
        for (index, char) in self.enumerated() {
            if char == character {
                indices.append(index)
            }
        }
        return indices
    }
    
    func split(withRegex regex: NSRegularExpression) -> [String] {
        let range = NSRange(self.startIndex..., in: self)
        let replacedStr = regex.stringByReplacingMatches(in: self, range: range, withTemplate: "$SPLIT$")
        return replacedStr.components(separatedBy: "$SPLIT$")
    }
}
