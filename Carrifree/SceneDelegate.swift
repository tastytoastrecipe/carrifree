//
//  SceneDelegate.swift
//  Carrifree
//
//  Created by orca on 2020/10/05.
//  Copyright © 2020 plattics. All rights reserved.
//

import UIKit
import KakaoSDKAuth
import FBSDKCoreKit
import NaverThirdPartyLogin
import SwiftyIamport


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
//        if let url = connectionOptions.urlContexts.first?.url {
//            _ = checkCarrifreeDriverParameter(url: url)
//        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        guard let url = URLContexts.first?.url else { return }
        
        MyLog.logWithArrow("AppDelegate.application url scheme ", url.scheme ?? "")
        MyLog.logWithArrow("AppDelegate.application url query", url.query ?? "")
        
        
        /*
        if true == checkCarrifreeDriverParameter(url: url) { return }
        
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            // kakao sign-in setting
            _ = AuthController.handleOpenUrl(url: url)
        }
        else {
            // facebook sign-in settings
            let isFacebookLiginUrl = ApplicationDelegate.shared.application(UIApplication.shared, open: url, sourceApplication: nil, annotation: [UIApplication.OpenURLOptionsKey.annotation])
            
            if isFacebookLiginUrl == false {
                NaverThirdPartyLoginConnection.getSharedInstance()?.receiveAccessToken(url)
            }
        }
        */
    }
    
    /*
    func checkCarrifreeDriverParameter(url: URL) -> Bool {
        let host = url.host ?? ""
        let scheme = url.scheme ?? ""
        var pathComponent = url.pathComponents
        if pathComponent.count > 0 { _ = pathComponent.removeFirst() }
        let appScheme = MyIdentifiers.scheme.rawValue
        let appSchemeLowercase = appScheme.lowercased()
        if (scheme == appScheme) || (scheme == appSchemeLowercase) {
            CarryPush.shared.receiveNotification(route: host, param: pathComponent)
            CarryPush.shared.checkPush()
            return true
        }
        
        return false
    }
     */
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        CarryEvents.shared.callApplicationWillEnterForeground()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

