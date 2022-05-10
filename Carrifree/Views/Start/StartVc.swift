//
//  StartVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/04.
//

import UIKit

class StartVc: UIViewController {

    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var vcDesc: UILabel!
    @IBOutlet weak var start: UIButton!
    @IBOutlet weak var signInTitle: UILabel!
    @IBOutlet weak var signIn: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        vcTitle.font = UIFont(name: "NanumSquareEB", size: 26)
        vcTitle.text = "안녕하세요.\n캐리프리 입니다."
        
        vcDesc.font = UIFont(name: "NanumSquareR", size: 16)
        vcDesc.text = "여행자를위한 새로운 서비스를 경험하세요."
        
        start.setTitle("시 작 하 기", for: .normal)
        start.titleLabel?.font = UIFont(name: "NanumSquareB", size: 20)
        start.addTarget(self, action: #selector(self.onStart(_:)), for: .touchUpInside)
        start.layer.cornerRadius = start.frame.height / 2
        start.layer.borderWidth = 1
        start.layer.borderColor = UIColor(red: 120/255, green: 120/255, blue: 120/255, alpha: 1).cgColor
        
        start.layer.shadowOffset = CGSize(width: 2, height: 2)
        start.layer.shadowRadius = 1
        start.layer.shadowOpacity = 0.2
        
        signInTitle.font = UIFont(name: "NanumSquareR", size: 15)
        signInTitle.text = "이미 계정이 있나요?"
        
        signIn.font = UIFont(name: "NanumSquareB", size: 15)
        signIn.text = "로그인"
        signIn.isUserInteractionEnabled = true
        signIn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onSignIn(_:))))
    }

}

// MARK: - Actions
extension StartVc {
    @objc func onStart(_ sender: UIButton) {
//        let vc = TermsVc()
        let vc = SignupVc()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @objc func onSignIn(_ sender: UIGestureRecognizer) {
        print("onSignIn")
        let vc = SigninVc()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}
