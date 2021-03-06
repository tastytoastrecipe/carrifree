//
//  StorageOrderVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/07.
//
//
//  ๐ฌ StorageOrderVc
//  ์๋ ฅํ ๋ณด๊ด ์กฐ๊ฑด ํ์ธ ํ ์ฃผ๋ฌธํ๋ ํ๋ฉด
//

import UIKit
import DropDown

class StorageOrderVc: NaviVc {
    
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var costTitle: UILabel!
    @IBOutlet weak var costSubTitle01: UILabel!
    @IBOutlet weak var costSubTitle02: UILabel!
    @IBOutlet weak var cost01: UILabel!
    @IBOutlet weak var cost02: UILabel!
    
    @IBOutlet weak var dcTitle: UILabel!
    @IBOutlet weak var dcSubTitle: UILabel!
    @IBOutlet weak var coupon: UIButton!
    @IBOutlet weak var dc: UILabel!
    @IBOutlet weak var couponDc: UILabel!
    
    @IBOutlet weak var paymentTitle: UILabel!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var paymentMenu: UIView!
    @IBOutlet weak var paymentDesc: UILabel!
    
    @IBOutlet weak var noticeTitle: UILabel!
    @IBOutlet weak var noticeDesc: UILabel!
    
    @IBOutlet weak var totalCostTitle: UILabel!
    @IBOutlet weak var totalCost: UILabel!
    @IBOutlet weak var go: UIButton!
    
    var vm: StorageOrderVm!
    var purchasingData: PurchasingData!
    var dropdown: DropDown!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavi()
        setDefault()
        vm = StorageOrderVm()
        vm.purchasingData = purchasingData
        configure()
    }
    
    // navigation
    func setNavi() {
        createMyNavi(title: "๋ณด๊ด ์ฃผ๋ฌธ์", naviCase: .normal, btns: [], backHidden: false)
        myNavi.delegate = self
        setBoard()
    }
    
    // ui defaults
    func setDefault() {
        _utils.setText(bold: .extraBold, size: 30, text: "๊ฒฐ์  ์ ๋ณด ํ์ธ", label: vcTitle)
        _utils.setText(bold: .regular, size: 18, text: "์์ธ์๊ธ", label: costTitle)
        _utils.setText(bold: .bold, size: 14, text: "๋ณด๊ด์๊ธ(์์)", label: costSubTitle01)
        _utils.setText(bold: .bold, size: 14, text: "๋ถ์คํ์ ๋ณดํ๋ฃ", label: costSubTitle02)
        _utils.setText(bold: .bold, size: 16, text: "", label: cost01)
        _utils.setText(bold: .bold, size: 16, text: "", label: cost02)
        _utils.setText(bold: .bold, size: 18, text: "ํ ์ธ์๊ธ", label: dcTitle)
        _utils.setText(bold: .bold, size: 14, text: "๋ถ์คยทํ์ ๋ณดํ๋ฃ(์ง์)", label: dcSubTitle)
        _utils.setText(bold: .bold, size: 16, text: "", label: dc)
        _utils.setText(bold: .bold, size: 13, text: "์ฟ ํฐ์ ์ฉ", color: .white, button: coupon)
        _utils.setText(bold: .bold, size: 16, text: "", label: couponDc)
        coupon.layer.cornerRadius = 4
        _utils.setText(bold: .bold, size: 18, text: "๊ฒฐ์ ์๋จ", label: paymentTitle)
        _utils.setText(bold: .bold, size: 14, text: "์ถ๊ฐํ๊ธฐ", button: add)
        _utils.setText(bold: .bold, size: 15, text: "์์ฝ ์  ์ฃผ์์ฌํญ", label: noticeTitle)
        _utils.setText(bold: .bold, size: 13, text: "์ค์  ๊ฒฐ์ ๋ ๋ณด๊ด์ฌ์์๊ฐ ๋ณด๊ด ์์์ ์งํํ๋ ๊ฒฝ์ฐ ์ด๋ฃจ์ด์ง๋ฉฐ, ๊ธ์ก์ด ์์ดํ ๊ฒฝ์ฐ ์ทจ์ ํ ์ฌ๊ฒฐ์ ๊ฐ ์ด๋ฃจ์ด์ง๋๋ค.", label: noticeDesc)
        _utils.setText(bold: .regular, size: 14, text: "์์ ๋ณด๊ด ์๊ธ", label: totalCostTitle)
        _utils.setText(bold: .extraBold, size: 30, text: "", label: totalCost)
        _utils.setText(bold: .bold, size: 17, text: "๋ณด๊ด์์ฝ", color: .white, button: go)
        go.addTarget(self, action: #selector(self.onGo(_:)), for: .touchUpInside)
        
        paymentMenu.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onPayMenu(_:))))
    }

    func configure() {
        let currency = _utils.getCurrencyString()
        let costStr = _utils.getDelimiter(str: purchasingData.cost)
        let careCostStr = _utils.getDelimiter(str: "\(vm.careCost)")
        let cost = (Int(purchasingData.cost) ?? 0)
        cost01.text = "\(costStr)\(currency)"
        cost02.text = "\(careCostStr)\(currency)"
        dc.text = "-\(careCostStr)\(currency)"
        couponDc.text = "-\(currency)"
        totalCost.text = "\(cost.delimiter)\(currency)"
        setDropdown()
    }
    
    /// ๊ฒฐ์  ์๋จ ํ์
    func setDropdown() {
        guard nil == dropdown else { return }
        let pays: [String] = ["์นด๋"]
        dropdown = DropDown()
        dropdown.dataSource = pays
        dropdown.anchorView = paymentMenu
        dropdown.bottomOffset = CGPoint(x: 0, y: paymentMenu.frame.height)
        dropdown.selectionAction = self.onSelect(index:item:)
        paymentDesc.text = pays[0]
    }
    
    /// Dropdown(์ ๋ ฌ) ๋ฒํผ ํฐ์น
    func onSelect(index: Int, item: String) {
        guard index < dropdown.dataSource.count else { return }
        paymentDesc.text = dropdown.dataSource[index]
    }

}

// MARK: - Actions
extension StorageOrderVc {
    @objc func onPayMenu(_ sender: UIGestureRecognizer) {
        
    }
    
    @objc func onGo(_ sender: UIButton) {
        if false == _utils.createIndicator() { return }
        
        vm.purchasingData.careCost = "\(vm.careCost)"
        
        // ์ง ์ฌ์ง ์๋ก๋
        vm.registerLuggagePicutures(imgs: purchasingData.luggagePictures) { (success, msg) in
            guard success else {
                _utils.removeIndicator()
                let alert = _utils.createSimpleAlert(title: "๊ฒฐ์ ", message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
                return
            }
            self.purchasingData = self.vm.purchasingData
            
            // ๊ฒฐ์  ์์ฒญ
            self.vm.requestPurchasing(purchasingData: self.vm.purchasingData) { (success, msg) in
                _utils.removeIndicator()
                guard success else {
                    let alert = _utils.createSimpleAlert(title: "๊ฒฐ์ ", message: msg, buttonTitle: _strings[.ok])
                    self.present(alert, animated: true)
                    return
                }
                
                self.purchasingData = self.vm.purchasingData
                let vc = ImpPurchasingVc()
                vc.delegate = self
                vc.purchasingData = self.purchasingData
                vc.modalPresentationStyle = .pageSheet
                self.present(vc, animated: true)
            }
        }
    }
}

// MARK: - MyNaviDelegate
extension StorageOrderVc: MyNaviDelegate {
    func onBack() {
        self.dismiss(animated: true)
    }
}

// MARK: - StorageOrderVmDelegate
extension StorageOrderVc: StorageOrderVmDelegate {
    func ready() {
        configure()
    }
}

// MARK: - ImpPurchasingVcDelegate
extension StorageOrderVc: ImpPurchasingVcDelegate {
    func purchasingDone(impUid: String) {
        if impUid.isEmpty { return }
        
        /*
        let vc = ImpPurchasingVc()
        vc.delegate = self
        vc.modalPresentationStyle = .pageSheet
        self.present(vc, animated: true)
        */
    }
}
