
indirect enum Operation {
    case number(Double)
    case term(Term)
    case add(Operation, Operation)
    case subtract(Operation, Operation)
    case multiply(Operation, Operation)
    case divide(Operation, Operation)
    case sine(Operation)
    case cosine(Operation)
    case tangent(Operation)
}
