//
//  StorageDoneVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/07.
//
//
//  💬 StorageDoneVc
//  보관 주문 완료 화면
//

import UIKit

class StorageDoneVc: UIViewController {

    @IBOutlet weak var stack: UIStackView!
    
    @IBOutlet weak var titleBoard: UIView!
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var orderNo: UILabel!
    @IBOutlet weak var line: UIView!
    
    @IBOutlet weak var detailBoard: UIView!
    @IBOutlet weak var detailTitle: UILabel!
    
    @IBOutlet weak var bizNameTitle: UILabel!
    @IBOutlet weak var bizName: UILabel!
    
    @IBOutlet weak var scheduleTitle: UILabel!
    @IBOutlet weak var schedule: UILabel!
    
    @IBOutlet weak var luggagesTtile: UILabel!
    @IBOutlet weak var luggages: UILabel!
    
    @IBOutlet weak var costTitle: UILabel!
    @IBOutlet weak var cost: UILabel!
    
    @IBOutlet weak var etcTitle: UILabel!
    @IBOutlet weak var etc: UILabel!
    
    @IBOutlet weak var goHistory: UIButton!
    @IBOutlet weak var goMain: UIButton!
    
    var vm: StorageDoneVm!
    var purchasingData: PurchasingData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefault()
        vm = StorageDoneVm(delegate: self)
    }

    // ui defaults
    func setDefault() {
        let deviceHeight = UIScreen.main.bounds.height
        _log.logWithArrow("device height", "\(deviceHeight)")
        if deviceHeight > 840 { stack.spacing = 7 }
        else if deviceHeight > 700 {
            stack.spacing = 3
        }
        else {
            stack.spacing = 0
        }
        
        titleBoard.roundCorners(cornerRadius: 20, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        
        detailBoard.roundCorners(cornerRadius: 20, maskedCorners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        
        _utils.drawDottedLine(start: CGPoint(x: 0, y: 1), end: CGPoint(x: line.frame.maxX, y: 1), view: line, thickness: 2, pattern: (dash: 4.5, gap: 3), color: .darkGray)
        
        var titleStr = "예약이\n완료되었습니다."
        if deviceHeight < 700 { titleStr = "예약 완료" }
        _utils.setText(bold: .extraBold, size: 30, text: titleStr, color: .white, lineSpacing: 6, label: vcTitle)
        _utils.setText(bold: .regular, size: 15, text: "", color: .white, label: orderNo)
        _utils.setText(bold: .extraBold, size: 20, text: "예약내역", label: detailTitle)
        _utils.setText(bold: .bold, size: 16, text: "보관베이스", label: bizNameTitle)
        _utils.setText(bold: .bold, size: 19, text: "", label: bizName)
        _utils.setText(bold: .bold, size: 16, text: "보관시간", label: scheduleTitle)
        _utils.setText(bold: .bold, size: 15, text: "", label: schedule)
        _utils.setText(bold: .bold, size: 16, text: "짐정보", label: luggagesTtile)
        _utils.setText(bold: .bold, size: 15, text: "", label: luggages)
        _utils.setText(bold: .bold, size: 16, text: "결제금액", label: costTitle)
        _utils.setText(bold: .extraBold, size: 18, text: "", label: cost)
        _utils.setText(bold: .bold, size: 16, text: "결제정보", label: etcTitle)
        _utils.setText(bold: .regular, size: 14, text: "", label: etc)
        
        _utils.setText(bold: .bold, size: 16, text: "상세 내역 확인", color: _symbolColor, button: goHistory)
        goHistory.backgroundColor = .white
        goHistory.tintColor = _symbolColor
        goHistory.layer.cornerRadius = goHistory.frame.height / 2
        goHistory.layer.borderColor = goHistory.tintColor.cgColor
        goHistory.layer.borderWidth = 1
        goHistory.addTarget(self, action: #selector(self.onHistory(_:)), for: .touchUpInside)
        
        _utils.setText(bold: .bold, size: 16, text: "메인 화면 이동", color: .white, button: goMain)
        goMain.backgroundColor = _symbolColor
        goMain.tintColor = .white
        goMain.layer.cornerRadius = goMain.frame.height / 2
        goMain.addTarget(self, action: #selector(self.onMain(_:)), for: .touchUpInside)
    }
    
    func configure() {
        orderNo.text = "예약번호: \(purchasingData.orderNo)"
        bizName.text = purchasingData.bizName
        let scheduleStr = "\(purchasingData.startDate)\n~ \(purchasingData.endDate)"
        _utils.setText(bold: .bold, size: 15, text: scheduleStr, alignment: .right, label: schedule)
        let luggagesText = createLuggageText()
        luggages.text = luggagesText
        let costStr = _utils.getDelimiter(str: purchasingData.cost)
        cost.text = "\(costStr)\(_utils.getCurrencyString())"
        etc.text = "지원금: -\(purchasingData.careCost)"
    }
    
    func createLuggageText() -> String {
        var luggagesText = ""
        if purchasingData.luggages.s > 0 {
            luggagesText += "(\(LuggageType.s.name))\(purchasingData.luggages.s)"
        }
        
        if purchasingData.luggages.m > 0 {
            if false == luggagesText.isEmpty { luggagesText = ", " }
            luggagesText += "(\(LuggageType.m.name))\(purchasingData.luggages.m)"
        }
        
        if purchasingData.luggages.l > 0 {
            if false == luggagesText.isEmpty { luggagesText = ", " }
            luggagesText += "(\(LuggageType.l.name))\(purchasingData.luggages.l)"
        }
        
        if purchasingData.luggages.xl > 0 {
            if false == luggagesText.isEmpty { luggagesText = ", " }
            luggagesText += "(\(LuggageType.xl.name))\(purchasingData.luggages.xl)"
        }
        
        return luggagesText
    }
    
}

// MARK: - Ations
extension StorageDoneVc {
    @objc func onHistory(_ sender: UIButton) {
        _events.purchaseDone(seeBills: true)
    }
    
    @objc func onMain(_ sender: UIButton) {
        _events.purchaseDone(seeBills: false)
//        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
}

// MARK: - MyNaviDelegate
extension StorageDoneVc: MyNaviDelegate {
    func onBack() {
        self.dismiss(animated: true)
    }
}


// MARK: - StorageDoneVmDelegate
extension StorageDoneVc: StorageDoneVmDelegate {
    func ready() {
        configure()
    }
}

