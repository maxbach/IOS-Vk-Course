//
//  ViewController.swift
//  CalculatorDemo
//
//  Created by Максим Бачинский on 19.09.16.
//  Copyright © 2016 Max Bachinskiy. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    var isLastCharIsNumber:Bool = true;
    var canWeUseDot:Bool = true;
    var currentNumber:[String] = [];
    var left:Int = 0;
    
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    @IBOutlet weak var labelOutlet: UILabel!
    
    override func viewDidLoad() {
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(CalculatorViewController.cleanAllLine));
        
        deleteButtonOutlet.addGestureRecognizer(longGesture);
        super.viewDidLoad();
        labelOutlet.text = "0"
        currentNumber.append("0")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
    
    
    //Fucn - action for number buttons
    @IBAction func clickNumberAction(_ sender: UIButton) {
        if (labelOutlet.text == "0") {
            labelOutlet.text = "";
            currentNumber.removeLast();
            currentNumber.append("")
        }
        addCharToExpression(char: Character((sender.titleLabel?.text!)!));
        if (isLastCharIsNumber == false) {
            canWeUseDot = true;
        }
        isLastCharIsNumber = true;
    }
    
    @IBAction func clickCharAction(_ sender: UIButton) {
        if (isLastCharIsNumber) {
            addCharToExpression(char: Character((sender.titleLabel?.text!)!));
            canWeUseDot = false;
            isLastCharIsNumber = false;
        }
        
    }
    
    @IBAction func leftButtonAction(_ sender: UIButton) {
        if (currentNumber.last == "0") {
            isLastCharIsNumber = false;
            labelOutlet.text = "";
            left += 1;
            addCharToExpression(char: "(")
            canWeUseDot = true;
        } else if (!isLastCharIsNumber) {
            left += 1;
            addCharToExpression(char: "(")
            canWeUseDot = true;
        }
    }
    
    
    @IBAction func rightButtonAction(_ sender: UIButton) {
        if (isLastCharIsNumber && left > 0 && currentNumber.last?.characters.last != ".") {
            left -= 1;
            addCharToExpression(char: ")")
            canWeUseDot = false;
        }
    }
    @IBAction func clickDotAction(_ sender: UIButton) {
        if (canWeUseDot || !isLastCharIsNumber) {
            addCharToExpression(char: ".")
            canWeUseDot = false;
            isLastCharIsNumber = true;
        }
    }
    
    func addCharToExpression(char:Character) {
        labelOutlet.text = labelOutlet.text! + String(char);
        if (isCharOperation(char)) {
            currentNumber.append("");
            
        } else {
            let lastItem : String = currentNumber.removeLast();
            currentNumber.append(lastItem + String(char))
        }
    }
    
    @IBAction func clickZeroAction(_ sender: UIButton) {
        if (isLastCharIsNumber && labelOutlet.text != "0") {
            addCharToExpression(char: "0");
            if (isLastCharIsNumber == false) {
                canWeUseDot = true;
            }
            isLastCharIsNumber = true;
        }
    }
    
    // Func - delete one char
    @IBAction func deleteOneCharAction(_ sender: UIButton) {
        var name :String = labelOutlet.text!
        if (name.characters.count == 1) {
            cleanAllLine()
        } else if (name.characters.count != 0 && name != "0") {
            
            let lastChar : Character = name.characters.last!;
            labelOutlet.text = name.substring(to: name.index(before: name.endIndex));
            name = labelOutlet.text!;
            let newLastChar : Character = name.characters.last!
            isLastCharIsNumber = isCharNumber(newLastChar)
            
            if (lastChar == ".") {
                canWeUseDot = true
            } else if (isCharNumber(lastChar)) {
                let lastItem : String = currentNumber.removeLast();
                currentNumber.append(lastItem.substring(to: lastItem.index(before: lastItem.endIndex)))
                canWeUseDot = !isNumberHasDot(str: currentNumber.last!)
                
                
            } else if (isCharOperation(lastChar)) {
                currentNumber.removeLast();
                canWeUseDot = !isNumberHasDot(str: currentNumber.last!)
            
            } else if (lastChar == "(") {
                left -= 1
                canWeUseDot = false
                currentNumber.removeLast();
            
            } else if (lastChar == ")") {
                left += 1
                canWeUseDot = !isNumberHasDot(str: currentNumber.last!)
            
            }
            
            
        }
    }
    
    
    @IBAction func cleanAllLine() {
        labelOutlet.text = "0";
        isLastCharIsNumber = true;
        canWeUseDot = true;
        left = 0;
        currentNumber.removeAll(keepingCapacity: false)
        currentNumber.append("0")
    }
    
    
    @IBAction func calculateExpressionAction(_ sender: UIButton) {
        
        var str:String = labelOutlet.text!;
        let lastChar = str.characters.last;
        if (isCharOperation(lastChar!) || lastChar == ".") {
            return;
        }
        if (left != 0) {
            while (left != 0) {
                str += ")"
                left -= 1
            }
        }
        var stack = charStack();
        var ppnExp = [String]()
        var num:String = ""
        for char in str.characters {
            if (isCharNumber(char)) {
                num += String (char);
            } else if (isCharOperation(char)) {  // нужен тут клининг кода!
                if (num != "") {
                    ppnExp.append(num);
                    num = "";
                }
                let operationPriority:Int = getPr(char);
                if (stack.isEmpty() || stack.getStackPr() < operationPriority) {
                    stack.push(char);
                } else {
                    while (stack.getStackPr() >= operationPriority) {
                        ppnExp.append(String(stack.pop()))
                    }
                    stack.push(char);
                }
                
            } else if (char == "(") {
                stack.push(char);
            } else if (char == ")") {
                if (num != "") {
                    ppnExp.append(num);
                    num = "";
                }
                var op:Character = stack.pop();
                while (op != "(") {
                    ppnExp.append(String(op));
                    op = stack.pop();
                }
            }
        }
        
        if (num != "") {
            ppnExp.append(num);
            num = "";
        }
        
        while (!stack.isEmpty()) {
            ppnExp.append(String(stack.pop()));
        }
        
        var newStack = intStack();
        for str in ppnExp {
            let num = Double(str);
            if (num != nil) {
                newStack.push(num!)
            } else {
                let num2:Double = newStack.pop();
                let num1:Double = newStack.pop();
                switch str {
                case "+":
                    newStack.push(num1 + num2)
                    break;
                case "-":
                    newStack.push(num1 - num2)
                    break;
                case "*":
                    newStack.push(num1 * num2)
                    break;
                case "/":
                    newStack.push(num1 / num2)
                    break;
                case "^":
                    newStack.push(pow(num1, num2));
                    break;
                default:
                    print("Неизведанная херь!")
                    break;
                }
            }
        }
        let result:Double = newStack.pop();
        let round:Int = Int(result);
        if (result - Double(round) == 0.0) {
            labelOutlet.text = String(round);
            canWeUseDot = true;
        } else {
            labelOutlet.text = String(result);
            canWeUseDot = false;
        }

        
    }
    
    
    func isCharNumber(_ char : Character) -> Bool{
        for i in 0...9 {
            if (String(char) == String(i) ){
                return true;
            }
        }
        
        if (String(char) == ".") {
            return true;
        }
        return false;
    }
    
    func isCharOperation(_ char: Character) -> Bool {
        let items = ["+", "-", "*", "/", "^"];
        for op in items {
            if (String(op) == String(char)) {
                return true;
            }
        }
        return false;
    }
    
    func isNumberHasDot (str: String) -> Bool {
        for i in str.characters {
            if (i == ".") {
                return true;
            }
        }
        return false;
    }
    
    
    struct charStack {
        var items = [Character]()
        var priority = 0;
        mutating func push(_ item: Character) {
            priority = getPr(item);
            items.append(item)
        }
        mutating func pop() -> Character {
            let lastItem:Character = items.removeLast();
            if (items.isEmpty) {
                priority = 0;
            } else {
                priority = getPr(items.last!);
            }
            return lastItem;
        }
        mutating func isEmpty() -> Bool {
            return items.count == 0;
        }
        
        mutating func getStackPr() -> Int {
            return priority;
        }
        
    }
    
    struct intStack {
        var items = [Double]()
        mutating func push(_ item: Double) {
            items.append(item)
        }
        mutating func pop() -> Double {
            return items.removeLast();
            
        }
    }
    
    
    


}

// Func - get prior of the operation
func getPr(_ char : Character) -> Int {
    if (char == "+" || char == "-") {
        return 2;
    } else if (char == "*" || char == "/") {
        return 3;
    } else if (char == "(" || char == ")") {
        return 1;
    } else if (char == "^") {
        return 4;
    } else {
        return 0;
    }
}

// Good input: после знака нельзя вводить знак и 0, после цифры можно вводить все
