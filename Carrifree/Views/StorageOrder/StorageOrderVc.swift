//
//  StorageOrderVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/07.
//
//
//  💬 StorageOrderVc
//  입력한 보관 조건 확인 후 주문하는 화면
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
        createMyNavi(title: "보관 주문서", naviCase: .normal, btns: [], backHidden: false)
        myNavi.delegate = self
        setBoard()
    }
    
    // ui defaults
    func setDefault() {
        _utils.setText(bold: .extraBold, size: 30, text: "결제 정보 확인", label: vcTitle)
        _utils.setText(bold: .regular, size: 18, text: "상세요금", label: costTitle)
        _utils.setText(bold: .bold, size: 14, text: "보관요금(예상)", label: costSubTitle01)
        _utils.setText(bold: .bold, size: 14, text: "분실파손 보험료", label: costSubTitle02)
        _utils.setText(bold: .bold, size: 16, text: "", label: cost01)
        _utils.setText(bold: .bold, size: 16, text: "", label: cost02)
        _utils.setText(bold: .bold, size: 18, text: "할인요금", label: dcTitle)
        _utils.setText(bold: .bold, size: 14, text: "분실·파손 보험료(지원)", label: dcSubTitle)
        _utils.setText(bold: .bold, size: 16, text: "", label: dc)
        _utils.setText(bold: .bold, size: 13, text: "쿠폰적용", color: .white, button: coupon)
        _utils.setText(bold: .bold, size: 16, text: "", label: couponDc)
        coupon.layer.cornerRadius = 4
        _utils.setText(bold: .bold, size: 18, text: "결제수단", label: paymentTitle)
        _utils.setText(bold: .bold, size: 14, text: "추가하기", button: add)
        _utils.setText(bold: .bold, size: 15, text: "예약 전 주의사항", label: noticeTitle)
        _utils.setText(bold: .bold, size: 13, text: "실제 결제는 보관사업자가 보관 시작을 진행하는 경우 이루어지며, 금액이 상이한 경우 취소 후 재결제가 이루어집니다.", label: noticeDesc)
        _utils.setText(bold: .regular, size: 14, text: "예상 보관 요금", label: totalCostTitle)
        _utils.setText(bold: .extraBold, size: 30, text: "", label: totalCost)
        _utils.setText(bold: .bold, size: 17, text: "보관예약", color: .white, button: go)
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
    
    /// 결제 수단 표시
    func setDropdown() {
        guard nil == dropdown else { return }
        let pays: [String] = ["카드"]
        dropdown = DropDown()
        dropdown.dataSource = pays
        dropdown.anchorView = paymentMenu
        dropdown.bottomOffset = CGPoint(x: 0, y: paymentMenu.frame.height)
        dropdown.selectionAction = self.onSelect(index:item:)
        paymentDesc.text = pays[0]
    }
    
    /// Dropdown(정렬) 버튼 터치
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
        
        // 짐 사진 업로드
        vm.registerLuggagePicutures(imgs: purchasingData.luggagePictures) { (success, msg) in
            guard success else {
                _utils.removeIndicator()
                let alert = _utils.createSimpleAlert(title: "결제", message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
                return
            }
            self.purchasingData = self.vm.purchasingData
            
            // 결제 요청
            self.vm.requestPurchasing(purchasingData: self.vm.purchasingData) { (success, msg) in
                _utils.removeIndicator()
                guard success else {
                    let alert = _utils.createSimpleAlert(title: "결제", message: msg, buttonTitle: _strings[.ok])
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
