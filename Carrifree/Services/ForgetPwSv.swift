//
//  ForgetPwSv.swift
//  Carrifree
//
//  Created by orca on 2022/03/14.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 ForgetPwSv
//  💬 비밀번호 재설정 화면 api 모음
//

import Foundation
import SwiftyJSON
import Alamofire

class ForgetPwSv: Service {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    /// PW 재설정
    func resetPw(id: String, phone: String, pw: String, completion: ResponseJson = nil) {
        let param: [String: String] = [
            "USER_ID": id,
            "USER_HP_NO": phone,
            "PWD": pw
        ]
        
        let url = getRequestUrl(body: "/sys/member/app/changePwd.do")
        apiManager.request(api: .resetPw, url: url, parameters: param, completion: completion)
    }
}
