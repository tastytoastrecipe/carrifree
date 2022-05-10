//
//  SettingsVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/25.
//
//
//  💬 SettingsVc
//  환경설정 화면
//

import UIKit

class SettingsVc: NaviVc {
    
    @IBOutlet weak var board: UIView!
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var notiTitle: UILabel!
    @IBOutlet weak var etcTitle: UILabel!
    @IBOutlet var items: [TitleSwitchView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        createMyNavi(title: _strings[.settingsSection03], naviCase: .normal, btns: [], backHidden: false)
        myNavi.delegate = self
        setBoard()
        
        _utils.setText(bold: .extraBold, size: 30, text: "환경설정", label: vcTitle)
        _utils.setText(bold: .extraBold, size: 20, text: "알림", label: notiTitle)
        _utils.setText(bold: .extraBold, size: 20, text: "기능", label: etcTitle)
        setItems()
    }
    
    

    func setItems() {
        let itemTitles: [(title: String, subtitle: String)] = [
            (title: "이벤트 및 혜택", subtitle: "쿠폰 및 마케팅 정보 알림"),
            (title: "리뷰 쓰기 알림", subtitle: "21시 ~ 08시 알림 없음"),
            (title: "리뷰 댓글 알림", subtitle: "21시 ~ 08시 알림 없음"),
            (title: "안심번호 사용", subtitle: "개인정보를 보호하기 위해 임의의 번호를 표시")
        ]
        
        for (i, item) in items.enumerated() {
            guard i < itemTitles.count else { break }
            let itemTitle = itemTitles[i]
            item.configure(title: itemTitle.title, subtitle: itemTitle.subtitle, on: true, tag: i)
        }
    }
    

}

// MARK: - MyNaviDelegate
extension SettingsVc: MyNaviDelegate {
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
