//
//  VerificationVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/04.
//

import UIKit
import DropDown

class SignupVc: UIViewController {
    // navi
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var naviTitle: UILabel!
    
    // board
    @IBOutlet weak var board: UIView!
    @IBOutlet weak var scrollview: UIScrollView!
    
    // terms
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var agreeAll: UIView!
    @IBOutlet weak var agreeAllIcon: UIImageView!
    @IBOutlet weak var agreeAllTitle: UILabel!
    @IBOutlet weak var termsStack: UIStackView!
    
    // phone
    @IBOutlet weak var phoneTitle: UILabel!
    @IBOutlet weak var countrycode: UILabel!
    @IBOutlet weak var country: UIView!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var requestAuth: UIButton!
    
    // auth
    @IBOutlet weak var doAuthView: UIView!
    @IBOutlet weak var limit: UILabel!
    @IBOutlet weak var doAuth: UIButton!
    @IBOutlet var pads: [BackwardTextField]!
    
    // id
    @IBOutlet weak var idView: UIView!
    @IBOutlet weak var idTitle: UILabel!
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var idCheck: UIButton!
    @IBOutlet weak var idDesc: UILabel!
    @IBOutlet weak var idAvailable: UIButton!
    
    // name
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameTitle: UILabel!
    @IBOutlet weak var nameField: UITextField!
    
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
    
    // signup
    @IBOutlet weak var signupView: UIView!
    @IBOutlet weak var signup: UIButton!
    @IBOutlet weak var signupDone: SignupDone!
    
    var isAgreeAll: Bool {
        get {
            var agreeAll: Bool = false
            for term in terms {
                guard term.data.required else { continue }
                agreeAll = term.agree
                guard agreeAll else { break }
            }
            
            return agreeAll
        }
    }
    
    var vm: SignupVm!
    var dropdown: DropDown! = nil
    var terms: [TermCell] = []
    var codeLevel = AuthCodeLevel.empty
    var codeWriting: Bool = false           // 인증코드 작성중인지 여부
    
    lazy var signupManager = SignUpManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        board.isHidden = true
        self.navigationItem.title = _strings[.signUp]
        
        vm = SignupVm(delegate: self)
        vm.requestTerms() { (success, msg) in
            if success {
                self.configure()
            } else {
                self.createSimpleAlert(msg: msg)
                self.dismiss()
            }
            
            self.board.isHidden = false
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
        UIView.animate(withDuration: 0.24, animations: { () -> Void in
            self.board.frame.origin.y += 250
        })
    }
    
    func configure() {
        
        _utils.setText(bold: .regular, size: 14, text: _strings[.signIn], button: back)
        back.addTarget(self, action: #selector(self.onBack(_:)), for: .touchUpInside)
        _utils.setText(bold: .extraBold, size: 17, text: _strings[.signUp], color: _symbolColor, label: naviTitle)
        _utils.setText(bold: .extraBold, size: 30, text: "이용 약관 확인", label: vcTitle)
        _utils.setText(bold: .regular, size: 20, text: "약관 전체 동의", label: agreeAllTitle)
        agreeAll.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onAgreeAll(_:))))
        
        var currentIndex: Int = 2
        vm.terms.forEach({
            let termCell = TermCell()
            termCell.configure(data: $0)
            termsStack.insertArrangedSubview(termCell, at: currentIndex)
            termCell.translatesAutoresizingMaskIntoConstraints = false
            termCell.heightAnchor.constraint(equalToConstant: 40).isActive = true
            termCell.setHeightCnst()
            termCell.delegate = self
            terms.append(termCell)
            currentIndex += 1
        })
        
        // phone
        _utils.setText(bold: .bold, size: 15, text: "휴대폰 번호", label: phoneTitle)
        _utils.setText(bold: .extraBold, size: 22, text: "", label: countrycode)
        phone.placeholder = "‘-’를 제외한 전화번호를 입력해주세요"
        _utils.setText(bold: .extraBold, size: 22, text: "", field: phone)
        phone.addTarget(self, action: #selector(self.onEditPhoneBegin(_:)), for: .editingDidBegin)
        phone.addTarget(self, action: #selector(self.onEditPhoneEnd(_:)), for: .editingDidEnd)
        phone.addTarget(self, action: #selector(self.onEditPhone(_:)), for: .editingChanged)
        country.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onCountrycode(_:))))
        setDropdown()
        
        // auth
        requestAuth.layer.cornerRadius = requestAuth.frame.height / 2
        requestAuth.layer.borderColor = _symbolColor.cgColor
        requestAuth.layer.borderWidth = 1
        requestAuth.addTarget(self, action: #selector(self.onRequestAuth(_:)), for: .touchUpInside)
        _utils.setText(bold: .bold, size: 17, text: "인증번호 전송", color: _symbolColor, button: requestAuth)
        _utils.setText(bold: .bold, size: 15, text: "", label: limit)
        _utils.setText(bold: .bold, size: 17, text: "인증하기", color: .white, button: doAuth)
        doAuth.addTarget(self, action: #selector(self.onDoAuth(_:)), for: .touchUpInside)
        for pad in pads {
            pad.addTarget(self, action: #selector(self.onEnterCode(_:)), for: .editingChanged)
            pad.addTarget(self, action: #selector(self.onEditCodeBegin(_:)), for: .editingDidBegin)
            pad.addTarget(self, action: #selector(self.onEditCodeEnd(_:)), for: .editingDidEnd)
            pad.backspaceCalled = self.onCodeBackspace
        }
        doAuthView.isHidden = true
        
        // id
        _utils.setText(bold: .regular, size: 20, text: "사용할 아이디", label: idTitle)
        _utils.setText(bold: .regular, size: 15, text: "", field: idField)
        idField.placeholder = "아이디를 입력해주세요"
        _utils.setText(bold: .regular, size: 13, text: "중복 체크", color: UIColor.systemGray, button: idCheck)
        idCheck.layer.cornerRadius = idCheck.frame.height / 2
        idCheck.layer.borderColor = UIColor.systemGray.cgColor
        idCheck.layer.borderWidth = 1
        idCheck.addTarget(self, action: #selector(self.onDuplicationCheck(_:)), for: .touchUpInside)
        _utils.setText(bold: .regular, size: 12, text: "", label: idDesc)
        _utils.setText(bold: .regular, size: 13, text: "확인 완료", color: .white, button: idAvailable)
        idAvailable.layer.cornerRadius = idAvailable.frame.height / 2
        idAvailable.backgroundColor = _availableColor
        idAvailable.isHidden = true
        idView.isHidden = true
        
        // name
        _utils.setText(bold: .regular, size: 20, text: "성명", label: nameTitle)
        _utils.setText(bold: .regular, size: 15, text: "", field: nameField)
        nameField.placeholder = "성명을 입력해 주세요"
        nameView.isHidden = true
        
        // password
        _utils.setText(bold: .regular, size: 20, text: "비밀번호", label: pwTitle)
        _utils.setText(bold: .regular, size: 15, text: "", field: pwField)
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
        _utils.setText(bold: .regular, size: 15, text: "", field: repwField)
        repwField.placeholder = "비밀번호를 다시 한번 입력해주세요"
        repwField.isSecureTextEntry = true
        repwField.addTarget(self, action: #selector(self.onPwChanged(_:)), for: .editingChanged)
        repwField.addTarget(self, action: #selector(self.onPwEditBegin(_:)), for: .editingDidBegin)
        repwField.addTarget(self, action: #selector(self.onPwEditEnd(_:)), for: .editingDidEnd)
        repwEye.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        repwEye.setImage(UIImage(systemName: "eye"), for: .selected)
        repwEye.addTarget(self, action: #selector(self.onRepwEye(_:)), for: .touchUpInside)
        _utils.setText(bold: .regular, size: 12, text: "", label: repwDesc)
        
        // sign up
        _utils.setText(bold: .bold, size: 19, text: _strings[.signUp], color: .white, button: signup)
        signup.addTarget(self, action: #selector(self.onSignup(_:)), for: .touchUpInside)
        signupView.isHidden = true
    }
    
    /// 전체 약관 동의
    func reverseAgreeAll() {
        let agree = isAgreeAll
        if agree {
            agreeAllIcon.image = UIImage(systemName: "checkmark.circle")
            agreeAllIcon.tintColor = .systemGray
            terms.forEach({ $0.setAgree(agree: false) })
            
        } else {
            agreeAllIcon.image = UIImage(systemName: "checkmark.circle.fill")
            agreeAllIcon.tintColor = _availableColor
            terms.forEach({ $0.setAgree(agree: true) })
        }
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
    
    /// 회원가입 필수 요건 확인
    func checkConditions() -> Bool {
        // 필수 약관 동의 확인
        if false == isAgreeAll {
            let alert = _utils.createSimpleAlert(title: "약관 동의", message: "필수 약관을 확인한 후 동의해주세요.", buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
            return false
        }
        /*
        for termCell in terms {
            if termCell.data.required == false { continue }
            if false == termCell.agree {
                createSimpleAlert(msg: "필수 약관에 동의해주시기 바랍니다.")
                return false
            }
        }
        */
        
        // 휴대폰 번호 입력 확인
        if true == phone.text?.isEmpty {
            createSimpleAlert(msg: "휴대폰 번호를 입력해주세요")
            return false
        }
        
        // 휴대폰 인증 확인
        guard vm.authComplete else {
            createSimpleAlert(msg: "휴대폰 인증을 완료해주세요")
            return false
        }
        
        // 아이디 입력 확인
        if true == idField.text?.isEmpty {
            createSimpleAlert(msg: _strings[.alertNeedId])
            return false
        }
        
        // 아이디 중복 확인
        guard signupManager.isAvailableId(id: idField.text) else {
            createSimpleAlert(msg: _strings[.alertNeedIdDuplicationCheck])
            return false
        }
        
        // 이름 입력 확인
        if true == nameField.text?.isEmpty {
            createSimpleAlert(msg: _strings[.alertNeedName])
            return false
        }
        
        // 비밀번호 입력 확인
        if true == pwField.text?.isEmpty {
            createSimpleAlert(msg: _strings[.alertNeedPw])
            return false
        }
        
        // 비밀번호 재입력 확인
        if true == repwField.text?.isEmpty {
            createSimpleAlert(msg: _strings[.alertNeedPw])
            return false
        }
        
        guard signupManager.pwAvailable else {
            createSimpleAlert(msg: _strings[.alertUnavailablePw])
            return false
        }
        
        return true
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
        
        signupManager.passwordVerification(pw: pwText) { (available, msg) in
            if available { self.pwDesc.textColor = _availableColor }
            else { self.pwDesc.textColor = .red }
            self.pwDesc.text = msg
        }
    }
    
    /// 재입력한 비밀번호 유효 여부 표시
    @objc func displayRepwStatus() {
        let pwText = pwField.text ?? ""; if pwText.isEmpty { return }
        let repwText = repwField.text ?? ""; if repwText.isEmpty { return }
        
        if signupManager.passwordCompare(pw01: pwText, pw02: repwText) {
            repwDesc.text = ""
        } else {
            repwDesc.textColor = .red
            repwDesc.text = _strings[.alertPwNotMatch]
        }
    }
    
    /// id 중복확인 후 나타나는 설명 text의 alpha값을 animate
    func animateIdDesc() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.idDesc.alpha = 1
        })
    }
    
    func createSimpleAlert(msg: String) {
        let alert = _utils.createSimpleAlert(title: _strings[.signUp], message: msg, buttonTitle: _strings[.ok])
        self.present(alert, animated: true)
    }
    
    func dismiss() {
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
}

// MARK: - Actions
extension SignupVc {
    
    @objc func onBack(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false)
    }
    
    @objc func onAgreeAll(_ sender: UIGestureRecognizer) {
        reverseAgreeAll()
    }
    
    @objc func onCountrycode(_ sender: UIGestureRecognizer) {
        dropdown.show()
    }
    
    @objc func onEditPhoneBegin(_ sender: UITextField) {
        keyboardWillShow()
    }
    
    @objc func onEditPhoneEnd(_ sender: UITextField) {
        keyboardWillHide()
    }
     
    @objc func onEditPhone(_ sender: UITextField) {
        self.vm.authComplete = false
        
        // 폰번호를 모두 지웠을때 다시 인증 요청 UI를 표시함
        if sender.text?.isEmpty == true {
            vm.stopAuthTimer()
//            authView.isHidden = false
//            signinView.isHidden = true
        }
    }
    
    @objc func onRequestAuth(_ sender: UIButton) {
        // 약관 동의 확인
        guard isAgreeAll else {
            let alert = _utils.createSimpleAlert(title: "약관 동의", message: "필수 약관을 확인한 후 동의해주세요.", buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
            return
        }
        
        if vm.authTime > 0 {
            let alert = _utils.createSimpleAlert(title: "휴대폰 인증", message: "기존에 보내진 코드를 남은 시간 안에 입력해주세요.", buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
            return
        }
        
        guard let phoneStr = phone.text, false == phoneStr.isEmpty else {
            createSimpleAlert(msg: "휴대폰 번호를 입력해주세요.")
            return
        }
        self.view.endEditing(true)
        
        vm.requestAuth(phone: phoneStr) { (success, msg) in
            if success {
                if sender.layer.borderColor != UIColor.systemGray.cgColor {
                    sender.layer.borderColor = UIColor.systemGray.cgColor
                    sender.setTitle("인증번호 재전송", for: .normal)
                    sender.setTitleColor(.systemGray, for: .normal)
                }
                
                self.doAuthView.isHidden = false
                self.vm.inAutheticating = true
                self.vm.startAuthTimer()
                self.scrollview.scroll(to: .bottom)
            } else {
                self.createSimpleAlert(msg: msg)
            }
        }
        
    }
    
    // 인증코드 입력 시작
    @objc func onEditCodeBegin(_ sender: UITextField) {
        keyboardWillShow()
        if sender == phone { return }
        
        let text = sender.text ?? ""
        if text.count > 0 {
            codeLevel = AuthCodeLevel.filled
        } else {
            codeLevel = AuthCodeLevel.empty
        }
    }
    
    // 인증코드 입력 완료
    @objc func onEditCodeEnd(_ sender: UITextField) {
        keyboardWillHide()
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
                codeWriting = true
                pads[nextIndex].becomeFirstResponder()
            }
        }
    }
    
    // Backspace 버튼 터치시 호출됨
    func onCodeBackspace(sender: BackwardTextField) {
        // 코드가 비어있을때 지우기 버튼을 터치하면 왼쪽의 TextField로 포커싱을 이동시킴
        guard codeLevel == .empty else {
            if codeLevel == .removed { codeLevel = .empty }
            return
        }
        
        for (index, pad) in pads.enumerated() {
            let prevIndex = index - 1
            if pad == sender && prevIndex > -1 {
                codeWriting = true
                pads[prevIndex].becomeFirstResponder()
            }
        }
    }
    
    @objc func onDoAuth(_ sender: UIButton) {
        guard let phoneStr = phone.text, false == phoneStr.isEmpty else {
            createSimpleAlert(msg: "휴대폰 번호를 입력해주세요.")
            return
        }
        
        // 인증번호 입력 확인
        var authCode: String = ""
        for pad in pads {
            let padText = pad.text ?? ""
            if padText.isEmpty {
                createSimpleAlert(msg: "인증번호를 모두 입력해주세요")
                return
            } else {
                authCode.append(contentsOf: padText)
            }
        }
        
        // 인증 api 호출 후 인증 완료 상태 변경
        vm.doAuth(phone: phoneStr, authNo: authCode) { (success, msg) in
            guard success else { self.createSimpleAlert(msg: msg); return }
            
            self.view.endEditing(true)
            
            self.vm.stopAuthTimer()
            self.vm.inAutheticating = false
            self.vm.authComplete = true
            self.limit.isHidden = true
            
            self.doAuth.setTitleColor(_availableColor, for: .normal)
            self.doAuth.backgroundColor = .white
            self.doAuth.layer.borderColor = _availableColor.cgColor
            self.doAuth.layer.borderWidth = 1
            
            self.idView.isHidden = false
            self.nameView.isHidden = false
            self.pwView.isHidden = false
            self.signupView.isHidden = false
            
            self.scrollview.scroll(to: .center)
        }
    }
    
    /// 중복 확인
    @objc func onDuplicationCheck(_ sender: UIButton) {
        let userId = idField.text ?? ""
        if userId.isEmpty { return }
        
        if userId.count < signupManager.minIdLength {
            createSimpleAlert(msg: _strings[.alertIdLengthMin])
            return
        }
        
        self.idDesc.alpha = 0
        vm.isAvailableId(id: userId) { (success, msg) in
            if success {
                self.idDesc.text = _strings[.alertAvailableId]
                self.idDesc.textColor = _availableColor
                self.signupManager.checkedIds.append(userId)
                self.signupManager.currentId = userId
            } else {
                self.idDesc.text = msg
                self.idDesc.textColor = .red
            }
            
            self.idAvailable.isHidden = !success
            self.animateIdDesc()
        }
    }
    
    /// 비밀번호 보기/가리기
    @objc func onPwEye(_ sender: UIButton) {
        changeEye(btn: sender, field: pwField)
    }
    
    @objc func onRepwEye(_ sender: UIButton) {
        changeEye(btn: sender, field: repwField)
    }
    
    @objc func onPwChanged(_ sender: UITextField) {
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
    
    @objc func onSignup(_ sender: UIButton) {
        let signupAvailable = checkConditions()
        guard signupAvailable else { return }
        
        let phoneStr = phone.text ?? ""
        let nameStr = nameField.text ?? ""
        vm.signup(id: signupManager.currentId, pw: signupManager.currentPw, phone: phoneStr, name: nameStr) { (success, msg) in
            if success {
                self.signupDone.isHidden = false
                self.signupDone.configure(id: self.signupManager.currentId, pw: self.signupManager.currentPw, name: nameStr, phone: phoneStr)
                self.view.bringSubviewToFront(self.signupDone)
            } else {
                self.createSimpleAlert(msg: msg)
            }
            
        }
    }
    
}

// MARK: - TermCellDelegate
extension SignupVc: TermCellDelegate {
    func spreaded(cell: TermCell) {
        for subview in termsStack.arrangedSubviews {
            if subview === cell { continue }
            guard let termCell = subview as? TermCell else { continue }
            termCell.isSpreaded = false
        }
    }
}

// MARK: - SigninVmDelegate
extension SignupVc: SignupVmDelegate {
    func printTime(time: String) {
        limit.text = "제한시간 \(time)"
    }
    
    func pwDelayed() {
        displayPwStatus()
    }
    
    func repwDelayed() {
        displayRepwStatus()
    }
}

/*
class SignupVc: UIViewController {
    
    @IBOutlet weak var complete: SignupDone!
    @IBOutlet weak var failed: UIView!
    @IBOutlet weak var failedDesc: UILabel!
    @IBOutlet weak var verification: UIButton!
    @IBOutlet weak var back: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _utils.setText(bold: .regular, size: 17, text: "본인인증을 완료하지 못했습니다. 회원가입을 계속 진행하시려면 본인인증이 필요합니다.", label: failedDesc)
        _utils.setText(bold: .regular, size: 17, text: "인증하기", button: verification)
        verification.backgroundColor = .white
        verification.layer.cornerRadius = (verification.frame.height - 2) / 2
        verification.layer.borderWidth = 1
        verification.layer.borderColor = UIColor(red: 120/255, green: 120/255, blue: 120/255, alpha: 1).cgColor
        verification.layer.shadowOffset = CGSize(width: 2, height: 2)
        verification.layer.shadowRadius = 1
        verification.layer.shadowOpacity = 0.2
        verification.addTarget(self, action: #selector(self.onVerification(_:)), for: .touchUpInside)
        back.addTarget(self, action: #selector(self.onBack(_:)), for: .touchUpInside)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) { self.verificate() }
    }
    
    func verificate() {
        let vc = ImpVerificationVc()
        vc.delegate = self
        vc.modalPresentationStyle = .popover
        self.present(vc, animated: true)
    }
}

// MARK: - Actions
extension SignupVc {
    @objc func onBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @objc func onVerification(_ sender: UIButton) {
        failed.isHidden = true
        back.isHidden = true
        complete.isHidden = true
        verificate()
    }
}

// MARK: - ImpVerificationDelegate
extension SignupVc: ImpVerificationDelegate {
    func disappear() {
        let phone = ImpRequest.shared.phone
        failed.isHidden = !phone.isEmpty
        back.isHidden = !phone.isEmpty
        complete.isHidden = phone.isEmpty
        guard phone.count > 0 else { return }
        
        _log.logWithArrow("폰번호 받아오기 성공!", phone)
        complete.configure(id: "M20000000001", name: "둘리", phone: phone)
        complete.isHidden = false
    }
}
*/
