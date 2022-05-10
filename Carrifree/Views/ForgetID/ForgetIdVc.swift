//
//  ForgetIdVc.swift
//  Carrifree
//
//  Created by orca on 2022/03/02.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 ForgetIdVc
//  ID 찾기 화면
//

import UIKit
import DropDown

class ForgetIdVc: UIViewController {
    
    // navi
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var naviTitle: UILabel!
    
    // title
    @IBOutlet weak var vcTitle: UILabel!
    
    // phone
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var phoneTitle: UILabel!
    @IBOutlet weak var countrycode: UILabel!
    @IBOutlet weak var country: UIView!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var requestAuthView: UIView!
    @IBOutlet weak var requestAuth: UIButton!
    
    // auth
    @IBOutlet weak var doAuthView: UIView!
    @IBOutlet weak var limit: UILabel!
    @IBOutlet var pads: [BackwardTextField]!
    @IBOutlet weak var doAuth: UIButton!
    
    // result
    @IBOutlet private weak var resultView: UIView!
    @IBOutlet private weak var resultTitle: UILabel!
    @IBOutlet private weak var resultId: UILabel!
    @IBOutlet weak var signin: UIButton!
    
    var prevVcTtile: String = ""      // 이전 화면 제목
    var dropdown: DropDown!
    var codeLevel = AuthCodeLevel.empty
    var vm: ForgetIdVm!

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = ForgetIdVm(delegate: self)
        setDefaults()
    }
    
    func setDefaults() {
        setNavi()
        setRequestAuthView()
        setDoAuthView()
        setDropdown()
        setResultView()
    }
    
    /// 네비게이션 view 설정
    func setNavi() {
        _utils.setText(bold: .regular, size: 14, text: prevVcTtile, button: back)
        back.addTarget(self, action: #selector(self.onBack(_:)), for: .touchUpInside)
    }
    
    /// 인증요청 view 설정
    func setRequestAuthView() {
        _utils.setText(bold: .extraBold, size: 17, text: _strings[.findId], color: _symbolColor, label: naviTitle)
        _utils.setText(bold: .bold, size: 20, text: "등록된 휴대전화 인증이 완료된 후 아이디를 찾을 수 있습니다.", color: .label, label: vcTitle)
        _utils.setText(bold: .regular, size: 20, text: "등록된 휴대폰 번호", label: phoneTitle)
        _utils.setText(bold: .extraBold, size: 23, text: "", color: .label, label: countrycode)
        country.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onCountrycode(_:))))
        _utils.setText(bold: .regular, size: 18, text: "", placeHolder: "휴대폰 번호 입력", field: phone)
        
        requestAuth.layer.cornerRadius = requestAuth.frame.height / 2
        requestAuth.layer.borderColor = _symbolColor.cgColor
        requestAuth.layer.borderWidth = 1
        requestAuth.addTarget(self, action: #selector(self.onRequestAuth(_:)), for: .touchUpInside)
        _utils.setText(bold: .bold, size: 17, text: "인증번호 전송", color: _symbolColor, button: requestAuth)
    }
    
    /// 인증 view 설정
    func setDoAuthView() {
        _utils.setText(bold: .bold, size: 15, text: "", label: limit)
        _utils.setText(bold: .bold, size: 18, text: _strings[.findId], color: .white, button: doAuth)
        doAuth.addTarget(self, action: #selector(self.onFindId(_:)), for: .touchUpInside)
        doAuthView.isHidden = true
        
        for pad in pads {
            pad.addTarget(self, action: #selector(self.onEnterCode(_:)), for: .editingChanged)
            pad.addTarget(self, action: #selector(self.onEditCodeBegin(_:)), for: .editingDidBegin)
            pad.backspaceCalled = self.onCodeBackspace
        }
    }
    
    /// 찾기 결과 view 설정
    private func setResultView() {
        resultView.isHidden = true
        _utils.setText(bold: .bold, size: 20, text: "아이디 찾기 결과입니다.", label: resultTitle)
        _utils.setText(bold: .extraBold, size: 33, text: "", color: .label, label: resultId)
        _utils.setText(bold: .bold, size: 18, text: _strings[.signIn], color: .white, button: signin)
        signin.addTarget(self, action: #selector(self.onSignin(_:)), for: .touchUpInside)
    }
    
    /// 국제 전화 코드 표시
    func setDropdown() {
        guard nil == dropdown else { return }
        dropdown = DropDown()
        dropdown.dataSource = vm.countrycodes
        dropdown.anchorView = country
        dropdown.bottomOffset = CGPoint(x: 0, y: country.frame.height)
        dropdown.selectionAction = self.onSelect(index:item:)
        if vm.countrycodes.count > 0 { countrycode.text = vm.countrycodes[0] }
    }
    
    /// 국제 전화 코드 선택
    func onSelect(index: Int, item: String) {
        guard index < vm.countrycodes.count else { return }
        
        dropdown.hide()
        countrycode.text = vm.countrycodes[index]
    }
    
    func createSecurityId(idStr: String?) -> String {
        guard var idStr = idStr else { return "" }
        if idStr.isEmpty || idStr.count < 4 { return idStr }
        
        // 변환할 문자열 범위
        let range = idStr.index(idStr.startIndex, offsetBy: 2) ..< idStr.index(idStr.endIndex, offsetBy: -1)
        
        // 변환할 문자열 개수
        let count = idStr.distance(from: range.lowerBound, to: range.upperBound)
        
        // 변환할 문자열 생성
        var replaceStr = ""
        for _ in 0 ..< count {
            replaceStr += "*"
        }
        
        // 문자열 변환
        idStr.replaceSubrange(range, with: replaceStr)
        return idStr
    }

    func moveBack() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false)
    }

}

// MARK: - Actions
extension ForgetIdVc {
    @objc func onBack(_ sender: UIButton) {
        moveBack()
    }
    
    @objc func onCountrycode(_ sender: UIGestureRecognizer) {
        dropdown.show()
    }
    
    @objc func onRequestAuth(_ sender: UIButton) {
        if vm.authTime > 0 {
            let alert = _utils.createSimpleAlert(title: "휴대폰 인증", message: "기존에 보내진 코드를 남은 시간 안에 입력해주세요.", buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
            return
        }
        
        guard let phoneStr = phone.text, false == phoneStr.isEmpty else {
            let alert = _utils.createSimpleAlert(title: _strings[.findId], message: _strings[.alertEnterPhone], buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
            return
        }
        
        vm.requestAuth(phone: phoneStr) { (success, msg) in
            if success {
                if sender.layer.borderColor != UIColor.systemGray.cgColor {
                    sender.layer.borderColor = UIColor.systemGray.cgColor
                    sender.setTitle("인증번호 재전송", for: .normal)
                    sender.setTitleColor(.systemGray, for: .normal)
                }
                self.doAuthView.isHidden = false
                self.vm.startAuthTimer()
            } else {
                let alert = _utils.createSimpleAlert(title: "", message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
            }
        }
    }
    
    // 인증코드 입력 시작
    @objc func onEditCodeBegin(_ sender: UITextField) {
        if sender == phone { return }
        
        let text = sender.text ?? ""
        if text.count > 0 {
            codeLevel = AuthCodeLevel.filled
        } else {
            codeLevel = AuthCodeLevel.empty
        }
    }
    
    // 인증 코드 수정
    @objc func onEnterCode(_ sender: UITextField) {
        let text = sender.text ?? ""
        let textCount = text.count
        
        // 한글자만 입력되게 함
        if textCount > 1 {
            let result = String(text[text.startIndex])
            sender.text = result
        }
        
        // 아무것도 입력되지 않았을때(지웠을때)에는 포커스를 이동시키지않음
        if textCount == 0 { codeLevel = AuthCodeLevel.removed; return }
        codeLevel = AuthCodeLevel.filled
        
        // 코드가 입력되었을때 오른쪽의 TextField로 포커싱을 이동시킴
        for (index, pad) in pads.enumerated() {
            let nextIndex = index + 1
            if pad == sender && nextIndex < pads.count {
                pads[nextIndex].becomeFirstResponder()
            }
        }
    }
    
    // Backspace 버튼 터치시 호출됨
    @objc func onCodeBackspace(sender: BackwardTextField) {
        // 코드가 비어있을때 지우기 버튼을 터치하면 왼쪽의 TextField로 포커싱을 이동시킴
        guard codeLevel == .empty else {
            if codeLevel == .removed { codeLevel = .empty }
            return
        }
        
        for (index, pad) in pads.enumerated() {
            let prevIndex = index - 1
            if pad == sender && prevIndex > -1 {
                pads[prevIndex].becomeFirstResponder()
            }
        }
    }
    
    @objc private func onFindId(_ sender: UIButton) {
        guard let phoneStr = phone.text, false == phoneStr.isEmpty else {
            let alert = _utils.createSimpleAlert(title: _strings[.findId], message: _strings[.alertEnterPhone], buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
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
            guard success else {
                let alert = _utils.createSimpleAlert(title: _strings[.findId], message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
                return
            }
            
            self.vm.findId(phone: phoneStr) { (success, msg) in
                if success {
                    self.vcTitle.isHidden = true
                    self.phoneView.isHidden = true
                    self.requestAuthView.isHidden = true
                    self.doAuthView.isHidden = true
                    self.resultView.isHidden = false
                    
                    let idStr = self.createSecurityId(idStr: self.vm.resultId)
                    self.resultId.text = idStr
                } else {
                    let alert = _utils.createSimpleAlert(title: "아이디 찾기", message: msg, buttonTitle: _strings[.ok])
                    self.present(alert, animated: true)
                }
            }
        }
        
        
        
        
    }
    
    @objc func onSignin(_ sender: UIButton) {
        moveBack()
    }
}

// MARK: - ForgetIdVmDelegate
extension ForgetIdVc: ForgetIdVmDelegate {
    func printTime(time: String) {
        limit.text = "제한시간 \(time)"
    }
}
