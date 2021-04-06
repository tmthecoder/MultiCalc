/// An enumeration to store an equation that can be solved algebraically or mathematically
/// The enum can hold recursively, allowing use for various operations without limit
public indirect enum SolvableExpression {
    /// A normal number
    case number(Double)
    /// A variable
    case term
    /// An addition operation
    case add(SolvableExpression, SolvableExpression)
    /// A subtraction operation
    case subtract(SolvableExpression, SolvableExpression)
    /// A multiplication operation
    case multiply(SolvableExpression, SolvableExpression)
    /// A division operation
    case divide(SolvableExpression, SolvableExpression)
    /// An exponent operation
    case exponent(SolvableExpression, SolvableExpression)
    //    case sine(SolvableExpression)
    //    case cosine(SolvableExpression)
    //    case tangent(SolvableExpression)
}