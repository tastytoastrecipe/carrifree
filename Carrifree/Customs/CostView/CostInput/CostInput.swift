//
//  CostInput.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/28.
//

import UIKit

class CostInput: UIView {
    
    @IBOutlet weak var cost: UITextField!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var line: UIView!

    var available: Bool = true

    var xibLoaded: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: CostInput.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        _utils.setText(bold: .regular, size: 16, text: "", field: cost)
        cost.addTarget(self, action: #selector(self.tfDidBeginEditing(_:)), for: .editingDidBegin)
        cost.addTarget(self, action: #selector(self.tfDidEndEditing(_:)), for: .editingDidEnd)
        cost.addTarget(self, action: #selector(self.tfDidChange(_:)), for: .editingChanged)
        cost.delegate = self
        
        _utils.setText(bold: .regular, size: 13, text: "", label: currency)
    }
    
    func configure(cost: String, editable: Bool) {
        configure()
        self.cost.text = cost
        self.cost.isUserInteractionEnabled = editable
        
        if Locale.current.languageCode == "ko" {
            self.currency.text = "원"
        } else {
            self.currency.text = Locale.current.currencySymbol!
        }
    }
    
    /// 기본 가격 설정 (placeholder)
    func setDefaultCost(cost: String) {
        self.cost.placeholder = cost
    }
    
    func setCost(cost: String) {
        let costWithoutDelimiter = _utils.removeDelimiter(str: cost)
        guard let _ = Int(costWithoutDelimiter) else { return }
        self.cost.text = cost
    }
    
    func getCost() -> String {
        return cost.text ?? ""
    }
    
    func getCostWithoutDelimiter() -> String {
        let costStr = _utils.removeDelimiter(str: cost.text)
        return costStr
    }
    
    func validate() {
        let costWithoutDelimiter = _utils.removeDelimiter(str: getCost())
        let costInt = Int(costWithoutDelimiter) ?? 0
        if costInt > 0 {
            line.backgroundColor = .systemGray4
        } else {
            line.backgroundColor = .systemRed
        }
    }
}

extension CostInput: UITextFieldDelegate {
    @objc func tfDidBeginEditing(_ textField: UITextField) {
        guard var text = textField.text else { return }
        text = _utils.removeDelimiter(str: text)
        textField.text = text
    }
    
    @objc func tfDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let delimeterText = _utils.getDelimiter(str: text)
        textField.text = delimeterText
    }
    
    @objc func tfDidChange(_ textField: UITextField) {
        validate()
    }
}
