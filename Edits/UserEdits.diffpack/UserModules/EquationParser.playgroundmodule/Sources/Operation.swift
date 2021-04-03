import Foundation

indirect enum SolvableExpression {
    case number(Double)
    case term(Term)
    case add(SolvableExpression, SolvableExpression)
    case subtract(SolvableExpression, SolvableExpression)
    case multiply(SolvableExpression, SolvableExpression)
    case divide(SolvableExpression, SolvableExpression)
    case exponent(SolvableExpression, SolvableExpression)
    case sine(SolvableExpression)
    case cosine(SolvableExpression)
    case tangent(SolvableExpression)
}
