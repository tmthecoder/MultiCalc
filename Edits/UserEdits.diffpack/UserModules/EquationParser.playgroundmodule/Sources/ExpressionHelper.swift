import Foundation

/// A class to handle expression evaluation
/// Handles both numeric and algebraic expressions
public class ExpressionHelper {
    
    /// Whether this class instance is dealing with a numeric or algrbraic expression
    let numeric: Bool
    
    /// Initializer to determine the type of expression this instance will deal with
    public init(numeric: Bool) {
        self.numeric = numeric
    }
    
    /// The main evaluation method, which calls recursively until reaching a double or term
    /// When reaching a double, it is utilized for the calling operation.
    /// When reaching a term, the termValue is substituted for the calling operation
    public func evaluate(_ expression: SolvableExpression, termValue: Double? = nil) -> Double {
        if !numeric && termValue == nil {
            fatalError("A Term Value must be given for term-based expressions")
        }
        switch expression {
        case let .number(num):
            // Return the base numeber
            return num
        case .term:
            // Return the set termValue
            return termValue!
        case .negTerm:
            // Return the set termValue but negated
            return -termValue!
        case let .add(rhs, lhs):
            // Add both values after recursive evaluation
            return evaluate(rhs, termValue: termValue) + evaluate(lhs, termValue: termValue)
        case let .subtract(rhs, lhs):
            // Subtract both values after recursive evaluation
            return evaluate(rhs, termValue: termValue) - evaluate(lhs, termValue: termValue)
        case let .multiply(rhs, lhs):
            // Multiply both values after recursive evaluation
            return evaluate(rhs,termValue: termValue) * evaluate(lhs,termValue: termValue)
        case let .divide(rhs, lhs):
            // Divide both values after recursive evaluation
            return evaluate(rhs, termValue: termValue) / evaluate(lhs, termValue: termValue)
        case let .exponent(base, power):
            // Return the exponential of both values after recursive evaluation
            return pow(evaluate(base, termValue: termValue), evaluate(power, termValue: termValue))
        }
    }
}
