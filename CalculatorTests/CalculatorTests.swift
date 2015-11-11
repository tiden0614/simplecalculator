//
//  CalculatorTests.swift
//  CalculatorTests
//
//  Created by tiden on 11/7/15.
//  Copyright (c) 2015 Daryl Zhang. All rights reserved.
//

import UIKit
import XCTest
import Calculator

class CalculatorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParser1() {
        var testInput = [
            GlobalConstants.Operators.MINU,
            "cos",
            GlobalConstants.Operators.LPRE,
            "3.14159",
            GlobalConstants.Operators.RPRE,
            GlobalConstants.Operators.DIVI,
            GlobalConstants.Operators.LPRE,
            "20.357",
            GlobalConstants.Operators.PLUS,
            "459",
            GlobalConstants.Operators.RPRE,
            GlobalConstants.Operators.MULT,
            "53",
            GlobalConstants.Operators.MINU,
            "2",
            GlobalConstants.Operators.PLUS,
            "sqrt",
            GlobalConstants.Operators.LPRE,
            "9",
            GlobalConstants.Operators.RPRE,
        ]
        
        let parser = Parser()
        if let parsedResult = parser.parse(testInput) {
            if let eval = parsedResult.evaluate() {
                println(eval)
            }
        }
    }
    
}
