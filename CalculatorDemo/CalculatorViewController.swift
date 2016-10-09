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
    @IBOutlet weak var labelOutlet: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad();
        labelOutlet.text = "0"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
    
    
    
    @IBAction func clickNumberAction(_ sender: UIButton) {
        if (labelOutlet.text == "0") {
            labelOutlet.text = "";
        }
        labelOutlet.text = labelOutlet.text! + (sender.titleLabel?.text!)!;
        isLastCharIsNumber = true;
    }
    
    @IBAction func clickCharAction(_ sender: UIButton) {
        if (isLastCharIsNumber) {
            labelOutlet.text = labelOutlet.text! + (sender.titleLabel?.text!)!;
            isLastCharIsNumber = false;
        }
        
    }
    
    @IBAction func clickZeroAction(_ sender: UIButton) {
        if (isLastCharIsNumber && labelOutlet.text != "0") {
            labelOutlet.text = labelOutlet.text! + (sender.titleLabel?.text!)!;
            isLastCharIsNumber = true;
        }
    }
    
    @IBAction func deleteOneCharAction(_ sender: UIButton) {
        let name :String = labelOutlet.text!
        if (name.characters.count == 1) {
            cleanAllLine(sender)
        } else if (name.characters.count != 0 && name != "0") {
            labelOutlet.text = name.substring(to: name.index(before: name.endIndex))
        }
    }
    
    
    @IBAction func cleanAllLine(_ sender: UIButton) {
        labelOutlet.text = "0";
        isLastCharIsNumber = true;
    }
    
    @IBAction func calculateExpressionAction(_ sender: UIButton) {
        var str:String = labelOutlet.text!;
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
        } else {
            labelOutlet.text = String(result);
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
        let items = ["+", "-", "*", "/"];
        for op in items {
            if (String(op) == String(char)) {
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

func getPr(_ char : Character) -> Int {
    if (char == "+" || char == "-") {
        return 2;
    } else if (char == "*" || char == "/") {
        return 3;
    } else if (char == "(" || char == ")") {
        return 1;
    } else {
        return 0;
    }
}

// Good input: после знака нельзя вводить знак и 0, после цифры можно вводить все
