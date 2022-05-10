//
//  Service.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/31.
//
//
//  💬 ## Service ##
//  💬 API 요청 protocol
//

import Foundation
import Alamofire
import SwiftyJSON

typealias RequestCallback = ((Bool) -> Void)?
typealias ResponseString = ((Bool, String) -> Void)?
typealias ResponseJson = ((Bool, JSON?) -> Void)?
typealias ResponsePresignedUrl = ((_ success: Bool, _ presignedUrl: String, _ attachGrpSeq: String, _ attachSeq: String, _ msg: String) -> Void)?

protocol Service {
    
}

extension Service {
    /// 가장 자주 사용되는 헤더 반환
    func getHeader() -> HTTPHeaders? {
        if _user.token.isEmpty || _user.id.isEmpty {
            _log.logWithArrow("API 헤더 생성 실패", "token 혹은 id가 빈값입니다..")
            return nil
        }
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": _user.token,
            "USER_ID": _user.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        return headers
    }
    
    /// 서버 주소를 적용한 url 반환
    func getRequestUrl(body: String) -> String {
        var server: String = ""
        if releaseMode {
            server = _identifiers[.liveServer]
        } else {
            server = _identifiers[.devServer]
        }
        
        return "\(server)\(body)"
    }
}
