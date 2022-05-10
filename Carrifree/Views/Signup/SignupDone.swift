//
//  VerificationComplete.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/04.
//

import UIKit

class SignupDone: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var idTitle: UILabel!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var nameTitle: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phoneTitle: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var eye: UIButton!
    @IBOutlet weak var start: UIButton!
    
    var idStr: String = ""
    var pwStr: String = ""
    
    var security: Bool = true
    var phoneOrigin: String = ""
    var phoneSecurity: String = ""
    var xibLoaded: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    
    func loadNib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: SignupDone.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        title.font = UIFont(name: "NanumSquareEB", size: 30)
        title.text = "가입이\n완료되었습니다."
        
        _utils.drawDottedLine(start: CGPoint(x: 0, y: 0), end: CGPoint(x: line.frame.maxX, y: 0), view: line)
        
        let titleFont = UIFont(name: "NanumSquareR", size: 20)
        idTitle.font = titleFont
        idTitle.text = _strings[.id]
        
        nameTitle.font = titleFont
        nameTitle.text = _strings[.name2]
        
        phone.font = titleFont
        phone.text = "휴대폰"
        
        start.titleLabel?.font = UIFont(name: "NanumSquareB", size: 20)
        start.setTitle("시작하기", for: .normal)
        start.addTarget(self, action: #selector(self.onStart(_:)), for: .touchUpInside)
    }
    
    func configure(id: String, pw: String, name: String, phone: String) {
        configure()
        phoneOrigin = phone
        idStr = id
        pwStr = pw
        
        let font = UIFont(name: "NanumSquareB", size: 20)
        self.id.font = font
        self.id.text = id
        
        self.name.font = font
        self.name.text = name
        
        let phone = getPhoneText(phone: phone, needScurity: true)
        self.phone.font = font
        self.phone.text = phone
    }
    
    /// 폰번호에 구분자 추가
    func getPhoneText(phone: String, needScurity: Bool) -> String {
        var phone = phone
        
        // 폰번호가 10자리일 경우 '000-***-0000' 형식의 문자열을 만든다
        if phone.count == 10 {
            // - 표시
            let firstIndex = phone.index(phone.startIndex, offsetBy: 3)
            phone.insert("-", at: firstIndex)
            
            let secondIndex = phone.index(phone.startIndex, offsetBy: 7)
            phone.insert("-", at: secondIndex)
            
            phoneOrigin = phone
            
            // * 표시
            if needScurity {
                let startIndex = phone.index(phone.startIndex, offsetBy: 4)
                let endIndex = phone.index(phone.startIndex, offsetBy: 6)
                phone.replaceSubrange(startIndex ... endIndex, with: "***")
                
                phoneSecurity = phone
            }
        }
        // 폰번호가 11자리 이상일 경우 '000-****-0000' 형식의 문자열을 만든다
        else if phone.count > 10 {
            // - 표시
            let firstIndex = phone.index(phone.startIndex, offsetBy: 3)
            phone.insert("-", at: firstIndex)
            
            let secondIndex = phone.index(phone.startIndex, offsetBy: 8)
            phone.insert("-", at: secondIndex)
            
            phoneOrigin = phone
            
            // * 표시
            if needScurity {
                let startIndex = phone.index(phone.startIndex, offsetBy: 4)
                let endIndex = phone.index(phone.startIndex, offsetBy: 7)
                phone.replaceSubrange(startIndex ... endIndex, with: "****")
                
                phoneSecurity = phone
            }
        }
        
        return phone
    }

    func setSecurity(security: Bool) {
        self.security = security
        
        if security {
            eye.setImage(UIImage(systemName: "eye"), for: .normal)
            phone.text = phoneSecurity
        } else {
            eye.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            phone.text = phoneOrigin
        }
    }
}


// MARK: - Actions
extension SignupDone {
    @IBAction func onShowPhoneNumber(_ sender: UIButton) {
        setSecurity(security: !security)
    }
    
    @objc func onStart(_ sender: UIButton) {
        // 로그인
        _cas.signin.signin(id: idStr, pw: pwStr) { (success, json) in
            if let json = json, true == success {
                _user.saveData(userId: self.idStr, userPw: self.pwStr, json: json)
                
                let deviceAuthUrl = json["resUrl"].stringValue
                guard false == deviceAuthUrl.isEmpty else {
                    _log.log("로그인하지 못했습니다.\n(디바이스 인증 url을 받지 못했습니다)")
                    _utils.topViewController()?.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                    return
                }
                
                // 디바이스 정보 전송
                _cas.signin.sendDeviceInfo(userSeq: _user.seq, url: deviceAuthUrl, userName: _user.name) { (success, json) in
                    if success { _user.signIn = true }
                    else { _log.log(ApiManager.getFailedMsg(defaultMsg: "로그인하지 못했습니다.", json: json)) }
                    _utils.topViewController()?.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                }
            } else {
                _utils.removeIndicator()
                _log.log(ApiManager.getFailedMsg(defaultMsg: "로그인하지 못했습니다.", json: json))
                _utils.topViewController()?.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            }
        }
    }
}
