//
//  ViewController.swift
//  Homework_3
//
//  Created by Sofya Avtsinova on 08.10.2024.
//

import UIKit

class ViewController: UIViewController {
    private var tapingIsProcessing = false
    private var dotIsPlaced = false
    
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var clearButton: UIButton!

    private lazy var viewModel = ViewModel { [weak self] text, buttonType in
        guard let self else {
            return
        }

        switch buttonType {
        case .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .zero:
            addNumber(text: text)
        case .dot:
            addDot(text: text)
        case .addition, .multiplication, .division:
            addOperation(text: text)
        case .substraction:
            addSubstraction(text: text)
        case .percent:
            addPercent(text: text)
        case .changeSign:
            changeSign()
        case .clear:
            clearLabel()
        case .result:
            equals(text: text)
        }
    }
}

// MARK: - Actions
private extension ViewController {
    @IBAction func tapOne(_ sender: UIButton) {
        viewModel.tapButton(.one)
    }
    
    @IBAction func tapTwo(_ sender: UIButton) {
        viewModel.tapButton(.two)
    }
    
    @IBAction func tapThree(_ sender: UIButton) {
        viewModel.tapButton(.three)
    }
    
    @IBAction func tapFour(_ sender: UIButton) {
        viewModel.tapButton(.four)
    }
    
    @IBAction func tapFive(_ sender: UIButton) {
        viewModel.tapButton(.five)
    }
    
    @IBAction func tapSix(_ sender: UIButton) {
        viewModel.tapButton(.six)
    }
    
    @IBAction func tapSeven(_ sender: UIButton) {
        viewModel.tapButton(.seven)
    }
    
    @IBAction func tapEight(_ sender: UIButton) {
        viewModel.tapButton(.eight)
    }
    
    @IBAction func tapNine(_ sender: UIButton) {
        viewModel.tapButton(.nine)
    }
    
    @IBAction func tapZero(_ sender: UIButton) {
        viewModel.tapButton(.zero)
    }
    
    @IBAction func tapDot(_ sender: UIButton) {
        viewModel.tapButton(.dot)
    }
    
    @IBAction func tapAddition(_ sender: UIButton) {
        viewModel.tapButton(.addition)
    }
    
    @IBAction func tapSubstraction(_ sender: UIButton) {
        viewModel.tapButton(.substraction)
    }
    
    @IBAction func tapMultiplication(_ sender: UIButton) {
        viewModel.tapButton(.multiplication)
    }
    
    @IBAction func tapDivision(_ sender: UIButton) {
        viewModel.tapButton(.division)
    }
    
    @IBAction func tapPercent(_ sender: UIButton) {
        viewModel.tapButton(.percent)
    }
    
    @IBAction func tapChangeSign(_ sender: UIButton) {
        viewModel.tapButton(.changeSign)
    }
    
    @IBAction func tapClear(_ sender: UIButton) {
        viewModel.tapButton(.clear)
    }
    
    @IBAction func tapEquals(_ sender: UIButton) {
        viewModel.tapEquals(resultLabel.text)
    }
}

// MARK: - Private methods
private extension ViewController {
    func addNumber(text: String) {
        if resultLabel.text == "0" || !tapingIsProcessing {
            resultLabel.text = text
        } else if let oldText = resultLabel.text, oldText.suffix(1) != "%" {
            resultLabel.text = oldText + text
        }

        changeButtonToDelete()
    }
    
    func addDot(text: String) {
        if !tapingIsProcessing {
            resultLabel.text = "0" + text
        } else if let oldText = resultLabel.text,
                  let _ = Int(oldText.suffix(1)), !dotIsPlaced {
            resultLabel.text = oldText + text
            dotIsPlaced = true
        }

        changeButtonToDelete()
    }
    
    func addOperation(text: String) {
        if let oldText = resultLabel.text,
           Int(oldText.suffix(1)) != nil || oldText.suffix(1) == "%" {
            resultLabel.text = oldText + text
            dotIsPlaced = false
            changeButtonToDelete()
        }
    }
    
    func addSubstraction(text: String) {
        if resultLabel.text == "0" {
            resultLabel.text = text
        } else if let oldText = resultLabel.text, oldText.suffix(1) != "," {
            resultLabel.text = oldText + text
            dotIsPlaced = false
        }

        changeButtonToDelete()
    }
    
    func addPercent(text: String) {
        if let oldText = resultLabel.text,
           let _ = Int(oldText.suffix(1)), oldText != "0" {
            resultLabel.text = oldText + text
            changeButtonToDelete()
        }
    }
    
    func changeSign() {
        guard let oldText = resultLabel.text else {
            return
        }
        
        let pattern = "(\\+|-|×|÷)*(-)*([0-9]+(,[0-9]+)*)%*$"

        guard let lastNumRegex = try? NSRegularExpression(pattern: pattern) else {
            return
        }

        let oldTextRange = NSRange(location: 0,
                                   length: oldText.count)
        guard let match = lastNumRegex.firstMatch(in: oldText, range: oldTextRange) else {
            return
        }
        
        let matchRange = match.range
        
        let oldTextMatch = (oldText as NSString).substring(with: matchRange)
        
        if let firstChar = oldTextMatch.first {
            switch firstChar {
            case "+":
                resultLabel.text = oldText.replacingOccurrences(of: "+",
                                                                with: "-",
                                                                options: [],
                                                                range: Range(matchRange, in: oldText))
            case "-":
                if oldTextMatch.count == oldText.count{
                    resultLabel.text = String(oldText.dropFirst())
                } else {
                    resultLabel.text = oldText.replacingOccurrences(of: "-",
                                                                    with: "+",
                                                                    options: [],
                                                                    range: Range(matchRange, in: oldText))
                }
            case "×","÷":
                if oldTextMatch.count > 1 &&
                    oldTextMatch[oldTextMatch.index(after: oldTextMatch.startIndex)] == "-" {
                    resultLabel.text = oldText.replacingOccurrences(of: "-",
                                                                    with: "",
                                                                    options: [],
                                                                    range: Range(matchRange, in: oldText))
                } else {
                    guard let regex = try? NSRegularExpression(pattern: "×|÷") else {
                        return
                    }
                    
                    resultLabel.text = regex.stringByReplacingMatches(in: oldText,
                                                                      range: matchRange,
                                                                      withTemplate: String(firstChar) + "-")
                }
                
            default:
                if oldText != "0" {
                    resultLabel.text = "-" + oldText
                }
            }
        }
    }
    
    func clearLabel() {
        if let oldtext = resultLabel.text, tapingIsProcessing, oldtext.count != 1 {
            resultLabel.text = String(oldtext.dropLast())
        } else {
            resultLabel.text = "0"
            changeButtonToAC()
        }
    }
    
    func equals(text: String) {
        resultLabel.text = text
        changeButtonToAC()
    }
    
    func changeButtonToDelete() {
        if !tapingIsProcessing {
            tapingIsProcessing = true
            clearButton.setAttributedTitle(NSAttributedString(string: "", attributes: [:]),
                                           for: .normal)
            let symbolConfiguration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 22.0))
            clearButton.setImage(UIImage(systemName: "delete.left",
                                         withConfiguration: symbolConfiguration),
                                 for: .normal)
        }
    }
    
    func changeButtonToAC() {
        if tapingIsProcessing {
            tapingIsProcessing = false
            clearButton.setImage(UIImage(), for: .normal)
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30.0)]
            let attributedText = NSAttributedString(string: "AC", attributes: attributes)
            clearButton.setAttributedTitle(attributedText, for: .normal)
        }
    }
}


class RoundButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width / 2
    }
}

//MARK: button zero
class ZeroRoundButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureButton()
    }

    private func configureButton() {
        configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: frame.width / 4.5, bottom: 0, trailing: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width / 4.5
    }
}


enum ButtonsType: String{
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case zero = "0"
    case dot = ","
    case addition = "+"
    case substraction = "-"
    case multiplication = "×"
    case division = "÷"
    case percent = "%"
    case clear
    case changeSign
    case result
}

class ViewModel {
    private var changeText: (String, ButtonsType) -> ()
    
    init(_ changeText: @escaping (String, ButtonsType) -> ()) {
        self.changeText = changeText
    }
    
    func tapButton(_ button: ButtonsType) {
        changeText(button.rawValue, button)
    }
    
    func tapEquals(_ expression: String?) {
        guard let expression else {
            return
        }
        
        let parser = Parser(expression: expression)
        
        guard let result = parser.parse() else {
            return
        }
        
        changeText(formatResult(result), .result)
    }
}

//MARK: private ViewModel methods
private extension ViewModel {
    func formatResult(_ result: Double) -> String {
        if result.isInfinite || result.isNaN {
            return "Ошибка"
        }
        if result.truncatingRemainder(dividingBy: 1.0) == 0 {
            return String(Int(result))
        } else {
            return String(result).replacingOccurrences(of: ".", with: ",")
        }
    }
}

class Parser {
    private var tokens: [String] = []
    private var position: Int = 0
    
    init(expression: String) {
        addTokens(expression)
    }
    
    func parse() -> Double? {
        
        guard let result = sumExpression() else {
            return nil
        }
        
        if (position != tokens.count) {
            return nil
        }
        
        return result
    }
}

//MARK: private Parser methods
private extension Parser {
    func addTokens(_ expression: String) {
        let modExpression = prepareExpression(expression: expression)
        
        guard let regex = try? NSRegularExpression(pattern: "([0-9]+(\\.[0-9]+)*)|(\\+|-|\\×|\\÷|%)") else {
            return
        }

        let matches = regex.matches(in: modExpression, range: NSRange(location: 0, length: modExpression.count))
        
        for match in matches {
            let matchRange = match.range
            let subMatch = (modExpression as NSString).substring(with: matchRange)
            tokens.append(subMatch)
        }
    }
    
    func prepareExpression(expression: String) -> String {
        return expression.replacingOccurrences(of: ",", with: ".")
    }
    
    func sumExpression() -> Double? {
        guard var first = multExpression() else {
            return nil
        }
        
        while position < tokens.count {
            let operation: String = tokens[position]
            
            if (operation != "+" && operation != "-") {
                break
            } else {
                position += 1
            }
            
            guard let second = multExpression() else {
                return nil
            }
            if operation == "+" {
                first += second
            } else {
                first -= second
            }
        }
        return first
    }
    
    func multExpression() -> Double? {
        guard var first = term() else {
            return nil
        }
        
        while position < tokens.count {
            let operation: String = tokens[position]
            
            if (operation != "×" && operation != "÷") {
                break
            } else {
                position += 1
            }
            
            guard let second = term() else {
                return nil
            }
            if operation == "×" {
                first *= second
            } else {
                first /= second
            }
        }
        return first
    }
    
    func term() -> Double? {
        if position >= tokens.count {
            return nil
        }
        var next = tokens[position]
        position += 1
        if next == "-" {
            next += tokens[position]
            position += 1
        }
        if (position < tokens.count && tokens[position] == "%") {
            position += 1
            return (Double(next) ?? 0) / 100
        }

        return Double(next)
    }
}
