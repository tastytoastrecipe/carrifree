//
//  SigninSv.swift
//  Carrifree
//
//  Created by orca on 2022/03/11.
//  Copyright Β© 2022 plattics. All rights reserved.
//
//
//  π¬ SigninSv
//  π¬ λ‘κ·ΈμΈ κ΄λ ¨ API λͺ¨μ
//

import Foundation
import Alamofire

class SigninSv: Service {
    let apiManager: ApiManager

    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    func signin(id: String, pw: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_ID                 μμ΄λ
        //      PWD                     λΉλ°λ²νΈ
        //      JOIN_TYPE               νμκ°μ μ’λ₯(SignCase)
        //      USER_TYPE               νμ μ ν(CarrifreeAppType.user)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        let param: [String: String] = [
            "USER_ID": id,
            "PWD": pw,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let url = getRequestUrl(body: "/sys/member/app/login.do")
        apiManager.request(api: .signin, url: url, parameters: param, completion: completion)
        
    }

    /// λλ°μ΄μ€ μ λ³΄ μ μ‘
    func sendDeviceInfo(userSeq: String, url: String, userName: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      MASTER_SEQ              νμ SEQ
        //      DEVICE_NM               λ¨λ§κΈ° λͺμΉ­
        //      DEVICE_VER              λ¨λ§κΈ° λ²μ 
        //      PUSH_ID                 λ¨λ§ PUSH_ID
        //      APP_VER                 λ¦¬μ‘νΈλ‘ κ°λ°λ μ± λ²μ 
        //      CD_PLATFORM             νλ«νΌ νμ (A:μλλ‘μ΄λ, I:IOS)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        if url.isEmpty {
            _log.log("Empty URL.. (send device info)")
            return
        }
        
//        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let deviceName =  UIDevice.current.name
        let osVersion = UIDevice.current.systemVersion
        let pushId = CarryPush.shared.fcmRegToken
        let appVersion = _utils.getAppVersion()
        let platform = "I"
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "MASTER_SEQ": userSeq,
            "DEVICE_NM": deviceName,
            "DEVICE_VER": osVersion,
            "PUSH_ID": pushId,
            "APP_VER": appVersion,
            "CD_PLATFORM": platform
        ]
        
        let url = getRequestUrl(body: "/sys/device/setDevice.do")
        apiManager.request(api: .deviceInfo, url: url, headers: headers, parameters: param, completion: completion)
    }
}
