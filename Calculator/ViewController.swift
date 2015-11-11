//
//  ViewController.swift
//  Calculator
//
//  Created by tiden on 11/7/15.
//  Copyright (c) 2015 Daryl Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var parser = Parser()
    var tokenStack = [String]()
    var currentInputString = ""
    
    @IBAction func appendDigit(sender: UIButton) {
        var buttonTitle = sender.currentTitle!
        
        switch buttonTitle {
        case ".":
            if currentInputString.rangeOfString(".") == nil {
                currentInputString += "."
                printDisplay()
            }
        case "0":
            // if the last thing on the stack is a number when we are editting the current
            // number, just pop it and concatenate with the currentInputString
            if Utils.isNumber(tokenStack.last) {
                currentInputString = tokenStack.last! + currentInputString
                tokenStack.removeLast()
            }
            if currentInputString.isEmpty || currentInputString != "0" {
                currentInputString += "0"
                printDisplay()
            }
        case "1", "2", "3", "4", "5", "6", "7", "8", "9":
            // if the last thing on the stack is a number when we are editting the current
            // number, just pop it and concatenate with the currentInputString
            if Utils.isNumber(tokenStack.last) {
                currentInputString = tokenStack.last! + currentInputString
                tokenStack.removeLast()
            }
            currentInputString += buttonTitle
            printDisplay()
        case "(", ")", ",":
            push()
            tokenStack.append(buttonTitle)
            printDisplay()
        case "π":
            currentInputString = "\(M_PI)"
            printDisplay()
        default:
            break
        }
        
        printStack()
    }
    
    func printDisplay() -> String {
        let d = " ".join(tokenStack) + currentInputString
        display.text! = d
        return d
    }

    func push() {
        if !currentInputString.isEmpty {
            tokenStack.append(currentInputString)
            currentInputString = ""
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        
        push()
        tokenStack.append(operation)
        
        // push a left parenthesis when approperiate reminding the user to use parenthesises
        if operation != GlobalConstants.Operators.PLUS && operation != GlobalConstants.Operators.MINU &&
            operation != GlobalConstants.Operators.MULT && operation != GlobalConstants.Operators.DIVI {
                tokenStack.append("(")
        }

        printDisplay()
        
        printStack()
    }
    

    @IBAction func enter() {
        push()
        
        preProcessStack()
        
        if let expr = parser.parse(tokenStack) {
            if let evalResult = expr.evaluate() {
                history.text! = printDisplay()
                display.text! = "\(evalResult)"
            }
            printStack()
        }

    }
    
    
    @IBAction func clear() {
        currentInputString = ""
        tokenStack.removeAll(keepCapacity: true)
        display.text! = "0"
    }
    
    @IBAction func backspace() {
        if !currentInputString.isEmpty {
            currentInputString.removeAtIndex(currentInputString.endIndex.predecessor())
        } else {
            if !tokenStack.isEmpty {
                var last = tokenStack.removeLast()
                if Utils.isNumber(last) {
                    // if the top of the stack is a number, pop the number and delete its last
                    last.removeAtIndex(last.endIndex.predecessor())
                    currentInputString = last
                }
            }
        }
        printDisplay()
        printStack()
    }
    
    private func printStack() {
        println(tokenStack)
    }
    
    private func preProcessStack() {
        // only numbers and right parenthesis are allowed at the very end of the stack
        // everything else should be poped up
        while !Utils.isNumberOrRightPren(tokenStack.last) {
            tokenStack.removeLast()
        }
    }
}

