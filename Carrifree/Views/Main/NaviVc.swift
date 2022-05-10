//
//  MyNavigationController.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/12.
//
//
//  💬 NaviVc
//  내가 만든 네비게이션을 표시하는 ViewController.
//  실제 UINavigationController의 방식으로 작동하는게 아닌
//  UIViewController의 상단에 커스텀한 NavigationBar를 표시한다.
//

import UIKit

class NaviVc: UIViewController {

    // navi
    lazy var myNavi: MyNavi = {
        let naviHeight: CGFloat = 80
        let tempNavi = MyNavi(frame: CGRect.zero)
//        tempNavi.delegate = self
        return tempNavi
    }()
    
    let boardTopCnstId: String = "boardTop"     // 네비게이션 아래에 보여질(맞닿아 있는) 뷰의 top constraint의 identifier
    var boardTopCnst: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func createMyNavi(title: String, naviCase: MyNavi.NaviCase, btns: [UIButton] = [], backHidden: Bool = false) {
        self.view.addSubview(myNavi)
        myNavi.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            myNavi.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            myNavi.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            myNavi.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            myNavi.heightAnchor.constraint(equalToConstant: 0)
        ])
        
        myNavi.configure(title: title, naviCase: naviCase, btns: btns, backHidden: backHidden)
    }
    
    func changeNaviCase(naviCase: MyNavi.NaviCase) {
        myNavi.setNaviCase(naviCase: naviCase)
    }
    
    func changeTitle(title: String = "") {
        myNavi.setTitle(title: title)
    }
    
    func rightBtnsHidden(hidden: Bool) {
        myNavi.rightStack.isHidden = hidden
    }
    
    func removeRightBtns() {
        myNavi.rightStack.removeAllArrangedSubviews()
    }
    
    /// 표시될 화면을 navigation 아래에 위치하도록 constraint를 조정함
    func setBoard() {
        for constraint in self.view.constraints {
            if constraint.identifier == boardTopCnstId {
                boardTopCnst = constraint
                constraint.constant += myNavi.naviCase.height
                break
            }
        }
    }
    
    /// back 버튼 숨김 / 표시
    func hideBackBtn(hidden: Bool) {
        myNavi.hideBackBtn(hidden: hidden)
    }
}
