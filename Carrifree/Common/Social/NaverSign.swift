//
//  NaverSignIn.swift
//  Carrifree
//
//  Created by orca on 2020/10/22.
//  Copyright © 2020 plattics. All rights reserved.
//

import Foundation
import NaverThirdPartyLogin
import Alamofire

class NaverSign: SocialSign {
    
    let naverLoginInstance: NaverThirdPartyLoginConnection
    
    override init() {
        naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
        super.init()
        naverLoginInstance.delegate = self
//        kServiceAppUrlScheme
    }
    
    override func signIn() {
        naverLoginInstance.requestThirdPartyLogin()
    }
    
    override func signOut() {
        naverLoginInstance.requestDeleteToken()
    }
    
    private func getNaverInfo() {
        if naverLoginInstance.isValidAccessTokenExpireTimeNow() == false { return }
        
        guard let tokenType = naverLoginInstance.tokenType else { return }
        guard let accessToken = naverLoginInstance.accessToken else { return }
        let urlStr = "https://openapi.naver.com/v1/nid/me"
        let url = URL(string: urlStr)!
        
        let authorization = "\(tokenType) \(accessToken)"
        let req = AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": authorization])
        
        req.responseJSON { response in
            guard let result = response.value as? [String: Any] else { return }
            guard let object = result["response"] as? [String: Any] else { return }
            let name = (object["name"] as? String) ?? ""
//            let email = (object["email"] as? String) ?? ""
            let id = (object["id"] as? String) ?? ""
            
            self.name = name
            self.id = id
            CarrySocial.shared.setSigned(signed: true, id: self.id, name: self.name, type: "004")
            
            MyLog.log("naver sign-in success! ---> name: \(name)")
//            MyLog.log("naver sign-in success! ---> email: \(email)")
            MyLog.log("naver sign-in success! ---> id: \(id)")
            MyLog.log("naver sign-in success! ---> token: \(self.naverLoginInstance.accessToken.description)")
            
            CarryEvents.shared.callSocialSignInSuccess(name: name, id: id)
        }
    }
}

extension NaverSign: NaverThirdPartyLoginConnectionDelegate {
    
    // naver sign-in success!
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        getNaverInfo()
    }
    
    // token 갱신
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        getNaverInfo()
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        MyLog.log("naver sign-out success!")
        CarryEvents.shared.callSocialSignOutSuccess()
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        MyLog.log("naver sign-in failed.. ---> error: \(error.debugDescription)")
        
    }
    
}
