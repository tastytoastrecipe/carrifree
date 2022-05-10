//
//  CostBoard.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/28.
//

import UIKit

class CostBoard: UIView {

    @IBOutlet weak var colSize: UILabel!
    @IBOutlet weak var colDefault: UILabel!
    @IBOutlet weak var colExtra: UILabel!
    @IBOutlet weak var colDay: UILabel!
    
    @IBOutlet var lines: [UIView] = []
    @IBOutlet var totalStack: UIStackView!
    @IBOutlet var titleStack: UIStackView!
    @IBOutlet var titles: [CostTitle] = []
    @IBOutlet var defaultCosts: [CostInput] = []
    @IBOutlet var extraCosts: [CostInput] = []
    @IBOutlet var dayCosts: [CostInput] = []
    
    var xibLoaded: Bool = false
    
    var isValid: Bool {
        for costInput in defaultCosts {
            let cost = costInput.getCost()
            let costInt = Int(_utils.removeDelimiter(str: cost)) ?? 0
            if cost.isEmpty || costInt == 0 {
                return false
            }
        }
        
        for costInput in extraCosts {
            let cost = costInput.getCost()
            let costInt = Int(_utils.removeDelimiter(str: cost)) ?? 0
            if cost.isEmpty || costInt == 0 {
                return false
            }
        }
        
        for costInput in dayCosts {
            let cost = costInput.getCost()
            let costInt = Int(_utils.removeDelimiter(str: cost)) ?? 0
            if cost.isEmpty || costInt == 0 {
                return false
            }
        }
        
        return true
    }
    
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
        guard let view = self.loadNib(name: String(describing: CostBoard.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        
        _utils.setText(bold: .bold, size: 14, text: "짐 사이즈", label: colSize)
        _utils.setText(bold: .bold, size: 14, text: "기본 4시간", label: colDefault)
        _utils.setText(bold: .bold, size: 14, text: "1시간 초과", label: colExtra)
        _utils.setText(bold: .bold, size: 14, text: "1일 최대", label: colDay)
        
        for (i, lug) in LuggageType.allCases.enumerated() {
            if i > titles.count - 1 { continue }
            titles[i].configure(title: lug.luggageName, subTitle: "[\(lug.longName)]", desc: lug.desc)
        }
        
        totalStack.bringSubviewToFront(titleStack)
    }
    
    func configure(defaultCosts: [String], extraCosts: [String], dayCosts: [String]) {
        loadXib()
        configure()
        
        for (i, cost) in self.defaultCosts.enumerated() {
            if i > defaultCosts.count - 1 { continue }
            cost.configure(cost: defaultCosts[i], editable: false)
        }
        
        for (i, cost) in self.extraCosts.enumerated() {
            if i > extraCosts.count - 1 { continue }
            cost.configure(cost: extraCosts[i], editable: false)
        }
        
        for (i, cost) in self.dayCosts.enumerated() {
            if i > dayCosts.count - 1 { continue }
            cost.configure(cost: dayCosts[i], editable: false)
        }
    }
    
    /// 기본 가격 설정 (placeholder)
    func setDefaultCosts(defaultCosts: [String], extraCosts: [String], dayCosts: [String]) {
        for (i, cost) in self.defaultCosts.enumerated() {
            if i > defaultCosts.count - 1 { continue }
            cost.setDefaultCost(cost: defaultCosts[i])
        }
        
        for (i, cost) in self.extraCosts.enumerated() {
            if i > extraCosts.count - 1 { continue }
            cost.setDefaultCost(cost: extraCosts[i])
        }
        
        for (i, cost) in self.dayCosts.enumerated() {
            if i > dayCosts.count - 1 { continue }
            cost.setDefaultCost(cost: dayCosts[i])
        }
    }
    
    /// 사이즈별 기본 가격 String 배열 반환
    func getDefaultCostStrings() -> [String] {
        var costArr: [String] = []
        for cost in defaultCosts {
            costArr.append(cost.getCostWithoutDelimiter())
        }
        return costArr
    }
    
    /// 사이즈별 추가 가격 String 배열 반환
    func getExtraCostStrings() -> [String] {
        var costArr: [String] = []
        for cost in extraCosts {
            costArr.append(cost.getCostWithoutDelimiter())
        }
        return costArr
    }
    
    /// 하루  가격 String 배열 반환
    func getDayCostStrings() -> [String] {
        var costArr: [String] = []
        for cost in dayCosts {
            costArr.append(cost.getCostWithoutDelimiter())
        }
        return costArr
    }
    
    /// 모든 가격이 기본가격 (placeholder)으로 입력되게함
    func setCostsForDefault() {
        for costInput in defaultCosts { costInput.setCost(cost: costInput.cost.placeholder ?? "") }
        for costInput in extraCosts { costInput.setCost(cost: costInput.cost.placeholder ?? "") }
        for costInput in dayCosts { costInput.setCost(cost: costInput.cost.placeholder ?? "") }
    }
    
    /// 유효한 값인지 확인
    func validate() {
        for costInput in defaultCosts { costInput.validate() }
        for costInput in extraCosts { costInput.validate() }
        for costInput in dayCosts { costInput.validate() }
    }
}
