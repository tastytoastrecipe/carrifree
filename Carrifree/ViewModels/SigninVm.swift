//
//  SigninVm.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/05.
//
//
//  💬 SigninVm
//  로그인 view model
//

import Foundation

class SigninVm {
    
    init() {
    }
    
    func signin(id: String, pw: String, completion: ResponseString = nil) {
        
        // 로그인 요청
//        let encodedPw = _utils.encodeToMD5(pw: pw)
        _cas.signin.signin(id: id, pw: pw) { (success, json) in
            var msg = ""
            if let json = json, true == success {
                _user.saveData(userId: id, userPw: pw, json: json)
                
                let deviceAuthUrl = json["resUrl"].stringValue
                guard false == deviceAuthUrl.isEmpty else {
                    completion?(false, "로그인하지 못했습니다.\n(디바이스 인증 url을 받지 못했습니다)")
                    return
                }
                
                // 디바이스 정보 전송
                _cas.signin.sendDeviceInfo(userSeq: _user.seq, url: deviceAuthUrl, userName: _user.name) { (success, json) in
                    if success {
                        _user.signIn = true
                        completion?(true, "")
                    } else {
                        let failedMsg = ApiManager.getFailedMsg(defaultMsg: "로그인하지 못했습니다.", json: json)
                        completion?(false, failedMsg)
                    }
                }
            } else {
                _utils.removeIndicator()
                msg = ApiManager.getFailedMsg(defaultMsg: "로그인하지 못했습니다.", json: json)
                completion?(success, msg)
            }
        }
    }
    
}
