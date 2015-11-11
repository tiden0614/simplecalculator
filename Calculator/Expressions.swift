//
//  Expressions.swift
//  Calculator
//
//  Created by tiden on 11/11/15.
//  Copyright (c) 2015 Daryl Zhang. All rights reserved.
//

import Foundation

protocol Expression {
    func evaluate() -> Double?
}

class expression: Expression {
    var chn: [Expression]
    var opr: [String]
    
    init(children: [Expression], operators: [String]) {
        chn = children
        opr = operators
    }
    
    func evaluate() -> Double? {
        assert(chn.count >= 1, "Children cannot be empty")
        assert(opr.count == chn.count || opr.count == chn.count - 1, "The number of operators should be equal to or one less than the number of children")
        
        func partialResult(oprIndex: Int -> Int) -> Double {
            var res = 0.0
            for (var i = 1; i < chn.count; i += 1) {
                if let eval = chn[i].evaluate() {
                    if opr[oprIndex(i)] == GlobalConstants.Operators.PLUS {
                        res = res + eval
                    } else {
                        res = res - eval
                    }
                }
            }
            return res
        }
        
        if var result = chn[0].evaluate() {
            if opr.count < chn.count {
                result += partialResult({ $0 - 1 })
            } else {
                if opr[0] == "-" {
                    result = -result
                }
                
                result += partialResult({ $0 })
            }
            
            return result
        }
        
        return nil
    }
}

class term: Expression {
    var chn: [Expression]
    var opr: [String]
    
    init(children: [Expression], operators: [String]) {
        chn = children
        opr = operators
    }
    
    func evaluate() -> Double? {
        assert(chn.count >= 1, "Children cannot be empty")
        assert(opr.count == chn.count - 1, "The number of operators should be one less than the number of children")
        
        if var result = chn[0].evaluate() {
            for (var i = 1; i < chn.count; i += 1) {
                if let eval = chn[i].evaluate() {
                    if opr[i - 1] == GlobalConstants.Operators.MULT {
                        result = result * eval
                    } else {
                        result = result / eval
                    }
                }
            }
            
            return result
        }
        
        return nil
    }
}

class factor: Expression {
    var chld: Expression
    
    init(child: Expression) {
        chld = child
    }
    
    func evaluate() -> Double? {
        return chld.evaluate()
    }
}

class function: Expression {
    var chn: [Expression]
    var opr: [Expression] -> Double?
    
    init(children: [Expression], operation: [Expression] -> Double?) {
        chn = children
        opr = operation
    }
    
    func evaluate() -> Double? {
        return opr(chn)
    }
}

class number: Expression {
    let val: Double
    
    init(value: Double) {
        val = value
    }
    
    func evaluate() -> Double? {
        return val
    }
}