//
//  HistoryCell.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/09.
//
//
//  💬 HistoryCell
//  주문 내역 목록 -> 아이템 안의 각 주문 정보 UI
//

import UIKit

class StorageBillCell: UIView {

    @IBOutlet weak var board: UIView!
    @IBOutlet weak var orderStatus: UILabel!
    @IBOutlet weak var orderCase: UIPaddingLabel!
    @IBOutlet weak var orderNo: UILabel!
    @IBOutlet weak var bizName: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    @IBOutlet weak var line: UIView!
    
    var data: StorageBillData!
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
        guard let view = self.loadNib(name: String(describing: StorageBillCell.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onSelected(_:))))
        self.layer.cornerRadius = 10
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.2
        
        board.layer.cornerRadius = 10
        board.clipsToBounds = true
        
        let labelColor = UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1)
        _utils.setText(bold: .extraBold, size: 25, text: "", color: _symbolColor, label: orderStatus)
        _utils.setText(bold: .regular, size: 11, text: "", color: .darkGray, label: orderCase)
        orderCase.inset = UIEdgeInsets(top: 4, left: 14, bottom: 4, right: 14)
        orderCase.layer.cornerRadius = orderCase.frame.height / 2
        orderCase.layer.borderColor = UIColor.systemGray.cgColor
        orderCase.layer.borderWidth = 1
        _utils.setText(bold: .regular, size: 14, text: "", color: .systemGray, label: orderNo)
        _utils.setText(bold: .extraBold, size: 16, text: "", color: labelColor, label: bizName)
        _utils.setText(bold: .regular, size: 11, text: "", color: .systemGray, label: address)
        _utils.setText(bold: .extraBold, size: 14, text: "", color: labelColor, label: orderDate)
        _utils.drawDottedLine(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: line.frame.maxY), view: line, pattern: (5, 2))
    }
    
    func configure(data: StorageBillData) {
        configure()
        self.data = data
        orderStatus.text = OrderStatus(rawValue: data.orderStatus)?.storageStatusText ?? ""
        orderCase.text = OrderCase(rawValue: data.orderCase)?.name ?? ""
        orderNo.text = data.orderNo
        bizName.text = data.bizName
        address.text = data.address
        orderDate.text = "요청일: \(data.orderDate)"
    }
}

// MARK: - Actions
extension StorageBillCell {
    @objc func onSelected(_ sender: UIGestureRecognizer) {
        let vc = StorageBillDocVc()
        vc.orderSeq = data.orderSeq
        vc.modalPresentationStyle = .overFullScreen
//        _utils.topViewController()?.present(vc, animated: true)
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        _utils.topViewController()?.view.window?.layer.add(transition, forKey: kCATransition)
        _utils.topViewController()?.present(vc, animated: false, completion: nil)
    }
}
