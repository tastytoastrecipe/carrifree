//
//  ForgetPwVm.swift
//  Carrifree
//
//  Created by orca on 2022/03/03.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 ForgetPwVm
//  PW 찾기 화면 view model
//

import Foundation
import StoreKit

@objc protocol ForgetPwVmDelegate: ForgetIdVmDelegate {
    @objc func pwDelayed()                  // 비밀번호 입력 후 검증 대기시간 됨
    @objc func repwDelayed()                // 비밀번호 재입력 후 검증 대기시간 됨
}

class ForgetPwVm: ForgetIdVm {
    // 비밀번호 입력 타이머
    var pwTimer: Timer? = nil
    var pwDelay: Double = 0.0
    
    // 비밀번호 재입력 타이머
    var repwTimer:Timer? = nil
    var repwDelay: Double = 0.0
    
    private var delegate: ForgetPwVmDelegate?
    
    init(delegate: ForgetPwVmDelegate) {
        super.init(delegate: delegate)
        self.delegate = delegate
        pwDelay = 1.0
        repwDelay = 1.0
    }
    
    /// 비밀번호 입력 후 유효성 검사 타이머 시작
    func startPwDelay() {
        pwTimer?.invalidate()
        pwTimer = Timer.scheduledTimer(timeInterval: pwDelay, target: self, selector: #selector(self.endPwDelay), userInfo: nil, repeats: false)
    }
    
    @objc func endPwDelay() {
        delegate?.pwDelayed()
    }
    
    /// 비밀번호 재입력 후 유효성 검사 타이머 시작
    func startRepwDelay() {
        repwTimer?.invalidate()
        repwTimer = Timer.scheduledTimer(timeInterval: repwDelay, target: self, selector: #selector(self.endRepwDelay), userInfo: nil, repeats: false)
    }
    
    @objc func endRepwDelay() {
        delegate?.repwDelayed()
    }
    
    // MARK: - PW 재설정
    func resetPw(id: String, phone: String, pw: String, completion: ResponseString = nil) {
        _cas.forgetPw.resetPw(id: id, phone: phone, pw: pw) { (success, json) in
            var message: String = ""
            if false == success { message = ApiManager.getFailedMsg(defaultMsg: "비밀번호를 재설정하지 못했습니다.", json: json) }
            completion?(success, message)
        }
    }
}
