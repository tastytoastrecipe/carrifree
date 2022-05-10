//
//  MyPageSv.swift
//  Carrifree
//
//  Created by orca on 2022/02/21.
//  Copyright © 2022 plattics. All rights reserved.
//

import Foundation

class MyPageSv: Service {
    
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: - 내 정보 조회
    func getMyInfo(completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ                사용자 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      USER_ATTACH_INFO        <String>        프로필 사진 정보
        //      USER_EMAIL              <String>        이메일
        //      USER_ID                 <String>        아이디
        //      USER_NAME               <String>        이름
        //      USER_HP_NO              <String>        핸드폰번호
        //      ATTACH_GRP_NO           <Number>        첨부파일 시퀀스
        //      resCd                   <String>        결과 코드
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: [String: String] = [
            "USER_SEQ": _user.seq
        ]
        
        let url = getRequestUrl(body: "/sys/member/app/getMyUserInfo.do")
        apiManager.request(api: .getMyInfo, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 폰번호 변경
    func setPhone(phone: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ                사용자 시퀀스
        //      USER_HP_NO              폰번호
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: [String: String] = [
            "USER_SEQ": _user.seq,
            "USER_HP_NO": phone
        ]
        
        let url = getRequestUrl(body: "/sys/member/app/updateUserHpNo.do")
        apiManager.request(api: .setPhone, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 프로필 사진 등록
    func registerProfilePicture(attachGrpSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ                사용자 시퀀스
        //      ATTACH_TYPE             저장 구분 (고정값: 016 - AttachType)
        //      ATTACH_GRP_SEQ          파일 시퀀스
        //      fileList                첨부 파일
        //      module                  모듈 번호 (고정값: 1)
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: [String: String] = [
            "USER_SEQ": _user.seq,
            "ATTACH_GRP_SEQ": attachGrpSeq
//            "ATTACH_TYPE": attachType.rawValue
        ]
        
        let url = getRequestUrl(body: "/sys/member/app/setProfileImage.do")
        apiManager.request(api: .registerProfilePicture, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 내 정보 저장
    func setMyinfo(email: String, attachGrpSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ                사용자 시퀀스
        //      ATTACH_GRP_SEQ          파일 시퀀스
        //      USER_EMAIL              이메일
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: [String: String] = [
            "USER_SEQ": _user.seq,
            "ATTACH_GRP_SEQ": attachGrpSeq,
            "USER_EMAIL": email
        ]
        
        let url = getRequestUrl(body: "/sys/member/app/setUserImgAndEmail.do")
        apiManager.request(api: .setMyInfo, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 로그아웃
    func signout(completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_ID                아이디
        //      USER_TOKEN             토큰
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, "요청 헤더를 생성하지 못했습니다."); return }
        
        let param: [String: String] = [
            "USER_ID": _user.id,
            "USER_TOKEN": _user.token
        ]
        
        let url = getRequestUrl(body: "/sys/member/app/logout.do")
        apiManager.request(api: .signout, url: url, headers: headers, parameters: param, completion: completion)
    }
}
