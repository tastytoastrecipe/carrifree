//
//  Service.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/31.
//
//
//  π¬ ## Service ##
//  π¬ API μμ²­ protocol
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
    /// κ°μ₯ μμ£Ό μ¬μ©λλ ν€λ λ°ν
    func getHeader() -> HTTPHeaders? {
        if _user.token.isEmpty || _user.id.isEmpty {
            _log.logWithArrow("API ν€λ μμ± μ€ν¨", "token νΉμ idκ° λΉκ°μλλ€..")
            return nil
        }
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": _user.token,
            "USER_ID": _user.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        return headers
    }
    
    /// μλ² μ£Όμλ₯Ό μ μ©ν url λ°ν
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
