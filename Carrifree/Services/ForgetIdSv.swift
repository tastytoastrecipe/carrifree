//
//  ForgetIdSv.swift
//  Carrifree
//
//  Created by orca on 2022/03/13.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 ForgetIdSv
//  💬 아이디 찾기 화면 api 모음
//

import Foundation
import SwiftyJSON
import Alamofire

class ForgetIdSv: Service {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    /// ID 찾기
    func findId(phone: String, completion: ResponseJson = nil) {
        let param: [String: String] = [
            "USER_HP_NO": phone,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let url = getRequestUrl(body: "/sys/memberV3/app/findId.do")
        apiManager.request(api: .findId, url: url, parameters: param, completion: completion)
    }
}
