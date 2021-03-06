//
//  GeneralSv.swift
//  CarrifreeStorage
//
//  Created by orca on 2022/03/08.
//
//
//  π¬ ## GeneralSv ##
//  π¬ μ¬λ¬ νλ©΄μμ μ°μ΄λ API λͺ¨μ
//

import Foundation
import SwiftyJSON
import Alamofire

class GeneralSv: Service {
    
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: - μ± μλ°μ΄νΈ μ λ³΄ μ‘°ν
    /// μ± μλ°μ΄νΈ μ λ³΄ μ‘°ν
    func getUpdateInfo(platform: String = CarrifreeAppType.appUser.rawValue, handler: @escaping ((Bool) -> Void)) {
        //-------------------------- Request -------------------------- //
        //
        //         PLATFORM_TYPE            λ¨λ§κΈ° νμ (I: iOS, A: Android)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //          APP_VERSION             λ§μ§λ§ κ°μ  μλ°μ΄νΈ λ²μ 
        //          DATE_C                  λ§μ§λ§ κ°μ  μλ°μ΄νΈ λ μ§
        //
        //------------------------------------------------------------- //
        
        let currentVersion = _utils.getAppVersionInt()
        
        _cas.load.getUpdateInfo(platform: platform) { (success, json) in
            guard let json = json else { return }
            
            let requestTitle = "[μλ°μ΄νΈ μ λ³΄ μμ²­]"
            let msg = json["resMsg"].stringValue
            
            // μμ²­ μ€ν¨
            guard json["resCd"].stringValue == "0000" else {
                _log.logWithArrow("\(requestTitle) failed", msg)
                var message = msg
                if message.isEmpty { message = "\(_strings[.alertUpdateInfoLoadFailed])\n\(_strings[.plzTryAgain])" }
                let alert = _utils.createSimpleAlert(title: msg, message: "", buttonTitle: _strings[.ok])
                _utils.topViewController()?.present(alert, animated: true)
                return
            }
            
            // μλ°μ΄νΈ μ λ³΄
            let lastVersion = _utils.getAppVersionInt(version: json["APP_VERSION"].stringValue)
            let _ = json["DATE_C"].stringValue
            
            // μλ²μμ λ°μ μ±λ²μ μ΄ νμ¬ μ±λ²μ  λ³΄λ€ ν¬λ©΄ μ€ν μ΄λ‘ μ΄λμν΄(νμ μλ°μ΄νΈ)
            let needUpdate = lastVersion > currentVersion
            handler(needUpdate)
        }
    }
    
    // test!
    func testLogin(completion: ResponseString = nil) {
        _cas.load.testLogin() { (success, json) in
            var msg: String = ""
            if let json = json, true == success {
                _user.token = json["sha_token"].stringValue
                _user.id = json["memberInfo"]["user_ID"].stringValue
                _user.seq = json["memberInfo"]["user_SEQ"].stringValue
                _user.masterSeq = json["memberInfo"]["master_SEQ"].stringValue
            } else {
                msg = ApiManager.getFailedMsg(defaultMsg: "", json: json)
            }
            
            completion?(success, msg)
        }
    }
    
    // MARK: - λ§€μ₯μ λ³΄ κ΄λ ¨ μ½λ μ‘°ν
    /// λ§€μ₯μ λ³΄ κ΄λ ¨ μ½λ μ‘°ν
    func getStorageCodes(all: Bool, userSeq: String, code: StorageCodeGroup, completion: (([StorageCode]) -> Void)? = nil) {
        guard let headers = getHeader() else { completion?([]); return }
        
        var api: ApiType = .getCategories
        if code == .bank       { api = .getBanks }
        else if code == .weeks { api = .getWeeks }
        else if code == .merit { api = .getMerits }
        
        var param: [String: String] = [
            "USER_SEQ": userSeq
        ]
        
        var url = ""
        if all {
            url = getRequestUrl(body: "/sys/common/app/getComCdList.do")
            param["comGrpCd"] = code.rawValue
        } else {
            url = getRequestUrl(body: "/sys/common/app/getOptionList.do")
            param["ITEM_GRP_CD"] = code.rawValue
        }
        
        apiManager.request(api: api, url: url, headers: headers, parameters: param) { (success, json) in
            guard let json = json, true == success else { completion?([]); return }
            
            var codes: [StorageCode] = []
            
            if all {
                let arr = json["comCdList"].arrayValue
                for val in arr {
                    let grp = val["COM_GRP_CD"].stringValue
                    let code = val["COM_CD"].stringValue
                    let name = val["COM_NM"].stringValue
                    let storageCode = StorageCode(grp: grp, code: code, name: name)
                    codes.append(storageCode)
                }
            } else {
                let arr = json["optionList"].arrayValue
                for val in arr {
                    let grp = val["ITEM_GRP_CD"].stringValue
                    let code = val["ITEM_COM_CD"].stringValue
                    let storageCode = StorageCode(grp: grp, code: code, name: "")
                    codes.append(storageCode)
                }
            }
            
                
            completion?(codes)
        }
    }
}
