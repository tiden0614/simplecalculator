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
    var _err = ""
    var error: String {
        set {
            if debug {
                println(newValue)
            }
            _err = newValue
        }
        get {
            return _err
        }
    }
    var debug = true
    
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
            error = "line(\(__LINE__)) Error: expecting \(expectation) but receive \(next())"
            return false
        }
    }
    
    func parse(tokenStack: [String]) -> Expression? {
        tokens = tokenStack
        nextIndex = 0
        return _expression()
    }
    
    // expression -> [ "+" | "-" ] term { "+" | "-" term }
    func _expression() -> Expression? {
        var children = [Expression]()
        var operators = [String]()
        
        func nextIsPlusOrMinu() -> Bool {
            return next() == GlobalConstants.Operators.PLUS || next() == GlobalConstants.Operators.MINU
        }
        
        if nextIsPlusOrMinu() {
            operators.append(next())
            consume()
        }
        
        if let t = _term() {
            children.append(t)
        } else {
            return nil
        }

        
        while nextIsPlusOrMinu() {
            operators.append(next())
            consume()
            if let t = _term() {
                children.append(t)
            } else {
                return nil
            }
        }
        
        return expression(children: children, operators: operators)
    }
    
    // term -> factor { "*" | "/" factor }
    func _term() -> Expression? {
        var children = [Expression]()
        var operators = [String]()
        
        if let f = _factor() {
            children.append(f)
        } else {
            return nil
        }

        
        while next() == GlobalConstants.Operators.MULT || next() == GlobalConstants.Operators.DIVI {
            operators.append(next())
            consume()
            if let f = _factor() {
                children.append(f)
            } else {
                return nil
            }
        }
        
        return term(children: children, operators: operators)
    }
    
    // factor -> number | "(" expression ")" | function
    func _factor() -> Expression? {
        var result: Expression
        if Utils.isNumber(next()) {
            result = factor(child: number(value: NSNumberFormatter().numberFromString(next())!.doubleValue))
            consume()
        } else if next() == GlobalConstants.Operators.LPRE {
            consume()
            if let e = _expression() {
                result = factor(child: e)
            } else {
                return nil
            }
            if !expect(GlobalConstants.Operators.RPRE) {
                return nil
            }
        } else {
            if let f = _function() {
                result = factor(child: f)
            } else {
                return nil
            }
        }
        return result
    }
    
    // function -> identifier "(" expression { "," expression } ")"
    func _function() -> Expression? {
        var children = [Expression]()
        var identifier = ""
        
        // find the identifier
        if Utils.isIDentifier(next()) {
            identifier = next()
            consume()
        } else {
            // parse error
            error = "line(\(__LINE__)) Error: expecting [identifier] but receive \(next())"
            return nil
        }
        
        if !expect(GlobalConstants.Operators.LPRE) {
            return nil
        }
        
        if let e = _expression() {
            children.append(e)
        } else {
            return nil
        }

        
        while next() == GlobalConstants.Operators.COMM {
            consume()
            if let e = _expression() {
                children.append(e)
            } else {
                return nil
            }
        }
        
        if !expect(GlobalConstants.Operators.RPRE) {
            return nil
        }
        
        var opr: [Expression] -> Double?
        
        switch identifier {
        case GlobalConstants.Operators.SQRT:
            if children.count < 1 {
                error = "line(\(__LINE__)) Error: \(identifier) function expects 1 arguments, but only got \(children.count)"
                return nil
            }
            opr = { sqrt($0[0].evaluate()!) }
        case GlobalConstants.Operators.SIN:
            if children.count < 1 {
                error = "line(\(__LINE__)) Error: \(identifier) function expects 1 arguments, but only got \(children.count)"
                return nil
            }
            opr = { sin($0[0].evaluate()!) }
        case GlobalConstants.Operators.COS:
            if children.count < 1 {
                error = "line(\(__LINE__)) Error: \(identifier) function expects 1 arguments, but only got \(children.count)"
                return nil
            }
            opr = { cos($0[0].evaluate()!) }
        case GlobalConstants.Operators.POW:
            if children.count < 2 {
                error = "line(\(__LINE__)) Error: \(identifier) function expects 2 arguments, but only got \(children.count)"
                return nil
            }
            opr = { pow($0[0].evaluate()!, $0[1].evaluate()!) }
        default:
            opr = { $0[0].evaluate() }
        }
        
        return function(children: children, opr)
    }
}