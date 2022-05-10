//
//  StorageBillConfirmView.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/11.
//
//
//  💬 StorageBillConfirmView
//  주문 상세 내역 화면 아래의 정보 표시 UI
//

import UIKit

protocol StorageBillConfirmViewDelegate {
    func orderCancel()
    func startStorging()
}

class StorageBillConfirmView: UIView {
    
    @IBOutlet weak var board: UIView!
    
    // reserved(예약)
    @IBOutlet weak var reservedView: UIView!
    @IBOutlet weak var reservedTitle: UILabel!
    @IBOutlet weak var reservedCost: UILabel!
    @IBOutlet weak var reservedCancel: UIButton!
    @IBOutlet weak var reservedConfirm: UIButton!
    
    // enstrust(보관중)
    @IBOutlet weak var entrustedView: UIView!
    @IBOutlet weak var entrustedTitle: UILabel!
    @IBOutlet weak var entrustedCost: UILabel!
    @IBOutlet weak var entrustedConfirm: UIButton!
    
    // complete(보관 완료)
    @IBOutlet weak var completedView: UIView!
    @IBOutlet weak var completedSubTitle: UILabel!
    @IBOutlet weak var completedSubDesc: UILabel!
    @IBOutlet weak var completedTitle: UILabel!
    @IBOutlet weak var completedCost: UILabel!
    
    // cancel(주문 취소)
    @IBOutlet weak var canceledView: UIView!
    @IBOutlet weak var canceledSubTitle: UILabel!
    @IBOutlet weak var canceledSubDesc: UILabel!
    @IBOutlet weak var canceledTitle: UILabel!
    @IBOutlet weak var canceledCost: UILabel!
    
    var data: StorageBillDocData!
    var delegate: StorageBillConfirmViewDelegate?
    var xibLoaded: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
        board.isHidden = true
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: StorageBillConfirmView.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        board.isHidden = false
        self.layer.shadowOffset = CGSize(width: 0, height: -2)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.2
        
        _utils.setText(bold: .regular, size: 15, text: "취소하기", color: _symbolColor, button: reservedCancel)
        reservedCancel.layer.cornerRadius = reservedCancel.frame.height / 2
        reservedCancel.layer.borderWidth = 1
        reservedCancel.layer.borderColor = _symbolColor.cgColor
        reservedCancel.addTarget(self, action: #selector(self.onCancel(_:)), for: .touchUpInside)
        _utils.setText(bold: .bold, size: 18, text: "보관요청", color: .white, button: reservedConfirm)
        reservedConfirm.addTarget(self, action: #selector(self.onStart(_:)), for: .touchUpInside)
        
        _utils.setText(bold: .regular, size: 13, text: "결제금액", color: .darkGray, label: reservedTitle)
        _utils.setText(bold: .extraBold, size: 30, text: "", color: .label, label: reservedCost)
        
        _utils.setText(bold: .bold, size: 18, text: "짐 반출 요청", color: .white, button: entrustedConfirm)
        _utils.setText(bold: .regular, size: 20, text: "결제금액", color: .darkGray, label: entrustedTitle)
        _utils.setText(bold: .extraBold, size: 30, text: "", color: .label, label: entrustedCost)
        
        _utils.setText(bold: .bold, size: 16, text: "결제정보", label: completedSubTitle)
        _utils.setText(bold: .bold, size: 14, text: "지원금: -1,000", label: completedSubDesc)
        completedSubDesc.isHidden = true
        
        _utils.setText(bold: .regular, size: 13, text: "정산금액", color: .darkGray, label: completedTitle)
        _utils.setText(bold: .extraBold, size: 30, text: "", color: .label, label: completedCost)
        
        _utils.setText(bold: .bold, size: 16, text: "결제정보", label: canceledSubTitle)
        _utils.setText(bold: .bold, size: 14, text: "카드 승인 취소 완료", label: canceledSubDesc)
        _utils.setText(bold: .regular, size: 13, text: "취소금액", color: .systemRed, label: canceledTitle)
        _utils.setText(bold: .extraBold, size: 30, text: "", color: .systemRed, label: canceledCost)
        
        reservedView.isHidden = true
        entrustedView.isHidden = true
        completedView.isHidden = true
        canceledView.isHidden = true
    }
    
    func configure(data: StorageBillDocData) {
        self.data = data
        configure()
        setStatus(data: data)
    }
        
    // 의뢰 진행 상황에 따라 보여질 view 결정
    func setStatus(data: StorageBillDocData) {
        reservedView.isHidden = true
        entrustedView.isHidden = true
        completedView.isHidden = true
        canceledView.isHidden = true
        
        let cost = "\(data.cost.delimiter)\(_utils.getCurrencyString())"
        let orderStatus = OrderStatus(rawValue: data.orderStatus) ?? .none
        switch orderStatus {
        case .reserved:
            reservedView.isHidden = false
            reservedCost.text = cost
        case .entrust:
            entrustedView.isHidden = false
            entrustedCost.text = cost
        case .take:
            completedView.isHidden = false
            completedCost.text = cost
        case .canceled:
            canceledView.isHidden = false
            canceledCost.text = cost
        default: break
        }
    }
}

// MARK: - Actions
extension StorageBillConfirmView {
    @objc func onCancel(_ sender: UIButton) {
        delegate?.orderCancel()
    }
    
    @objc func onStart(_ sender: UIButton) {
        delegate?.startStorging()
    }
}

