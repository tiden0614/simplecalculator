//
//  CalculatorUtils.swift
//  Calculator
//
//  Created by tiden on 11/11/15.
//  Copyright (c) 2015 Daryl Zhang. All rights reserved.
//

import Foundation

struct Utils {
    static func isNumber(str: String?) -> Bool {
        if str == nil { return false }
        return str!.rangeOfString("^[0-9]+(\\.[0-9]+)?$", options: .RegularExpressionSearch) != nil

    }
    
    static func isIDentifier(str: String?) -> Bool {
        if str == nil { return false }
        return str!.rangeOfString("^[a-zA-Z][a-zA-Z0-9]+$", options: .RegularExpressionSearch) != nil
    }
    
    static func isNumberOrRightPren(str: String?) -> Bool {
        if str == nil { return false }
        return Utils.isNumber(str) || str! == ")"
    }
}