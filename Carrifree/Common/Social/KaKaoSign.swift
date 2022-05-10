//
//  KaKaoSignIn.swift
//  Carrifree
//
//  Created by orca on 2020/10/21.
//  Copyright © 2020 plattics. All rights reserved.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser

class KaKaoSign: SocialSign {
    
    private var token = ""
    var accessToken: String {
        return token
    }
    
    override func signIn() {
        // 카카오톡 설치 여부 확인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            // 카카오톡 로그인. api 호출 결과를 클로저로 전달.
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    // 예외 처리 (로그인 취소 등)
                    MyLog.log("kakao sign-in failed.. (\(error))")
                }
                else {
                    
                    // do something
                    _ = oauthToken
                    // 어세스토큰
                    guard let tempToken = oauthToken?.accessToken else {
                        MyLog.log("kakao sign-in ---> failed.. (empty token)")
                        return
                    }
                    
                    self.token = tempToken
                    MyLog.log("kakao sign-in ---> success!(token: \(self.token))")
                    
                    self.getUserInfo()
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    self.loginSuccess(token: oauthToken)
                }
            }
        }
    }
    
    func loginSuccess(token: OAuthToken?) {
        guard let tempToken = token?.accessToken else {
            MyLog.log("kakao sign-in ---> failed.. (empty token)")
            return
        }
        
        self.token = tempToken
        MyLog.log("kakao sign-in ---> success!(token: \(self.token))")
        
        self.getUserInfo()
    }
    
    func getUserInfo() {
        //사용자 관리 api 호출
        UserApi.shared.me() { (user, error) in
            if let error = error {
                MyLog.log("get kakao user info ---> failed.. (\(error))")
            }
            else {
                let nickname = user?.kakaoAccount?.profile?.nickname
                let email = user?.kakaoAccount?.email
//                let id = user?.kakaoAccount?.ci
                let userid = user?.id
                
                self.name = nickname ?? ""
                self.id = "\(userid ?? 0)"
                CarrySocial.shared.setSigned(signed: true, id: self.id, name: self.name, type: "002")
                
                MyLog.log("get kakao user info success! ---> nickName: \(nickname ?? "")")
                MyLog.log("get kakao user info success! ---> email: \(email ?? "")")
                MyLog.log("get kakao user info success! ---> id: \(userid ?? 0)")
                CarryEvents.shared.callSocialSignInSuccess(name: nickname ?? "", id: "\(userid ?? 0)")
            }
        }
    }
    
    override func signOut() {
        UserApi.shared.logout {(error) in
            if let error = error {
                MyLog.log("kakao logout ---> failed.. (\(error))")
            }
            else {
                MyLog.log("kakao logout ---> success!")
                CarryEvents.shared.callSocialSignOutSuccess()
            }
        }
    }
}
