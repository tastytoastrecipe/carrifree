//
//  FacebookSignIn.swift
//  Carrifree
//
//  Created by orca on 2020/10/21.
//  Copyright © 2020 plattics. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

class FacebookSign: SocialSign {
    
    var loginManager: LoginManager? = nil
    override func signIn() {

//        let loginButton = FBLoginButton()
//        loginButton.center = view.center
//        view.addSubview(loginButton)
        
        loginManager = LoginManager()
        loginManager?.logIn(permissions: [Permission.publicProfile], viewController: nil) { (result) in
            
            switch result {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("user cancelled login")
            case .success(granted: _, declined: _, token: _): // 로그인 성공
                guard let token = AccessToken.current, !token.isExpired else { return }
                
                // token.userID와 profile.userID가 동일함!!
                MyLog.log("facebook sign-in success! (id: \(token.userID))")
                MyLog.log("facebook sign-in success! (token: \(token.tokenString))")
                
                //  프로필 가져오기
                Profile.loadCurrentProfile(completion: {(profile, error) in
                    
                    self.name = profile?.name ?? ""
                    self.id = token.userID
                    CarrySocial.shared.setSigned(signed: true, id: self.id, name: self.name, type: "003")
                    
                    MyLog.log("facebook sign-in success! (name: \(profile?.name ?? ""))")
                    MyLog.log("facebook sign-in success! (userID: \(profile?.userID ?? ""))")
                    
                    CarryEvents.shared.callSocialSignInSuccess(name: self.name, id: self.id)
                    
                })
            }
        }
    }
    
    override func signOut() {
        loginManager?.logOut()
        
        CarryEvents.shared.callSocialSignOutSuccess()
    }
}
