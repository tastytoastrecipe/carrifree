//
//  NotificationsVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/26.
//
//
//  💬 NotificationsVc
//  알림 화면 (알림 목록 표시)
//

import UIKit

class NotificationsVc: NaviVc {

    @IBOutlet weak var board: UIView!
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var vcDesc: UILabel!
    @IBOutlet weak var category: PointMenu!
    @IBOutlet weak var sv: UIScrollView!
    @IBOutlet weak var stack: UIStackView!
    
    var vm: NotificationVm!
    var boardOriginY: CGFloat = 0               // board(navi를 제외한 전체 뷰)의 원래 Y값
    var items: [NotificationItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation
        createMyNavi(title: _strings[.settingsSection03], naviCase: .normal, btns: [], backHidden: false)
        myNavi.delegate = self
        setBoard()
        
        // add swipe on view
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.onSwipe(_:)))
        swipeGesture.numberOfTouchesRequired = 1
        swipeGesture.direction = .down
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(swipeGesture)
        
        // scroll view delegate
        sv.delegate = self
        
        // view model
        vm = NotificationVm(delegate: self)
        
        // ui
        _utils.setText(bold: .extraBold, size: 30, text: "알림", label: vcTitle)
        _utils.setText(bold: .regular, size: 17, text: "캐리프리에서 알림", label: vcDesc)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        for cnst in self.board.constraints {
            if cnst.firstAttribute == .top {
                boardOriginY = cnst.constant
                boardTopCnst = cnst
                break
            }
        }
    }
    
    func configure() {
        category.configure(itemTitles: vm.category)
        category.delegate = self
        getNoti(category: 0)
    }
    
    // request notifications
    func getNoti(category: Int) {
        if false == _utils.createIndicator() { return }
        let noticase = NotiCase(rawValue: category) ?? .none
        vm.getNotifications(noticase: noticase) { (success, msg) in
            _utils.removeIndicator()
            if success {
                self.refreshNoti(notifications: self.vm.notifications)
            } else {
                let alert = _utils.createSimpleAlert(title: _strings[.requestFailed], message: msg, buttonTitle: _strings[.ok], handler: nil)
                self.present(alert, animated: true)
            }
        }
    }
    
    // refresh notification list
    func refreshNoti(notifications: [NotificationData]) {
        items.forEach({ $0.removeFromSuperview() })
        items.removeAll()
        
        for notiData in notifications {
            let item = NotificationItem(frame: CGRect.zero)
            item.translatesAutoresizingMaskIntoConstraints = false
            item.heightAnchor.constraint(equalToConstant: 0).isActive = true
            item.configure(data: notiData)
            stack.addArrangedSubview(item)
            items.append(item)
        }
    }
    
    // 네비게이션을 제외한 전체 뷰의 Y위치를 위로 이동시킨다
    // (알림이 보여지는 범위를 늘림)
    func moveBoard(up: Bool) {
        self.board.translatesAutoresizingMaskIntoConstraints = false
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            if up { self.boardTopCnst.constant = -112 }
            else { self.boardTopCnst.constant = self.boardOriginY }
            
            self.board.layoutIfNeeded()
        })
    }
}

// MARK: - Actions
extension NotificationsVc {
    @objc func onSwipe(_ sender: UIGestureRecognizer) {
        moveBoard(up: false)
    }
}

// MARK: - NotificationVmDelegate
extension NotificationsVc: NotificationVmDelegate {
    func ready() {
        configure()
    }
}

// MARK: - PointMenuDelegate
extension NotificationsVc: PointMenuDelegate {
    func onPointMenuSelected(item: PointItem) {
        getNoti(category: item.tag)
    }
}

// MARK: - MyNaviDelegate
extension NotificationsVc: MyNaviDelegate {
    func onBack() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false)
    }
}

// MARK: - UIScrollviewDelegate
extension NotificationsVc: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        moveBoard(up: true)
    }
}
