//
//  MyNavigationController.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/12.
//
//
//  ๐ฌ NaviVc
//  ๋ด๊ฐ ๋ง๋  ๋ค๋น๊ฒ์ด์์ ํ์ํ๋ ViewController.
//  ์ค์  UINavigationController์ ๋ฐฉ์์ผ๋ก ์๋ํ๋๊ฒ ์๋
//  UIViewController์ ์๋จ์ ์ปค์คํํ NavigationBar๋ฅผ ํ์ํ๋ค.
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
    
    let boardTopCnstId: String = "boardTop"     // ๋ค๋น๊ฒ์ด์ ์๋์ ๋ณด์ฌ์ง(๋ง๋ฟ์ ์๋) ๋ทฐ์ top constraint์ identifier
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
    
    /// ํ์๋  ํ๋ฉด์ navigation ์๋์ ์์นํ๋๋ก constraint๋ฅผ ์กฐ์ ํจ
    func setBoard() {
        for constraint in self.view.constraints {
            if constraint.identifier == boardTopCnstId {
                boardTopCnst = constraint
                constraint.constant += myNavi.naviCase.height
                break
            }
        }
    }
    
    /// back ๋ฒํผ ์จ๊น / ํ์
    func hideBackBtn(hidden: Bool) {
        myNavi.hideBackBtn(hidden: hidden)
    }
}
