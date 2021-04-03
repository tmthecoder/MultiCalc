
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
}
