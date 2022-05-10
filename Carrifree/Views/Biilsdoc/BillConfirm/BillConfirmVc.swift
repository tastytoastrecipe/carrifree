//
//  OrderNoticeVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/11/08.
//

import UIKit

@objc protocol BillConfirmVcDelegate {
    @objc optional func onContinue()
    @objc optional func onExit(confirmed: Bool)
}

class BillConfirmVc: UIViewController {
    @IBOutlet weak var board: UIView!
    @IBOutlet weak var boardHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var exitBtn: UIButton!
    
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var vcDesc: UILabel!
    
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var continueView: UIView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var originHeight: CGFloat = 0
    var vm: BilldocVm!
    var delegate: BillConfirmVcDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateBoard(appear: true)
    }
    
    func configure() {
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.onSwipe(_:)))
        swipeGesture.numberOfTouchesRequired = 1
        swipeGesture.direction = .down
        self.view.addGestureRecognizer(swipeGesture)
        self.view.isUserInteractionEnabled = true
        
        _utils.setText(bold: .bold, size: 23, text: "짐 보관을 진행하시겠습니까?", label: vcTitle)
        _utils.setText(bold: .regular, size: 14, text: "짐을 맡긴 후에는 주문을 취소(환불)할 수 없습니다.", label: vcDesc)
        
        // exit
        exitBtn.setTitle("", for: .normal)
        exitBtn.titleLabel?.font = UIFont(name: "NanumSquareB", size: 16)
        exitBtn.addTarget(self, action: #selector(self.onExit(_:)), for: .touchUpInside)
        
        // cancel
        cancelBtn.setTitle(_strings[.backToContent], for: .normal)
        cancelBtn.titleLabel?.font = UIFont(name: "NanumSquareB", size: 16)
        cancelBtn.addTarget(self, action: #selector(self.onExit(_:)), for: .touchUpInside)
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = cancelBtn.tintColor.cgColor
        
        // continue
        continueBtn.setTitle("네 맡길게요", for: .normal)
        continueBtn.titleLabel?.font = UIFont(name: "NanumSquareB", size: 16)
        continueBtn.layer.borderWidth = 1
        continueBtn.layer.borderColor = continueBtn.tintColor.cgColor
        continueBtn.addTarget(self, action: #selector(self.onContinue(_:)), for: .touchUpInside)

        // line
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            _utils.drawDottedLine(start: CGPoint(x: 0, y: 0), end: CGPoint(x: self.line.frame.width, y: 0), view: self.line, pattern: (5, 2))
        }
        originHeight = boardHeightConstraint.constant
        boardHeightConstraint.constant = 0
    }
    
    func animateBoard(appear: Bool, completion: (() -> Void)? = nil) {
        if appear {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.boardHeightConstraint.constant = self.originHeight
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                completion?()
            })
            
        } else {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.boardHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                completion?()
            })
        }
    }
    
    func exit(confirmed: Bool) {
        self.view.backgroundColor = .clear
        animateBoard(appear: false) {
            self.dismiss(animated: true)
            self.delegate?.onExit?(confirmed: confirmed)
        }
    }
    
}

// MARK: - Actions
extension BillConfirmVc {
    @objc func onExit(_ sedner: UIButton) {
        exit(confirmed: false)
    }
    
    @objc func onSwipe(_ sender: Any) {
        exit(confirmed: false)
    }
    
    @objc func onContinue(_ sender: UIButton) {
        if false == _utils.createIndicator() { return }
        vm.changeOrderStatus(orderStatus: OrderStatus.entrust.rawValue, storageSeq: vm.data.storageSeq) { (success, msg) in
            _utils.removeIndicator()
            guard success else {
                let alert = _utils.createSimpleAlert(title: _strings[.storage], message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
                self.exit(confirmed: false)
                return
            }
            
            self.exit(confirmed: true)
        }
    }
}
