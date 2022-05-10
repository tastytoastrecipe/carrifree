//
//  SignupSv.swift
//  Carrifree
//
//  Created by orca on 2022/02/28.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 SignupSv
//  💬 회원가입 관련 API 모음
//

import Foundation
import SwiftyJSON
import Alamofire

class SignupSv: Service {

    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: - ID 유효성 확인
    func isAvailableId(id: String, completion: ResponseJson) {
        
        let param: Parameters = [
            "USER_ID": id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let url = getRequestUrl(body: "/sys/member/app/duplicateMember.do")
        apiManager.request(api: .idDuplicationCheck, url: url, parameters: param, completion: completion)
    }
    
    // MARK: - 약관 조회
    func requestTerms(termType: String = "", completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      TERMS_TYPE              약관 종류, null:전체약관조회 (TermCase.type)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (termsList)
        //      BOARD_SEQ               약관 시퀀스
        //      BOARD_TITLE             약관 제목
        //      BOARD_MEMO              약관 내용
        //      DIVISION_YN             필수/선택 사항
        //
        //------------------------------------------------------------- //
        
        let url = getRequestUrl(body: "/sys/contents/appAuth/getAllTerms.do")
        
        if termType.isEmpty {
            apiManager.requestSimpleGetJson(api: .getTerms, url: url, completion: completion)
        } else {
            let param: Parameters = ["TERMS_TYPE": termType]
            apiManager.request(api: .getTerms, url: url, parameters: param, completion: completion)
        }
    }
    
    // MARK: - 휴대폰 인증 번호 요청
    func requestAuth(phone: String, signup: Bool, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_HP_NO              핸드폰번호
        //      JOIN_YN                 회원가입 여부
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        var param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_HP_NO": phone
        ]
        
        if signup {
            param["JOIN_YN"] = "Y"
        }
        
        let url = getRequestUrl(body: "/sys/memberV3/app/hpAuthNSendSms.do")
        apiManager.request(api: .phoneAuth, url: url, parameters: param, completion: completion)
    }
    
    // MARK: - 휴대폰 인증
    func doAuth(phone: String, authNo: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_HP_NO              핸드폰번호
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        let param: Parameters = [
            "USER_HP_NO": phone,
            "AUTH_CHECK_NO": authNo
        ]
        
        let url = getRequestUrl(body: "/sys/memberV3/app/hpConfirmCheck.do")
        apiManager.request(api: .phoneAuth, url: url, parameters: param, completion: completion)
    }
    
    
    // MARK: - 회원가입
    func signup(id: String, pw: String, phone: String, name: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_ID                 회원 ID
        //      USER_PWD                패스워드
        //      USER_NAME               사용자 이름
        //      USER_HP_NO              핸드폰번호
        //      USER_TYPE               회원 유형(CarrifreeAppType.user)
        //      JOIN_TYPE               디바이스 종류 (001: iOS, 002: Android)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        let param: Parameters = [
            "USER_ID": id,
            "USER_PWD": pw,
            "USER_NAME": name,
            "USER_HP_NO": phone,
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "JOIN_TYPE": "001"
        ]
        
        let url = getRequestUrl(body: "/sys/member/app/generalJoinMember.do").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if url.isEmpty { completion?(false, "회원가입 요청 url을 생성하지 못했습니다. 다시 시도해주시기 바랍니다."); return }
        apiManager.request(api: .signUp, url: url, parameters: param, completion: completion)
    }
}

