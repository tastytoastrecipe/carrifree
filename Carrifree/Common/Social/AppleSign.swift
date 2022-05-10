//
//  AppleSignIng.swift
//  Carrifree
//
//  Created by orca on 2020/10/13.
//  Copyright © 2020 plattics. All rights reserved.
//

import Foundation
import CryptoKit
import AuthenticationServices

class AppleSign: SocialSign {
    
    private var currentNonce: String?
    private var viewController: UIViewController!
    
    override func signIn() {
        guard let opViewController = _utils.topViewController() else { return }
        viewController = opViewController
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    // 애플 로그인 요청에 대해 'nonce' 문자열(무작위) 생성 https://firebase.google.com/docs/auth/ios/apple?authuser=0
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

// MARK:- ASAuthorizationControllerDelegate
extension AppleSign: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            self.name = appleIDCredential.fullName?.nickname ?? ""
            if self.name.isEmpty { self.name = appleIDCredential.fullName?.givenName ?? "" }
            
            // id는 6 ~ 12자 제한이기 때문에 12자로 제한한다
            let originalId = appleIDCredential.user
            let appleIds = originalId.split(separator: ".").map { (value) -> String in
                return String(value)
            }
            
            let maxLength: Int = 24
            var finalId = ""
            if appleIds.count > 2 && appleIds[1].count > maxLength {
                let appleId = appleIds[1]
                let firstIndex = appleId.index(appleId.startIndex, offsetBy: 0)
                let lastIndex = appleId.index(appleId.startIndex, offsetBy: maxLength)
                finalId = "\(appleId[firstIndex ..< lastIndex])"
            } else {
                let firstIndex = originalId.index(originalId.startIndex, offsetBy: 0)
                let lastIndex = originalId.index(originalId.startIndex, offsetBy: maxLength)
                finalId = "\(originalId[firstIndex ..< lastIndex])"
            }
            
            self.id = finalId
            
            // 애플 로그인은 최초 로그인에서만 이름을 받을 수 있기 때문에 최초 로그인시 이름을 캐싱한다
            if self.name.isEmpty {
                var appleName = UserDefaults.standard.string(forKey: MyIdentifiers.keyAppleUserName.rawValue) ?? ""
                if appleName.isEmpty { appleName = self.id }
                self.name = appleName
            }
            
            UserDefaults.standard.setValue(self.name, forKey: MyIdentifiers.keyAppleUserName.rawValue)
            
            MyLog.log("aplle login success! ---> id: \(self.id)")
            MyLog.log("aplle login success! ---> name: \(self.name)")
            CarrySocial.shared.setSigned(signed: true, id: self.id, name: self.name, type: "005")
            CarryEvents.shared.callSocialSignInSuccess(name: self.name, id: self.id)
            
            
//            guard let nonce = currentNonce else {
//                fatalError("\n Invalid state: A login callback was received, but no login request was sent.")
//            }
//            guard let appleIDToken = appleIDCredential.identityToken else {
//                MyLog.log("\n Unable to fetch identity token")
//                return
//            }
//            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//                MyLog.log("\n Unable to serialize token string from data: \(appleIDToken.debugDescription)")
//                return
//            }
            
            
            
            
            
//            indicator.startAnimating()
//            FirebaseRequest.shared.appleSignIn(idToken: idTokenString, nonce: nonce)
            
//            var userEmail = appleIDCredential.email ?? ""
//            if userEmail.isEmpty { userEmail = Auth.auth().currentUser?.email ?? "" }
//            makeSignInAlert(email: userEmail)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("\n Apple Sign-In failed..\n\n - \(error)\n\n")
    }
    
    
}

// MARK:- ASAuthorizationControllerPresentationContextProviding
extension AppleSign: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return view.window!
        
        return viewController.view.window!
    }
    
    
}


