### Update 6/1: WWDC21 Swift Student Challenge Winner!

## MultiCalc

MultiCalc is a multi-purpose calculator that consists of a handwriting-based expression solver and a graphing calculator.

Both the handwriting and graphing calculators were written from scratch. The handwriting calculator was written with Vision and PencilKit while the Graphing calculator uses Core Graphics.

Both calculators use a custom-written EquationParser module which uses a String expression and breaks it up into a set of recursive two-term operations which can be solved with a simple invokation

The graphing calculator uses a variable-based implementation of the EquationParser module, which allows for a solve invocation with a supplied number for the variable

The code is extensively documented should you choose to view it and a .zip file has been attached in the releases section. I would love to hear any feedback!
