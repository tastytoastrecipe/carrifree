//
//  CarrySignIn.swift
//  Carrifree
//
//  Created by orca on 2020/10/13.
//  Copyright © 2020 plattics. All rights reserved.
//

import Foundation
import UIKit



class CarrySocial {
    static let shared = CarrySocial()
    
    private let apple: AppleSign
    private let kakao: KaKaoSign
    private let facebook: FacebookSign
    private let naver: NaverSign
    
    var name: String = ""
    var id: String = ""
    var type: String = "001"        // 기본값 = id/pw 가입
    var signed: Bool = false
    
    private init() {
        apple = AppleSign()
        kakao = KaKaoSign()
        facebook = FacebookSign()
        naver = NaverSign()
    }
    
    func signInApple() {
        apple.signIn()
    }
    
    func signInKakao() {
        kakao.signIn()
    }
    
    func signInFacebook() {
        facebook.signIn()
    }
    
    func signInNaver() {
        naver.signIn()
    }
    
    func signOut() {
        removeData()
        CarryEvents.shared.callSocialSignOutSuccess()
    }
    
    func isSocialType(type: String) -> Bool {
        if type.isEmpty { return false }
        return type != "001"
    }
    
    func getCurrentTypeString() -> String {
        var platform = ""
        if type == "002" {              // 카카오
            platform = MyStrings.platformKakao.rawValue
        } else if type == "003" {       // 페이스북
            platform = MyStrings.platformFacebook.rawValue
        } else if type == "004" {       // 네이버
            platform = MyStrings.platformNaver.rawValue
        } else if type == "005" {       // 애플
            platform = MyStrings.platformApple.rawValue
        }
        
        return platform
    }
    
    func getTypeString(type: String) -> String {
        var platform = ""
        if type == "002" {              // 카카오
            platform = MyStrings.platformKakao.rawValue
        } else if type == "003" {       // 페이스북
            platform = MyStrings.platformFacebook.rawValue
        } else if type == "004" {       // 네이버
            platform = MyStrings.platformNaver.rawValue
        } else if type == "005" {       // 애플
            platform = MyStrings.platformApple.rawValue
        }
        
        return platform
    }
    
    func setSigned(signed: Bool, id: String, name: String, type: String) {
        self.signed = signed
        self.id = id
        self.name = name
        self.type = type
        
//        let appleUserName = UserDefaults.standard.string(forKey: MyIdentifiers.keyAppleUserName.rawValue) ?? "user"
//        name = appleUserName
    }
    
    func removeData() {
        setSigned(signed: false, id: "", name: "", type: "001")
    }
}
