
enum MalformedExpressionError : Error {
    case mismatchedParenthesis(String)
    case parenthesisLookbackError(String)
    case failedNumberParse(String)
    case failedEquationParse(String)
}
