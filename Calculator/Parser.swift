//
//  Parser.swift
//  Calculator
//
//  Created by tiden on 11/11/15.
//  Copyright (c) 2015 Daryl Zhang. All rights reserved.
//

import Foundation

public class Parser {
    
    var tokens = [String]()
    var nextIndex = 0
    
    private func next() -> String {
        if nextIndex >= tokens.count {
            return "$"
        }
        return tokens[nextIndex]
    }
    
    private func consume() {
        nextIndex += 1
    }
    
    private func expect(expectation: String) -> Bool {
        if expectation == next() {
            consume()
            return true
        } else {
            println("Error: expecting \(expectation) but receive \(next())")
            return false
        }
    }
    
    func parse(tokenStack: [String]) -> Expression {
        tokens = tokenStack
        nextIndex = 0
        return _expression()
    }
    
    // expression -> [ "+" | "-" ] term { "+" | "-" term }
    func _expression() -> Expression {
        var children = [Expression]()
        var operators = [String]()
        
        func nextIsPlusOrMinu() -> Bool {
            return next() == GlobalConstants.Operators.PLUS || next() == GlobalConstants.Operators.MINU
        }
        
        if nextIsPlusOrMinu() {
            operators.append(next())
            consume()
        }
        
        children.append(_term())
        
        while nextIsPlusOrMinu() {
            operators.append(next())
            consume()
            children.append(_term())
        }
        
        return expression(children: children, operators: operators)
    }
    
    // term -> factor { "*" | "/" factor }
    func _term() -> Expression {
        var children = [Expression]()
        var operators = [String]()
        
        children.append(_factor())
        
        while next() == GlobalConstants.Operators.MULT || next() == GlobalConstants.Operators.DIVI {
            operators.append(next())
            consume()
            children.append(_factor())
        }
        
        return term(children: children, operators: operators)
    }
    
    // factor -> number | "(" expression ")" | function
    func _factor() -> Expression {
        var result: Expression
        if next().rangeOfString("^[0-9]+(\\.[0-9]+)?$", options: .RegularExpressionSearch) != nil {
            result = factor(child: number(value: NSNumberFormatter().numberFromString(next())!.doubleValue))
            consume()
        } else if next() == GlobalConstants.Operators.LPRE {
            consume()
            result = factor(child: _expression())
            expect(GlobalConstants.Operators.RPRE)
        } else {
            result = factor(child: _function())
        }
        return result
    }
    
    // function -> identifier "(" expression { "," expression } ")"
    func _function() -> Expression {
        var children = [Expression]()
        var identifier = ""
        
        // find the identifier
        if next().rangeOfString("^[a-zA-Z][a-zA-Z0-9]+$", options: .RegularExpressionSearch) != nil {
            identifier = next()
            consume()
        } else {
            // parse error
            println("Error: expecting [identifier] but receive \(next())")
        }
        
        expect(GlobalConstants.Operators.LPRE)
        
        children.append(_expression())
        
        while next() == GlobalConstants.Operators.COMM {
            consume()
            children.append(_expression())
        }
        
        expect(GlobalConstants.Operators.RPRE)
        
        var opr: [Expression] -> Double?
        
        switch identifier {
        case GlobalConstants.Operators.SQRT:
            opr = { sqrt($0[0].evaluate()!) }
        case GlobalConstants.Operators.SIN:
            opr = { sin($0[0].evaluate()!) }
        case GlobalConstants.Operators.COS:
            opr = { cos($0[0].evaluate()!) }
        default:
            opr = { $0[0].evaluate() }
        }
        
        return function(children: children, opr)
    }
}