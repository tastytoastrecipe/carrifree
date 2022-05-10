//
//  ForgetPwVc.swift
//  Carrifree
//
//  Created by orca on 2022/03/03.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 ForgetPwVc
//  PW 찾기 화면
//

import UIKit
import DropDown

class ForgetPwVc: ForgetIdVc {
    
    @IBOutlet weak var board: UIView!
    
    // id
    @IBOutlet weak var idView: UIView!
    @IBOutlet weak var idTitle: UILabel!
    @IBOutlet weak var idField: UITextField!
    
    // pw
    @IBOutlet weak var pwView: UIView!
    @IBOutlet weak var pwTitle: UILabel!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var pwDesc: UILabel!
    @IBOutlet weak var pwEye: UIButton!
    
    // re-enter pw
    @IBOutlet weak var repwTitle: UILabel!
    @IBOutlet weak var repwField: UITextField!
    @IBOutlet weak var repwDesc: UILabel!
    @IBOutlet weak var repwEye: UIButton!
    @IBOutlet weak var resetPw: UIButton!
    
    // complete
    @IBOutlet weak var completeView: UIView!
    @IBOutlet weak var completeTitle: UILabel!
    @IBOutlet weak var completeDesc: UILabel!

    var codeWriting: Bool = false           // 인증코드 작성중인지 여부
    
    lazy var signUpManager = SignUpManager()
    
    

    override func viewDidLoad() {
        vm = ForgetPwVm(delegate: self)
        setDefaults()
    }
    
    override func setDefaults() {
        setNavi()
        setIdView()
        setRequestAuthView()
        setDoAuthView()
        setDropdown()
        setPwView()
        setCompleteView()
        
        _utils.setText(bold: .extraBold, size: 17, text: _strings[.findPw], color: _symbolColor, label: naviTitle)
    }
    
    func setIdView() {
        _utils.setText(bold: .regular, size: 20, text: _strings[.id], label: idTitle)
        _utils.setText(bold: .regular, size: 18, text: "", placeHolder: "등록된 아이디를 입력해주세요", field: idField)
    }
    
    override func setRequestAuthView() {
        super.setRequestAuthView()
        _utils.setText(bold: .bold, size: 20, text: "등록된 휴대전화 인증이 완료된 후 비밀번호를 재설정할 수 있습니다.", color: .label, label: vcTitle)
    }
    
    /// 인증 view 설정
    override func setDoAuthView() {
        _utils.setText(bold: .bold, size: 15, text: "", label: limit)
        _utils.setText(bold: .bold, size: 18, text: "인증하기", color: .white, button: doAuth)
        doAuth.addTarget(self, action: #selector(self.onDoAuth(_:)), for: .touchUpInside)
        doAuthView.isHidden = true
        
        for pad in pads {
            pad.addTarget(self, action: #selector(self.onEnterCode(_:)), for: .editingChanged)
            pad.addTarget(self, action: #selector(self.onEditCodeBegin(_:)), for: .editingDidBegin)
            pad.backspaceCalled = self.onCodeBackspace
        }
    }
    
    func setPwView() {
        // password
        _utils.setText(bold: .regular, size: 20, text: "비밀번호", label: pwTitle)
        _utils.setText(bold: .regular, size: 18, text: "", field: pwField)
        pwField.placeholder = _strings[.passwordRule]
        pwField.isSecureTextEntry = true
        pwField.addTarget(self, action: #selector(self.onPwChanged(_:)), for: .editingChanged)
        pwField.addTarget(self, action: #selector(self.onPwEditBegin(_:)), for: .editingDidBegin)
        pwField.addTarget(self, action: #selector(self.onPwEditEnd(_:)), for: .editingDidEnd)
        pwEye.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        pwEye.setImage(UIImage(systemName: "eye"), for: .selected)
        pwEye.addTarget(self, action: #selector(self.onPwEye(_:)), for: .touchUpInside)
        _utils.setText(bold: .regular, size: 12, text: "", label: pwDesc)
        pwView.isHidden = true
        
        // re-enter password
        _utils.setText(bold: .regular, size: 20, text: "비밀번호", label: repwTitle)
        _utils.setText(bold: .regular, size: 18, text: "", field: repwField)
        repwField.placeholder = "비밀번호를 다시 한번 입력해주세요"
        repwField.isSecureTextEntry = true
        repwField.addTarget(self, action: #selector(self.onPwChanged(_:)), for: .editingChanged)
        repwField.addTarget(self, action: #selector(self.onPwEditBegin(_:)), for: .editingDidBegin)
        repwField.addTarget(self, action: #selector(self.onPwEditEnd(_:)), for: .editingDidEnd)
        repwEye.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        repwEye.setImage(UIImage(systemName: "eye"), for: .selected)
        repwEye.addTarget(self, action: #selector(self.onRepwEye(_:)), for: .touchUpInside)
        _utils.setText(bold: .regular, size: 12, text: "", label: repwDesc)
        
        _utils.setText(bold: .bold, size: 18, text: "비밀번호 재설정", color: .white, button: resetPw)
        resetPw.addTarget(self, action: #selector(self.onResetPw(_:)), for: .touchUpInside)
    }
    
    func setCompleteView() {
        completeView.isHidden = true
        _utils.setText(bold: .bold, size: 18, text: _strings[.signIn], color: .white, button: signin)
        _utils.setText(bold: .extraBold, size: 30, text: "비밀번호가\n재설정 되었습니다.", color: .label, label: completeTitle)
        _utils.setText(bold: .regular, size: 20, text: "변경된 비밀번호로 다시 로그인하시기 바랍니다.", label: completeDesc)
        signin.addTarget(self, action: #selector(self.onSignin(_:)), for: .touchUpInside)
    }
    
    /// 비밀번호 보기 버튼 활성화/비활성화
    func changeEye(btn: UIButton, field: UITextField) {
        btn.isSelected = !btn.isSelected
        if btn.isSelected { btn.tintColor = _availableColor }
        else { btn.tintColor = .systemGray }
        
        field.isSecureTextEntry = !btn.isSelected
    }
    
    /// 비밀번호 유효 여부 표시
    @objc func displayPwStatus() {
        let pwText = pwField.text ?? ""; if pwText.isEmpty { return }
        
        signUpManager.passwordVerification(pw: pwText) { (available, msg) in
            if available { self.pwDesc.textColor = _availableColor }
            else { self.pwDesc.textColor = .red }
            self.pwDesc.text = msg
        }
    }
    
    /// 재입력한 비밀번호 유효 여부 표시
    @objc func displayRepwStatus() {
        let pwText = pwField.text ?? ""; if pwText.isEmpty { return }
        let repwText = repwField.text ?? ""; if repwText.isEmpty { return }
        
        if signUpManager.passwordCompare(pw01: pwText, pw02: repwText) {
            repwDesc.text = ""
        } else {
            repwDesc.textColor = .red
            repwDesc.text = _strings[.alertPwNotMatch]
        }
    }
    
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
        if codeWriting { self.codeWriting = false; return }
        board.translatesAutoresizingMaskIntoConstraints = false
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            self.board.frame.origin.y += 250
        })
    }
    
    func createSimpleAlert(msg: String) {
        let alert = _utils.createSimpleAlert(title: "비밀번호 재설정", message: msg, buttonTitle: _strings[.ok])
        self.present(alert, animated: true)
    }
    
}

// MARK: - Actions
extension ForgetPwVc {
    
    override func onEnterCode(_ sender: UITextField) {
        super.onEnterCode(sender)
        codeWriting = true
    }
    
    override func onCodeBackspace(sender: BackwardTextField) {
        super.onCodeBackspace(sender: sender)
        codeWriting = true
    }
    
    @objc func onDoAuth(_ sender: UIButton) {
        // 아이디 입력 확인
        let phoneStr = phone.text ?? ""
        if phoneStr.isEmpty {
            createSimpleAlert(msg: _strings[.alertEnterPhone])
            return
        }
        
        // 인증번호 입력 확인
        var authNo: String = ""
        for pad in pads {
            guard let padText = pad.text, false == padText.isEmpty else {
                let alert = _utils.createSimpleAlert(title: _strings[.findId], message: "인증번호를 모두 입력해주세요", buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
                return
            }
            
            authNo += padText
        }
        
        vm.doAuth(phone: phoneStr, authNo: authNo) { (success, msg) in
            if success {
                self.vm.stopAuthTimer()
                self.limit.isHidden = true
                self.doAuth.setTitleColor(_availableColor, for: .normal)
                self.doAuth.backgroundColor = .white
                self.doAuth.layer.borderColor = _availableColor.cgColor
                self.doAuth.layer.borderWidth = 1
                self.pwView.isHidden = false
            } else {
                self.createSimpleAlert(msg: msg)
            }
        }
        
    }
    
    /// 비밀번호 보기/가리기
    @objc func onPwEye(_ sender: UIButton) {
        changeEye(btn: sender, field: pwField)
    }
    
    /// 비밀번호 재입력 보기/가리기
    @objc func onRepwEye(_ sender: UIButton) {
        changeEye(btn: sender, field: repwField)
    }
    
    @objc func onPwChanged(_ sender: UITextField) {
        guard let vm = vm as? ForgetPwVm else { return }
        
        if (sender === pwField) {
            vm.startPwDelay()
            displayRepwStatus()
        } else if (sender === repwField) {
            vm.startRepwDelay()
        }
    }
    
    @objc func onPwEditBegin(_ sender: UITextField) {
        keyboardWillShow()
    }
    
    @objc func onPwEditEnd(_ sender: UITextField) {
        keyboardWillHide()
    }
    
    @objc func onResetPw(_ sender: UIButton) {
        // 아이디 입력 확인
        guard let idStr = idField.text, false == idStr.isEmpty else {
            createSimpleAlert(msg: _strings[.alertNeedId]); return
        }
        
        guard let phoneStr = phone.text, false == phoneStr.isEmpty else {
            createSimpleAlert(msg: _strings[.alertEnterPhone]); return
        }
        
        // 비밀번호 입력 확인
        guard let pwStr = pwField.text, false == pwStr.isEmpty else  {
            createSimpleAlert(msg: _strings[.alertNeedPw]); return
        }
        
        // 비밀번호 재입력 확인
        if true == repwField.text?.isEmpty {
            createSimpleAlert(msg: _strings[.alertNeedPw]); return
        }
        
        // 비밀번호 유효성 확인
        guard signUpManager.pwAvailable else {
            createSimpleAlert(msg: _strings[.alertUnavailablePw]); return
        }
        
        guard let vm = vm as? ForgetPwVm else {
            createSimpleAlert(msg: "잘못된 접근입니다. 다시 시도해주시기 바랍니다.\n(ForgetPwVm is nil)")
            return
        }
        
        let enpw = signUpManager.currentPw
        vm.resetPw(id: idStr, phone: phoneStr, pw: enpw) { (success, msg) in
            if success {
                self.vcTitle.isHidden = true
                self.idView.isHidden = true
                self.phoneView.isHidden = true
                self.requestAuthView.isHidden = true
                self.doAuthView.isHidden = true
                self.pwView.isHidden = true
                self.completeView.isHidden = false
                self.view.endEditing(true)
            } else {
                self.createSimpleAlert(msg: msg)
            }
        }
    }
    
}

// MARK: - ForgetPwVmDelegate
extension ForgetPwVc: ForgetPwVmDelegate {
    override func printTime(time: String) {
        limit.text = "제한시간 \(time)"
    }
    
    func pwDelayed() {
        displayPwStatus()
    }
    
    func repwDelayed() {
        displayRepwStatus()
    }
}
