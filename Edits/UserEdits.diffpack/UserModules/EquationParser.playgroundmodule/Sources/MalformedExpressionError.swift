/// An enum that returns the type of error with the associated malformed expression
/// Thrown from the main parse helper class from its various methods
enum MalformedExpressionError : Error {
    /// An error when the count of open and closed parentheses are different
    case mismatchedParenthesis(String)
    /// An error when searching for the assosiated open parenthesis fails
    case parenthesisLookbackError(String)
    /// An error when a specific nunber component fails parsing
    case failedNumberParse(String)
    /// An error when an entire equation fails the parse process
    case failedEquationParse(String)
}
