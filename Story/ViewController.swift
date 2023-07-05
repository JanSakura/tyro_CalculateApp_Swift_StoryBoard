//
//  ViewController.swift
//  Story
//
//  Created by JanSakura on 2023/7/4.
//

import UIKit

// 使用了Decimal ,就不用自己设计清除小数点最后的若干0 问题
extension Double {
    // 清除小数点最后的0
    var clearSuffixZero:String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0lf", self) : String(self)
    }
}


// 将Any类型的值,转化为自身对应的类型,支持Int和Double
func AnyToType(_ any:Any ) -> Any {
    if any is Int {
        return (any as? Int)!
    }
    if any is Double {
        return (any as? Double)!
    }
    return 0
}

class ViewController: UIViewController {

    @IBOutlet weak var tf_show: UITextField!
    
    
    // 使用可选类型,先不初始化
    var g_operated:Any?
    var g_operand:Any?
    var g_operator:Character?
    var g_pressState = false    // 按运算符为false,其他为true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 禁止文本框可编辑
        tf_show.isUserInteractionEnabled = false
    }
    
    // 计算
    func simpleCal(_ operateds:Any ,_ operands:Any,_ operators:Character) ->Any {
        switch operators {
        case "+" :
            return ((operateds as? Decimal)! + (operands as? Decimal)!)
        case "-":
            return ((operateds as? Decimal)! - (operands as? Decimal)!)
        case "*" :
            return ((operateds as? Decimal)! * (operands as? Decimal)!)
        case "/" :
            return ((operateds as? Decimal)! / (operands as? Decimal)!)
        case "%":
            
            // Decimal 不支持mod , Swift支持浮点数求模
            let t1 = Double(truncating: (operateds as? NSNumber)!)
            let t2 = Double(truncating: (operands as? NSNumber)!)
            if (ceil(t1) == floor(t1)) && (ceil(t2) == floor(t2)){
                // 浮点数求模,结果和一般的求模规则结果不同, 尽量用整数
                return Int(t1) % Int(t2)
            } else {
                return t1.truncatingRemainder(dividingBy: t2)
            }
        default:
            break
        }
        return 0
    }
    // 展示结果
    func showTextField(_ any : Any){
        tf_show.text! = "\(any)"
    }
    
    // 数据校验显示
    func checkText(_ num : Int){
        // 字符串为0,如果输入的还是0 ,删除后追加,相当于不变
        if tf_show.text! == "0" || !g_pressState {
            tf_show.text!.removeAll()
        }
        tf_show.text?.append(contentsOf: "\(num)")
        g_pressState = true
    }
    
    // 符号校验
    func checkSymbol(_ char : Character) {
        switch char {
        case ".":
            // 有小数点的情况,就不用处理
            if tf_show.text!.contains("."){
                return
            }
            tf_show.text?.append(contentsOf: ".")
            break
        // 只有在具体数学运算方法时,才确定被操作数,操作数的值
        case "+", "-","*","/","%":
            // print("==  \(char) : \(g_operated) \(g_operator)--\(g_operand)  \(g_pressState)")
            // 被操作数存储
            if g_operator == nil && g_operated == nil && g_operand == nil && g_pressState {
                g_operator = char
                // 使用Decimal 就不用判断Double 和Int,运算时会自己转换结果形式 ,且保证精确运算
                g_operated = Decimal(Double(tf_show.text!)!)
            }
            else if g_operator != nil && g_operated != nil {
                if !g_pressState {
                    // 连续按运算符键时, 刷新数学运算符
                    g_operator = char
                    // 重新获取,避免用户中间按了取反
                    g_operated = Decimal(Double(tf_show.text!)!)
                }else{
                    // 连续运算时
                    g_operator = char
                    g_operand = Decimal(Double(tf_show.text!)!)
                    showTextField( simpleCal(g_operated!, g_operand!, g_operator!) )
                }
            }
            // print("\(char) : \(g_operated) \(g_operator)--\(g_operand)  \(g_pressState) ==")
            g_pressState = false
            break
        case "±" :
            if tf_show.text! != "0" {
                if tf_show.text!.hasPrefix("-"){
                    tf_show.text!.remove(at: tf_show.text!.index(tf_show.text!.startIndex, offsetBy: 0))
                }else {
                    // 直接拼接,不用insert
                    // tf_show.text! = "-" + tf_show.text!
                    tf_show.text!.insert("-", at: tf_show.text!.index(tf_show.text!.startIndex, offsetBy: 0))
                }
            }
            break
        case "=":
            if g_operator != nil && g_operated != nil {
                g_operand = Decimal(Double(tf_show.text!)!)
                
                g_operated = simpleCal(g_operated!, g_operand!, g_operator!)
                
                showTextField( g_operated ?? 0 )
                g_pressState = false
            }
            break
        default:
            break
        }
    }
    
    @IBAction func click_Bt0(_ sender: Any) {
        checkText(0)
    }
    @IBAction func click_Bt1(_ sender: Any) {
        checkText(1)
    }
    @IBAction func click_Bt2(_ sender: Any) {
        checkText(2)
    }
    @IBAction func click_Bt3(_ sender: Any) {
        checkText(3)
    }
    @IBAction func click_Bt4(_ sender: Any) {
        checkText(4)
    }
    @IBAction func click_Bt5(_ sender: Any) {
        checkText(5)
    }
    @IBAction func click_Bt6(_ sender: Any) {
        checkText(6)
    }
    @IBAction func click_Bt7(_ sender: Any) {
        checkText(7)
    }
    @IBAction func click_Bt8(_ sender: Any) {
        checkText(8)
    }
    @IBAction func click_bt9(_ sender: Any) {
        checkText(9)
    }
    
    // 符号类按钮
    @IBAction func click_BtPoint(_ sender: Any) {
        checkSymbol(".")
    }
    @IBAction func click_BtEqual(_ sender: Any) {
        checkSymbol("=")
    }
    @IBAction func click_BtAdd(_ sender: Any) {
        checkSymbol("+")
    }
    @IBAction func click_BtSub(_ sender: Any) {
        checkSymbol("-")
    }
    @IBAction func click_BtMult(_ sender: Any) {
        checkSymbol("*")
    }
    @IBAction func click_BtDiv(_ sender: Any) {
        checkSymbol("/")
    }
    @IBAction func click_BtMod(_ sender: Any) {
        checkSymbol("%")
    }
    // 数值取相反数
    @IBAction func click_BtNegate(_ sender: Any) {
        checkSymbol("±")
    }
    // 清空当前输入的数值
    @IBAction func click_BtAc(_ sender: Any) {
        tf_show.text = "0"
        if g_pressState {
            g_pressState = false
        } else {
            g_operated = nil
            g_operator = nil
            g_operand = nil
        }
    }
    
}

