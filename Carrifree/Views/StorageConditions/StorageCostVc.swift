//
//  StorageCostVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/04.
//

import UIKit

class StorageCostVc: UIViewController {

    @IBOutlet weak var board: UIView!                       // 모든 UI가 표시되는 view
    @IBOutlet weak var boardHeight: NSLayoutConstraint!     // board의 height constraint
    @IBOutlet weak var costTitle: UILabel!                  // 제목
    @IBOutlet weak var costview: CostBoard!                 // 요금이 표시되는 view
    
    var originHeight: CGFloat = 0
    var vm: StorageDetailVm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _utils.setText(bold: .bold, size: 20, text: "요금확인", label: costTitle)
        originHeight = boardHeight.constant
        boardHeight.constant = 0
        
        
        let swipeAction = UISwipeGestureRecognizer(target: self, action: #selector(self.onSwipe(_:)))
        swipeAction.numberOfTouchesRequired = 1
        swipeAction.direction = .down
        board.addGestureRecognizer(swipeAction)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onBoard(_:))))
        
        let defaultCosts = vm.getCostStrings(costs: vm.data.defaultCosts)
        let extraCosts = vm.getCostStrings(costs: vm.data.extraCosts)
        let dayCosts = vm.getCostStrings(costs: vm.data.dayCosts)
        costview.configure(defaultCosts: defaultCosts, extraCosts: extraCosts, dayCosts: dayCosts)
        costview.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        board.isHidden = false
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.boardHeight.constant = self.originHeight
            self.view.layoutIfNeeded()
        }, completion: { (_) in
            self.costview.isHidden = false
        })
    }
    
    func dismissWithAnimation() {
        self.view.backgroundColor = .clear
        
        UIView.animate(withDuration: 0.15, animations: { () -> Void in
            self.costview.isHidden = true
            self.boardHeight.constant = 0
            self.view.layoutIfNeeded()
        }, completion: { (_) in
            self.dismiss(animated: false)
        })
    }
}

// MARK: - Actions
extension StorageCostVc {
    @IBAction func onExit(_ sender: UIButton) {
        dismissWithAnimation()
    }
    
    @objc func onSwipe(_ sender: UIGestureRecognizer) {
        dismissWithAnimation()
    }
    
    @objc func onBoard(_ sender: UIGestureRecognizer) {
        dismissWithAnimation()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension StorageCostVc: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 터치 영역이 해당 View의 Frame 안에 포함되는지를 파악해 리턴
        return !self.board.frame.contains(touch.location(in: self.view))
    }
}
