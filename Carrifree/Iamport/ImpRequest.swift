//
//  ImpRequest.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/01/20.
//

import Foundation
import Alamofire
import SwiftyJSON

class ImpRequest {
    
    static let shared = ImpRequest()
    
    var phone: String = ""
    
    func printRequestInfos(requestTitle: String, response: AFDataResponse<Any>) {
        _log.logWithArrow("\(requestTitle) response", response.debugDescription)

        if let data = response.request?.httpBody {
            let body = String(data: data, encoding: .utf8)
            _log.logWithArrow("\(requestTitle) request body", body ?? "")
        }
    }
    
    func requestToken(impKey: String, impSecret: String, completion: ResponseString = nil) {          // [impKey] - REST API key, [impSecret] - REST API secret
        
        let param: Parameters = [
            "imp_key": _identifiers[.iamportKey],
            "imp_secret": _identifiers[.iamportSecret]
        ]
        
        let url = "https://api.iamport.kr/users/getToken"
        AF.request(url, method: .post, parameters: param) { $0.timeoutInterval = 10 }.validate().responseJSON { (response) in
            let requestTitle = "[아임포트 토큰 요청]"
            self.printRequestInfos(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                if let token = json["response"]["access_token"].string {
                    completion?(true, token)
                } else {
                    completion?(false, "access_token is empty")
                }
                
            case .failure(let error):
                _log.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    func requestUserInfo(impUid: String, token: String, completion: ResponseString = nil) {          // [impUid] - import uid
        
        let headers: HTTPHeaders = [
            "Authorization": token
        ]
        
        let url = "https://api.iamport.kr/certifications/\(impUid)"
        AF.request(url, method: .get, headers: headers) { $0.timeoutInterval = 10 }.validate().responseJSON { (response) in
            let requestTitle = "[아임포트 사용자 정보 요청]"
            self.printRequestInfos(requestTitle: requestTitle, response: response)
            
//            let json = JSON(response)
//            let msg = json["message"].stringValue
            
            switch response.result { 
            case .success(let value):
                
                let json = JSON(value)
                let phone = json["response"]["phone"].stringValue
                _log.logWithArrow("phone number", phone)
                self.phone = phone
//                _user.contact = phone
                UserDefaults.standard.setValue(phone, forKey: _identifiers[.keyUserContact])
//                CarryRequest.shared.requestSetPhoneNumber(phone: CarryUser.phone)
                completion?(true, "")
                
            case .failure(let error):
                _log.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
}
