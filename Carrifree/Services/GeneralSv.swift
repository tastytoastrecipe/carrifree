//
//  GeneralSv.swift
//  CarrifreeStorage
//
//  Created by orca on 2022/03/08.
//
//
//  💬 ## GeneralSv ##
//  💬 여러 화면에서 쓰이는 API 모음
//

import Foundation
import SwiftyJSON
import Alamofire

class GeneralSv: Service {
    
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: - 앱 업데이트 정보 조회
    /// 앱 업데이트 정보 조회
    func getUpdateInfo(platform: String = CarrifreeAppType.appUser.rawValue, handler: @escaping ((Bool) -> Void)) {
        //-------------------------- Request -------------------------- //
        //
        //         PLATFORM_TYPE            단말기 타입 (I: iOS, A: Android)
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
        //------------------------------------------------------------- //
        
        let currentVersion = _utils.getAppVersionInt()
        
        _cas.load.getUpdateInfo(platform: platform) { (success, json) in
            guard let json = json else { return }
            
            let requestTitle = "[업데이트 정보 요청]"
            let msg = json["resMsg"].stringValue
            
            // 요청 실패
            guard json["resCd"].stringValue == "0000" else {
                _log.logWithArrow("\(requestTitle) failed", msg)
                var message = msg
                if message.isEmpty { message = "\(_strings[.alertUpdateInfoLoadFailed])\n\(_strings[.plzTryAgain])" }
                let alert = _utils.createSimpleAlert(title: msg, message: "", buttonTitle: _strings[.ok])
                _utils.topViewController()?.present(alert, animated: true)
                return
            }
            
            // 업데이트 정보
            let lastVersion = _utils.getAppVersionInt(version: json["APP_VERSION"].stringValue)
            let _ = json["DATE_C"].stringValue
            
            // 서버에서 받은 앱버전이 현재 앱버전 보다 크면 스토어로 이동시킴(필수 업데이트)
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
    
    // MARK: - 매장정보 관련 코드 조회
    /// 매장정보 관련 코드 조회
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
