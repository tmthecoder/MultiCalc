import Foundation

public class ParseHelper {
    
    /// Create a usable instance as reinitialization is not needed in any matter for equation parsing
    public static var instance = ParseHelper()
    
    /// The main method to parse a string expression and gain a SolveableExpression for a purely numeric expression or one with a variable
    public func parseExpression(from expressionStr: String, numeric: Bool) throws -> SolvableExpression {
        // Remove all spaces in the string and make it lowercased
        let formattedStr = expressionStr.replacingOccurrences(of: " ", with: "", options: .literal, range: nil).lowercased()
            // Add a multiplication symbol in front of implicit multiplication (ex: '2x', '2(x+1)' or '(x+1)(x+2)')
            // Use the regex with two capture groups, one for the number, and the other for the term or parenthesis after
            .replacingOccurrences(of: "(\\d|\\))(x|\\()", with: "$1".appending("*$2"), options: .regularExpression)
            // Add a '-1*' symbol in front of any implicitly negated variables to maintain order of operations
            .replacingOccurrences(of: "(\\-)(x)", with: "$1".appending("1*$2"), options: .regularExpression)
        // Get the result and return
        return try splitAndSolve(expression: formattedStr, numeric: numeric)
    }
    
    /// The primaty method to handle method splitting and solving, with both numeric and algebraic functions
    /// Takes a string and splits it by parenthesis and solves iteratively, returning a final SolvableExpression
    private func splitAndSolve(expression: String, numeric: Bool) throws -> SolvableExpression {
        // Make sure the expression is formatted correctly
        let openParenthesisCount = expression.countOccurences(of: "(")
        let closedParenthesisCount = expression.countOccurences(of: ")")
        if openParenthesisCount != closedParenthesisCount {
            throw MalformedExpressionError.mismatchedParenthesis(
                "\(openParenthesisCount) occurences of '(' does not match \(closedParenthesisCount) occurences of ')'")
        }
        // Create a mutable variable to manipulate the string expression
        var adjustedExpression = expression
        // Start the parenthesis reading by getting the end of the first set
        var endIndex = adjustedExpression.firstIndex(of: ")")
        var mainStored: [String: SolvableExpression] = [:]
        var counter = 0
        // Loop through until no parenthesis sets are left
        while let aEndIndex = endIndex {
            // Get a substring from the end to the start of the set (forced as we know the parenthesis count is equal)
            guard let subString = adjustedExpression.range(of: "(", options: .backwards, range: adjustedExpression.startIndex..<aEndIndex) else {
                throw MalformedExpressionError.parenthesisLookbackError("Failed to look back to an open parenthesis")
            }
            // Create the solvable expression from the subsection of the expression
            let subExpression = adjustedExpression[subString.upperBound..<aEndIndex]
            guard let expression = try? createSolvableExpression(subExpression: String(subExpression), numeric: numeric, mainStored: mainStored) else {
                throw MalformedExpressionError.failedEquationParse("Unable to parse equation from \(subExpression)")
            }
            mainStored[("mStore\(counter)")] = expression
            // Replace the parenthesis section with the key of the newly stored SolvableExpression
            adjustedExpression.replaceSubrange(subString.lowerBound...aEndIndex, with: "mStore\(counter)")
            // Update the loop
            endIndex = adjustedExpression.firstIndex(of: ")")
            counter += 1
        }
        return try createSolvableExpression(subExpression: adjustedExpression, numeric: numeric, mainStored: mainStored)
        
    }
    
    // TODO make this throw an exception
    
    /// The main method to handle transforming a String equation into a SolvableEquation type
    /// Splits by operation by the order-of-operations hierarchy (PEMDAS) and returns a single SolvableExpression
    func createSolvableExpression(subExpression: String, numeric: Bool, mainStored: [String: SolvableExpression]) throws -> SolvableExpression {
        // If the only part of the string is a double (answer already got), return it
        if let answer = Double(subExpression) {
            return .number(answer)
        }
        
        if subExpression.contains("-"),
           let expression = mainStored[String(subExpression.dropFirst())] {
            return .multiply(expression, .number(-1))
        }
        
        if let expression = mainStored[subExpression] {
            return expression
        }
        
        // Regexes for both operations and other terms surrounding operation
        let operationRegex = try! NSRegularExpression(pattern: "(?<=\\d|x)[+\\-*\\/\\^]")
        //        let termRegex = try! NSRegularExpression(pattern: "[^+\\-*\\/\\^]+")
        // Get the ranges
        let operationRanges = operationRegex.matches(in:subExpression, range: NSRange(subExpression.startIndex..., in: subExpression))
        //        let termRanges = termRegex.matches(in: subExpression, range: NSRange(subExpression.startIndex..., in: subExpression))
        // Create a String array of each split operation and terms
        var operations = operationRanges.compactMap {
            Range($0.range, in: subExpression).map { String(subExpression[$0]) }
        }
        var terms = subExpression.split(withRegex: operationRegex)
        // Create an overarching map and counter to keep track of fragmented solvables before the final merge
        var allExpressions: [String: SolvableExpression] = [:]
        var counter = 0
        // A convenience method to get parts of an expression to integrate into the full one
        func getExpressionParts(index: Int) throws -> (SolvableExpression, SolvableExpression) {
            // Gets the terms around the operation
            let lhsItem = terms[index]
            let rhsItem = terms[index + 1]
            // Checks them against already stored values or parses them
            let solvableParse = { (item: String) -> SolvableExpression? in
                let negative = item.contains("-")
                if item.contains("mStore") {
                    if negative, let stored = mainStored[String(item.dropFirst())] {
                        return .multiply(stored, .number(-1))
                    }
                    return mainStored[item]
                }
                if item.contains("store") {
                    if negative, let stored = allExpressions[String(item.dropFirst())] {
                        return .multiply(stored, .number(-1))
                    }
                    return allExpressions[item]
                }
                if !numeric && item == "-x" {return .negTerm}
                if !numeric && item == "x" {return .term}
                if let number = Double(item) {return .number(number)}
                throw MalformedExpressionError.failedNumberParse("Could not parse from \(item)")
            }
            guard let lhs = try? solvableParse(lhsItem),
                  let rhs = try? solvableParse(rhsItem) else {
                throw MalformedExpressionError.failedNumberParse("Could not parse from \(lhsItem) or \(rhsItem)")
            }
            // Removes the index from the arrays to update the loop below
            operations.remove(at: index)
            terms[index] = "store\(counter)"
            terms.remove(at: index + 1)
            return (lhs, rhs)
        }
        // Loop through until each operation is utilized and added to the hierarchial solver
        while operations.count > 0 && terms.count > 1 {
            // Start with exponents (E in PEMDAS)
            // Note: Parenthesis are already taken care of due to their being split in the prior methods
            if let expIndex = operations.firstIndex(of: "^") {
                // get the values on both ends of the operation and add them to the main store
                guard let (lhs, rhs) = try? getExpressionParts(index: expIndex) else {
                    throw MalformedExpressionError.failedNumberParse("Could not parse numbers from \(terms[expIndex]) and \(terms[expIndex + 1])")
                }
                allExpressions["store\(counter)"] = .exponent(lhs, rhs)
                counter+=1
                continue
            }
            // Proceed with the first instance of either multiplication or division (MD in PEMDAS)
            if let multIndex = operations.firstIndex(of: "*"), let divIndex = operations.firstIndex(of: "/") {
                // Get the correct operator to use
                let usedIndex = multIndex < divIndex ? multIndex : divIndex
                // Get values and add them to the main store
                guard let (lhs, rhs) = try? getExpressionParts(index: usedIndex) else {
                    throw MalformedExpressionError.failedNumberParse("Could not parse numbers from \(terms[usedIndex]) and \(terms[usedIndex + 1])")
                }
                allExpressions["store\(counter)"] = multIndex < divIndex ? .multiply(lhs, rhs) : .divide(lhs, rhs)
                counter+=1
                continue
            } else if let multIndex = operations.firstIndex(of: "*") {
                // No division in the subExpression, so just proceed with multiplication
                guard let (lhs, rhs) = try? getExpressionParts(index: multIndex) else {
                    throw MalformedExpressionError.failedNumberParse("Could not parse numbers from \(terms[multIndex]) and \(terms[multIndex + 1])")
                }
                allExpressions["store\(counter)"] = .multiply(lhs, rhs)
                counter+=1
                continue
            } else if let divIndex = operations.firstIndex(of: "/") {
                // No multiplication in the subExpression, so proceed with remaining division
                guard let (lhs, rhs) = try? getExpressionParts(index: divIndex) else {
                    throw MalformedExpressionError.failedNumberParse("Could not parse numbers from \(terms[divIndex]) and \(terms[divIndex + 1])")
                }
                allExpressions["store\(counter)"] = .divide(lhs, rhs)
                counter+=1
                continue
            }
            
            // Proceed with the first instance of either addition or subtraction (AS in PEMDAS)
            if let addIndex = operations.firstIndex(of: "+"), let subIndex = operations.firstIndex(of: "-") {
                // Get the correct operator to use
                let usedIndex = addIndex < subIndex ? addIndex : subIndex
                // Get the values and add them to the main store
                guard let (lhs, rhs) = try? getExpressionParts(index: usedIndex) else {
                    throw MalformedExpressionError.failedNumberParse("Could not parse numbers from \(terms[usedIndex]) and \(terms[usedIndex + 1])")
                }
                allExpressions["store\(counter)"] = addIndex < subIndex ? .add(lhs, rhs) : .subtract(lhs, rhs)
                counter+=1
                continue
            } else if let addIndex = operations.firstIndex(of: "+") {
                // No subtraction in the subExpression, so proceed with only addition
                guard let (lhs, rhs) = try? getExpressionParts(index: addIndex) else {
                    throw MalformedExpressionError.failedNumberParse("Could not parse numbers from \(terms[addIndex]) and \(terms[addIndex + 1])")
                }
                allExpressions["store\(counter)"] = .add(lhs, rhs)
                counter+=1
                continue
            } else if let subIndex = operations.firstIndex(of: "-") {
                // No addition in the subExpression, so proceed with only addition
                guard let (lhs, rhs) = try? getExpressionParts(index: subIndex) else {
                    throw MalformedExpressionError.failedNumberParse("Could not parse numbers from \(terms[subIndex]) and \(terms[subIndex + 1])")
                }
                allExpressions["store\(counter)"] = .subtract(lhs, rhs)
                counter+=1
                continue
            }
        }
        
        // The last key after sorting contains the full equation
        // This is because all operations will be accounted for iteratively at the end
        if let key = allExpressions.keys.sorted().last {
            return allExpressions[key]!
        }
        
        throw MalformedExpressionError.failedEquationParse("Unable to parse expression from \(subExpression)")
    }
    
}
