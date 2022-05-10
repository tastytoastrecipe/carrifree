//
//  CarryNotReadyVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/08.
//

import UIKit

protocol CarryNotReadyVcDelegate {
    func carryVcDismissed()
}

class CarryNotReadyVc: NaviVc {
    
    @IBOutlet weak var board: UIView!
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var vcDesc: UILabel!
    @IBOutlet weak var ok: UIButton!
    
    var delegate: CarryNotReadyVcDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavi()
        configure()
    }

    func configure() {
        board.layer.cornerRadius = 20
        board.clipsToBounds = true
        
        let titleFont01 = UIFont(name: "NanumSquareEB", size: 24)
        let titleFont02 = UIFont(name: "NanumSquareR", size: 24)
        
        // "서비스 준비중" 문자열 생성
        let titleStr01 = "서비스 준비중"
        let titleStr02 = "입니다"
        let totalTitle = "\(titleStr01) \(titleStr02)"
        let attString = NSMutableAttributedString(string: totalTitle, attributes: [
          .font: titleFont01!,
          .foregroundColor: _symbolColor
        ])
        
        // "입니다" 폰트 설정
        attString.addAttributes([
          .font: titleFont02!,
          .foregroundColor: UIColor.label
        ], range: NSRange(location: titleStr01.count + 1, length: titleStr02.count))
        
        vcTitle.attributedText = attString
        
        _utils.setText(bold: .regular, size: 14, text: "현재 운반서비스는 준비중입니다.\n빠른시일내에 완료 하겠습니다.", label: vcDesc)
        _utils.setText(bold: .bold, size: 16, text: _strings[.ok], color: .white, button: ok)
        ok.addTarget(self, action: #selector(self.onOk(_:)), for: .touchUpInside)
    }
    
    // navigation
    func setNavi() {
        createMyNavi(title: "", naviCase: .long, btns: [], backHidden: true)
        NaviEditor.navi = myNavi
        NaviEditor.editNavi(scene: .carry, callbacks: [])
        setBoard()
        
        if let parent = board.superview {
            self.view.bringSubviewToFront(parent)
        }
    }

}

// MARK: - Actions
extension CarryNotReadyVc {
    @objc func onOk(_ sender: UIButton) {
        self.delegate?.carryVcDismissed()
    }
}
