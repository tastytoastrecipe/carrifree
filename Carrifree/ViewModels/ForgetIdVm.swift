//
//  ForgetIdVm.swift
//  Carrifree
//
//  Created by orca on 2022/03/03.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 ForgetIdVm
//  ID 찾기 화면 view model
//

import Foundation

@objc protocol ForgetIdVmDelegate {
    @objc func printTime(time: String)
}

class ForgetIdVm {
    private var delegate: ForgetIdVmDelegate?
    
    // 휴대폰 인증 타이머
    let authMaxTime: Double = 180.0     // sec (인증 번호 입력 유효 시간)
    var authDelay: Double = 0.0         // sec (딜레이)
    var authTime: Double = 0.0          // sec (현재 까지 진행된 시간)
    var authTimer: Timer? = nil
    
    var countrycodes: [String] = []
    var resultId: String = ""
    
    init(delegate: ForgetIdVmDelegate) {
        self.delegate = delegate
        authDelay = 1.1
        countrycodes.append("+ 82")
    }
    
    /// 휴대폰 인증 번호 입력 타이머 시작
    func startAuthTimer() {
        self.authTime = self.authMaxTime
        self.calculateAuthTime()
    }
    
    /// 타이머 정지
    func stopAuthTimer() {
        authTime = 0.0
        authTimer?.invalidate()
        refreshAuthTimeText()
    }
    
    /// 인증 유효 시간 text 갱신
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
    
    /// 인증 유효 시간 계산
    @objc private func calculateAuthTime() {
        refreshAuthTimeText()
        authTime -= 1.0
        
        if authTime < 0 { stopAuthTimer() }
        else            { callAuthTimer() }
        
    }
    
    /// 인증 시간 타이머 호출
    private func callAuthTimer() {
        authTimer?.invalidate()
        authTimer = Timer.scheduledTimer(timeInterval: authDelay, target: self, selector: #selector(self.calculateAuthTime), userInfo: nil, repeats: false)
    }
    
    // MARK: - 휴대폰 인증 번호 요청
    func requestAuth(phone: String, completion: ResponseString = nil) {
        _cas.signup.requestAuth(phone: phone, signup: false) { (success, json) in
            var message: String = ""
            if false == success { message = ApiManager.getFailedMsg(defaultMsg: "인증 요청을 완료하지 못했습니다.", json: json) }
            
            completion?(success, message)
        }
    }
    
    // MARK: - 휴대폰 인증
    func doAuth(phone: String, authNo: String, completion: ResponseString = nil) {
        _cas.signup.doAuth(phone: phone, authNo: authNo) { (success, json) in
            var message: String = ""
            if false == success { message = ApiManager.getFailedMsg(defaultMsg: "인증을 완료하지 못했습니다.", json: json) }
            
            completion?(success, message)
        }
    }
    
    // MARK: - ID 찾기
    final func findId(phone: String, completion: ResponseString = nil) {
        resultId = ""
        _cas.forgetId.findId(phone: phone) { (success, json) in
            if let json = json, true == success {
                let id = json["USER_ID"].stringValue
                if id.isEmpty {
                    completion?(false, "서버로 부터 잘못된 응답을 받았습니다. 다시 시도해주시기 바랍니다.")
                } else {
                    self.resultId = id
                    completion?(true, "")
                }
            } else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "아이디를 찾지 못했습니다.", json: json))
            }
        }
    }
}
