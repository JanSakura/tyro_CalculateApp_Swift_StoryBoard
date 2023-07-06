//
//  ViewController.swift
//  Story
//
//  Created by JanSakura on 2023/7/4.
//

import UIKit

// 使用了Decimal ,就不用自己设计清除小数点最后的若干0 问题
//extension Double {
//    // 清除小数点最后的0
//    var clearSuffixZero:String {
//        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0lf", self) : String(self)
//    }
//}

// 将Any类型的值,转化为自身对应的类型,支持Int和Double
//func anyToType(_ any:Any ) -> Any {
////    if any is Int {
////        return (any as? Int)!
////    }
////    if any is Double {
////        return (any as? Double)!
////    }
//    if let num = any as? Int {
//        return num
//    }
//    if let num = any as? Double {
//        return num
//    }
//    return 0
//}

class ViewController: UIViewController {
    
    @IBOutlet weak var textFieldScreen: UITextField!
    
    // 使用可选类型,可以先不初始化
    private var g_operated:Decimal?
    private var g_operand:Decimal?
    private var g_operator:Character?
    private var g_pressState = false    // 按运算符后为false,其他如数字键为true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 禁止文本框可编辑
        setTextField("0")
        textFieldScreen.isUserInteractionEnabled = false
    }
    
    // 计算
    func simpleCal( operateds:Decimal , operands:Decimal, operators:Character) ->Decimal {
        switch operators {
        case "+" :
            return operateds + operands
        case "-":
            return operateds - operands
        case "*" :
            return operateds * operands
        case "/" :
            // Decimal has solved the question, it will return NaN
            if operands == 0 {
                return 0
            }
            return operateds / operands
        case "%":
            // Decimal 不支持mod , Swift支持浮点数求模
            let t1 = Double(truncating: NSNumber(nonretainedObject: operateds) )
            let t2 = Double(truncating: NSNumber(nonretainedObject: operands) )
            if (ceil(t1) == floor(t1)) && (ceil(t2) == floor(t2)){
                // 浮点数求模,结果和一般的求模规则结果不同, 尽量用整数
                return Decimal( Int(t1) % Int(t2) )
            } else {
                return Decimal( t1.truncatingRemainder(dividingBy: t2) )
            }
        default:
            break
        }
        return 0
    }
    // 设置展示结果
    func setTextField(_ any : Any){
        textFieldScreen.text = "\(any)"
    }
    
    // 数据校验显示
    func checkText(num : Int){
        // 字符串为0,如果输入的还是0 ,删除后追加,相当于不变
        if textFieldScreen.text == "0" || !g_pressState {
            textFieldScreen.text?.removeAll()
        }
        textFieldScreen.text?.append(contentsOf: "\(num)")
        g_pressState = true
    }
    
    // 符号校验
    func checkSymbol( char : Character) {
        // 校验非空
        guard let content = textFieldScreen.text else{
            return
        }
        switch char {
        case ".":
            // 有小数点的情况,就不用处理
            if content.contains("."){
                return
            }
            textFieldScreen.text?.append(contentsOf: ".")
            // 只有在具体数学运算方法时,才确定被操作数,操作数的值
        case "+", "-", "*", "/", "%":
            // 被操作数存储
            if g_operator == nil && g_operated == nil && g_operand == nil && g_pressState {
                g_operator = char
                // 使用Decimal 就不用判断Double 和Int,运算时会自己转换结果形式 ,且保证精确运算
                g_operated = Decimal(Double(content) ?? 0)
            }
            else if g_operator != nil && g_operated != nil {
                if !g_pressState {
                    // 连续按运算符键时, 刷新数学运算符
                    g_operator = char
                    // 重新获取,避免用户中间按了取反
                    g_operated = Decimal(Double(content) ?? 0)
                }else{
                    // 连续运算时
                    g_operand = Decimal(Double(content) ?? 0)
                    setTextField( simpleCal(operateds: g_operated ?? 0, operands: g_operand ?? 0, operators: g_operator ?? "=") )
                    g_operator = char
                    // 更新被操作数的值
                    g_operated = Decimal(Double(textFieldScreen.text ?? "0" ) ?? 0)
                }
            }
            g_pressState = false
            break
        case "±" :
            if content != "0" {
                if content.hasPrefix("-"){
                    textFieldScreen.text?.remove(at: content.index(content.startIndex, offsetBy: 0))
                }else {
                    // 直接拼接,不用insert
                    // tf_show.text! = "-" + tf_show.text!
                    textFieldScreen.text?.insert("-", at: content.index(content.startIndex, offsetBy: 0))
                }
            }
        case "=":
            if g_operator != nil && g_operated != nil {
                g_operand = Decimal(Double(content) ?? 0)
                
                g_operated = simpleCal(operateds: g_operated ?? 0, operands: g_operand ?? 0, operators: g_operator ?? "=")
                
                setTextField( g_operated ?? 0 )
                g_pressState = false
            }
        default:
            break
        }
    }
    
    
    @IBAction func pressNumberButton(_ sender: UIButton) {
        let num = sender.tag
        checkText(num: num)
        // print("@@@  \(num) : \(g_operated) \(g_operator) \(g_operand)  \(g_pressState) @@@")
    }
    
    
    @IBAction func pressMathSymbolButton(_ sender: UIButton) {
        // UIButton style choose Default or use sender.titleLabel?.text
        guard let char = sender.currentTitle else{
            return
        }
        // print("==  \(char) : \(g_operated) \(g_operator) \(g_operand)  \(g_pressState) ***")
        checkSymbol(char: Character(char) )
        // print("*** \(char) : \(g_operated) \(g_operator) \(g_operand)  \(g_pressState) ==")
    }
    
    // 清空当前输入的数值
    @IBAction func pressACButton(_ sender: Any) {
        textFieldScreen.text = "0"
        if g_pressState {
            g_pressState = false
        } else {
            g_operated = nil
            g_operator = nil
            g_operand = nil
        }
    }
    
}

