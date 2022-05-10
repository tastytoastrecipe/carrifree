//
//  SigninSv.swift
//  Carrifree
//
//  Created by orca on 2022/03/11.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 SigninSv
//  💬 로그인 관련 API 모음
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
        //      USER_ID                 아이디
        //      PWD                     비밀번호
        //      JOIN_TYPE               회원가입 종류(SignCase)
        //      USER_TYPE               회원 유형(CarrifreeAppType.user)
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

    /// 디바이스 정보 전송
    func sendDeviceInfo(userSeq: String, url: String, userName: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      MASTER_SEQ              회원 SEQ
        //      DEVICE_NM               단말기 명칭
        //      DEVICE_VER              단말기 버전
        //      PUSH_ID                 단말 PUSH_ID
        //      APP_VER                 리액트로 개발된 앱 버전
        //      CD_PLATFORM             플랫폼 타입 (A:안드로이드, I:IOS)
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
