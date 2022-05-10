//
//  SigninVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/05.
//

import UIKit
import DropDown

class SigninVc: UIViewController {
    
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var vcDesc: UILabel!
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var forgetId: UILabel!
    @IBOutlet weak var forgetPw: UILabel!
    @IBOutlet weak var signin: UIButton!
    @IBOutlet weak var signup: UIButton!
    
    var vm: SigninVm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaults()
        vm = SigninVm()
    }
    
    /*
    // 키보드 높이만큼 특정 view 위치 이동
    @objc func keyboardWillShow() {
        if self.board.frame.origin.y < 0 { return }
        board.translatesAutoresizingMaskIntoConstraints = true
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            self.board.frame.origin.y -= 250
        })
    }

    // 키보드 사라질때 특정 view를 원래 위치로 이동
    @objc func keyboardWillHide() {
        board.translatesAutoresizingMaskIntoConstraints = false
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            self.board.frame.origin.y += 250
        })
    }
     */
    
    
    func setDefaults() {
        _utils.setText(bold: .extraBold, size: 25, text: "안녕하세요.\n캐리프리입니다.", label: vcTitle)
        _utils.setText(bold: .regular, size: 15, text: "여행자의 자유로운 여행을 위한", label: vcDesc)
        _utils.setText(bold: .regular, size: 17, text: "", placeHolder: _strings[.id], field: idField)
        _utils.setText(bold: .regular, size: 17, text: "", placeHolder: _strings[.pw], field: pwField)
        _utils.setText(bold: .regular, size: 14, text: _strings[.findId], color: .darkGray, label: forgetId)
        forgetId.isUserInteractionEnabled = true
        forgetId.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onForgetId(_:))))
        _utils.setText(bold: .regular, size: 14, text: _strings[.findPw], color: .darkGray, label: forgetPw)
        forgetPw.isUserInteractionEnabled = true
        forgetPw.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onForgetPw(_:))))
        _utils.setText(bold: .bold, size: 17, text: _strings[.signIn], color: .white, button: signin)
        signin.addTarget(self, action: #selector(self.onSignin(_:)), for: .touchUpInside)
        _utils.setText(bold: .bold, size: 17, text: _strings[.signUp], color: .darkGray, button: signup)
        signup.layer.borderWidth = 1
        signup.layer.borderColor = UIColor.darkGray.cgColor
        signup.addTarget(self, action: #selector(self.onSignup(_:)), for: .touchUpInside)
    }
    
    func requestSignin() {
        let id = idField.text ?? ""
        let pw = pwField.text ?? ""
        let enpw = _utils.encodeToMD5(pw: pw)
        
        if false == _utils.createIndicator() { return }
        vm.signin(id: id, pw: enpw) { (success, msg) in
            _utils.removeIndicator()
            if success {
                self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            } else {
                let alert = _utils.createSimpleAlert(title: _strings[.signIn], message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
            }
            
        }
    }
    
    func moveScene(destination: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.present(destination, animated: false, completion: nil)
    }
}

// MARK: - Actions
extension SigninVc {
    @objc func onSignin(_ sender: UIButton) {
        requestSignin()
    }
    
    @objc func onSignup(_ sender: UIButton) {
        let vc = SignupVc()
        vc.modalPresentationStyle = .fullScreen
        moveScene(destination: vc)
    }
    
    @objc func onForgetId(_ sender: UIButton) {
        let vc = ForgetIdVc()
        vc.modalPresentationStyle = .fullScreen
        vc.prevVcTtile = _strings[.signIn]
        moveScene(destination: vc)
    }
    
    @objc func onForgetPw(_ sender: UIButton) {
        let vc = ForgetPwVc()
        vc.modalPresentationStyle = .fullScreen
        vc.prevVcTtile = _strings[.signIn]
        moveScene(destination: vc)
    }
    
}
