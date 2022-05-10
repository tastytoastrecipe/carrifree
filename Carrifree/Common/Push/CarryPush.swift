//
//  CarryPush.swift
//  Carrifree
//
//  Created by plattics-kwon on 2020/11/12.
//  Copyright © 2020 plattics. All rights reserved.
//


import Foundation
import Firebase
import FirebaseMessaging
import SwiftyJSON

@objc protocol CarryPushDelegate {
    @objc optional func getTokenComplete()
}

class CarryPush: NSObject {
    
    enum PushRoute: String {
        case driverHistory = "driverUserOrder"
        case storageHistory = "saveUserOrder"
        case none = ""
        
    }
    
    static let shared = CarryPush()
    
    var delegate: CarryPushDelegate?
    var fcmRegToken = ""
    
    lazy var route: PushRoute = .none
//    lazy var pushData = PushDatas()
    
    private override init() {}
    
    func configure(application: UIApplication) {
        registerRemoteNoti(application: application)
//        setRegistrationToken()
    }
    
    // 앱 실행시 외부(푸시, 카톡등)에서 받은 데이터를 저장한다
    func receiveNotification(route: String, param: [String]) {
        self.route = PushRoute(rawValue: route) ?? .none
        if self.route == .none { return }
        
//        pushData.createPushData(route: self.route, parameters: param)
    }
    
    func moveScene(storyboardId: String) {
        if storyboardId.isEmpty { return }
        _utils.moveScene(storyboardId: storyboardId, push: true)
    }
    
    // 외부(푸시, 카톡등)에서 받은 데이터가 있으면 해당 데이터가 표시되는 화면으로 이동한다
    func checkPush() {
        /*
        switch route {
        case .driverHistory:
            CarrySearch.service = .delivery
            _utils.moveScene(storyboardId: MyIdentifiers.sceneHistory.rawValue, push: false)
        case .storageHistory:
            CarrySearch.service = .store
            _utils.moveScene(storyboardId: MyIdentifiers.sceneHistory.rawValue, push: false)
        default: break
        }
        */
    }
}



// MARK:- ---------------------- FCM ----------------------
extension CarryPush {
    private func registerRemoteNoti(application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    func setRegistrationToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                MyLog.log("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                MyLog.log("FCM registration token: \(token)")
                self.fcmRegToken = token
            }
            self.delegate?.getTokenComplete?()
        }
    }
}

extension CarryPush: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        MyLog.logWithArrow("Remote notification response", response.debugDescription)
        
        let notification = response.notification
        let userInfo = notification.request.content.userInfo
        
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            print ("push message closed")
        }
        else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
//            guard let info = userInfo["aps"] as? Dictionary<String, Any> else { return}
            
            MyLog.logWithArrow("Notification Info(aps)", userInfo.debugDescription)
            
            let data = JSON(userInfo)
            
            let dealSeq = data["dealSeq"].stringValue
            let route = data["route"].stringValue
            
            MyLog.logWithArrow("push data", "dealSeq(\(dealSeq))")
            MyLog.logWithArrow("push data", "route(\(route))")
        }
        completionHandler()
    }
}

extension CarryPush: MessagingDelegate {
    
}

