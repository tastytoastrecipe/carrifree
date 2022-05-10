//
//  LoadSv.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/12/21.
//

import Foundation

class LoadSv: Service {
    
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: - 앱 업데이트 정보 요청
    func getUpdateInfo(platform: String, completion: ResponseJson = nil) {
        
        //-------------------------- Request -------------------------- //
        //
        //         PLATFORM_TYPE            플랫폼 타입    I001: iOS 사용자앱    / A001: Android 사용자앱
        //                                              I002: iOS 운송사업자앱 / A002: Android 운송사업자앱
        //                                              I003: iOS 보관사업자앱 / A003: Android 보관사업자앱
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //          APP_VERSION             마지막 강제 업데이트 버전
        //          DATE_C                  마지막 강제 업데이트 날짜
        //
        //------------------------------------------------------------- /

        let param: [String: String] = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "PLATFORM_TYPE": platform
        ]

        let url = getRequestUrl(body: "/sys/common/app/versionMng.do")
        apiManager.request(api: .getUpdateInfo, url: url, parameters: param, completion: completion)
    }
    
    // test!
    /// 테스트 계정으로 로그인함
    func testLogin(completion: ResponseJson = nil) {
        let param: [String: String] = [
            "USER_ID": "user01",
            "JOIN_TYPE": SignCase.normal.type,
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "PWD": "536e6fb88aa6a4b66029d6d87959d3a7"
        ]

        let url = getRequestUrl(body: "/sys/member/app/login.do")
        apiManager.request(api: .signin, url: url, parameters: param, completion: completion)
        
    }
}
