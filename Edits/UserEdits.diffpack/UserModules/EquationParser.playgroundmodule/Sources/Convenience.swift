import Foundation

/// A collection of String extensions that are used for convenience throughout both the parser library and the entire project
extension String {
    /// A method to count the occurrences of a single character within a string
    /// Takes the character to count and return an integer denoting the its occurrence in the string
    func countOccurences(of character: Character) -> Int {
        var occurences = 0
        for char in self {
            if char == character {
                occurences += 1
            }
        }
        return occurences
    }
    
    /// A method to find the speciific indices of a character, returning them as an Int array
    /// Takes the character to search for and returns an Integer array with the indicdes
    func indices(of character: Character) -> [Int] {
        var indices: [Int] = []
        for (index, char) in self.enumerated() {
            if char == character {
                indices.append(index)
            }
        }
        return indices
    }
    
    /// A method to split a String with a given regex
    /// Takes the regex, finds the matches and replaces them with a '$SPLIT$ string
    /// Then splits the string by $SPLIT$, returning a String array
    func split(withRegex regex: NSRegularExpression) -> [String] {
        let range = NSRange(self.startIndex..., in: self)
        let replacedStr = regex.stringByReplacingMatches(in: self, range: range, withTemplate: "$SPLIT$")
        return replacedStr.components(separatedBy: "$SPLIT$")
    }
}
