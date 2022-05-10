//
//  SignupVm.swift
//  Carrifree
//
//  Created by orca on 2022/02/17.
//  Copyright © 2022 plattics. All rights reserved.
//

import Foundation

@objc protocol SignupVmDelegate {
//    func ready()
    @objc func printTime(time: String)
    @objc func pwDelayed()                  // 비밀번호 입력 후 검증 대기시간 됨
    @objc func repwDelayed()                // 비밀번호 재입력 후 검증 대기시간 됨
}

class SignupVm {
    
    var delegate: SignupVmDelegate?
    
    var terms: [TermData] = []          // 약관
    
    var countrycodes: [String] = []
    var inAutheticating: Bool = false   // 인증 진행중
    var authComplete: Bool = false      // 인증 완료
    
    // 휴대폰 인증 타이머
    let authMaxTime: Double = 180.0     // sec (인증 번호 입력 유효 시간)
    var authDelay: Double = 0.0         // sec (딜레이)
    var authTime: Double = 0.0          // sec (현재 까지 진행된 시간)
    var authTimer: Timer? = nil
    
    // 비밀번호 입력 타이머
    var pwTimer:Timer? = nil
    var pwDelay: Double = 0.0
    
    // 비밀번호 재입력 타이머
    var repwTimer:Timer? = nil
    var repwDelay: Double = 0.0
    
    init(delegate: SignupVmDelegate?) {
        self.delegate = delegate
        setDatas()
    }
    
    func setDatas() {
        countrycodes.append("+ 82")
        authDelay = 1.1
        pwDelay = 1.0
        repwDelay = 1.0
    }
    
    // 인증 유효 시간 text 갱신
    private func refreshAuthTimeText() {
        let diveding: Double = 60
        let minute = Int(authTime / diveding)
        let second = Int(authTime.truncatingRemainder(dividingBy: diveding))
        
        var minuteStr = "\(minute)"
        if minute < 10 { minuteStr = "0\(minute)" }
        
        var secondStr = "\(second)"
        if second < 10 { secondStr = "0\(secondStr)" }
        
        let time = "\(minuteStr) : \(secondStr)"
        
        delegate?.printTime(time: time)
        
//        _log.log("auth time: \(time)")
//        authTimeLabel.text = time
    }
    
    // 인증 유효 시간 계산
    @objc private func calculateAuthTime() {
        refreshAuthTimeText()
        authTime -= 1.0
        
        if authTime < 0 { stopAuthTimer() }
        else            { callAuthTimer() }
        
    }
    
    // 인증 시간 타이머 호출
    private func callAuthTimer() {
        authTimer?.invalidate()
        authTimer = Timer.scheduledTimer(timeInterval: authDelay, target: self, selector: #selector(self.calculateAuthTime), userInfo: nil, repeats: false)
    }
    
    /// 휴대폰 인증 번호 입력 타이머 시작
    func startAuthTimer() {
        self.authTime = self.authMaxTime
        self.calculateAuthTime()
    }
    
    func stopAuthTimer() {
        authTime = 0.0
        authTimer?.invalidate()
        refreshAuthTimeText()
    }
    
    /// 비밀번호 입력 후 인증 대기 타이머 시작
    func startPwDelay() {
        pwTimer?.invalidate()
        pwTimer = Timer.scheduledTimer(timeInterval: pwDelay, target: self, selector: #selector(self.endPwDelay), userInfo: nil, repeats: false)
    }
    
    @objc func endPwDelay() {
        delegate?.pwDelayed()
    }
    
    /// 비밀번호 입력 후 인증 대기 타이머 계산
    func startRepwDelay() {
        repwTimer?.invalidate()
        repwTimer = Timer.scheduledTimer(timeInterval: repwDelay, target: self, selector: #selector(self.endRepwDelay), userInfo: nil, repeats: false)
    }
    
    @objc func endRepwDelay() {
        delegate?.repwDelayed()
    }
    
    // MARK: - 약관 조회
    func requestTerms(termType: String = "", completion: ResponseString = nil) {
        _cas.signup.requestTerms() { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "약관 정보를 불러오지 못했습니다. 다시 시도해주시기 바랍니다.", json: json))
                return
            }
            
            let arr = json["termsList"].arrayValue
            for val in arr {
                let seq = val["board_seq"].stringValue
                let title = val["board_title"].stringValue
                let content = val["board_memo"].stringValue
                let requiredText = val["division_yn"].stringValue
                let required = (requiredText == "Y")
                let term = TermData(seq: seq, title: title, content: content, required: required)
                self.terms.append(term)
            }
            
            completion?(true, "")
        }
    }
    
    // MARK: - ID 유효성 검증
    func isAvailableId(id: String, completion: ResponseString = nil) {
        _cas.signup.isAvailableId(id: id) { (success, json) in
            var msg: String = ""
            if success {
                
            } else {
                // resCd = "9890"       // 중복
                msg = _strings[.alertNoAvailableId]
            }
                
            completion?(success, msg)
        }
    }
    
    // MARK: - 휴대폰 인증 번호 요청
    func requestAuth(phone: String, completion: ResponseString = nil) {
        // test!
        if simpleSignupMode {
            completion?(true, "")
            return
        }
        
        _cas.signup.requestAuth(phone: phone, signup: true) { (success, json) in
            var message: String = ""
            if false == success { message = ApiManager.getFailedMsg(defaultMsg: "핸드폰 인증 요청을 완료하지 못했습니다.", json: json) }
            completion?(success, message)
        }
    }
    
    // MARK: - 휴대폰 인증
    func doAuth(phone: String, authNo: String, completion: ResponseString = nil) {
        // test!
        if simpleSignupMode {
            completion?(true, "")
            return
        }
        
        _cas.signup.doAuth(phone: phone, authNo: authNo) { (success, json) in
            var message: String = ""
            if false == success { message = ApiManager.getFailedMsg(defaultMsg: "인증을 완료하지 못했습니다.", json: json) }
            completion?(success, message)
        }
    }
    
    // MARK: - 회원가입
    func signup(id: String, pw: String, phone: String, name: String, completion: ResponseString = nil) {
        _cas.signup.signup(id: id, pw: pw, phone: phone, name: name) { (success, json) in
            var message: String = ""
            if success { message = _strings[.alertSignUpComplete] }
            else { message = ApiManager.getFailedMsg(defaultMsg: "회원가입을 완료하지 못했습니다.", json: json)}
            completion?(success, message)
        }
    }
}
