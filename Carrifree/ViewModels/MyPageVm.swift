//
//  MyPageVm.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/24.
//
//
//  💬 StorageDetailVmDelegate
//  보관소 상세 화면 View Model
//

import Foundation

class MyPageVm: UploadVm {
    var profile: String = ""
    var name: String = ""
    var id: String = ""
    var contact: String = ""
    var email: String = ""
    var giftBadge: Int = 0
    var reviewsBadge: Int = 0
    
    var attachGrpSeq: String = _user.attachGrpSeq
    var attachSeq: String = ""
    var presignedUrl: String = ""
    
    init() {
//        setDummyDatas()
    }
    
    func setDummyDatas() {
        profile = "https://d2u3dcdbebyaiu.cloudfront.net/uploads/atch_img/602/e6aabb8f6f4e62aa402753b4dab8fd73_res.jpeg"
        name = "권회정 님"
        id = "M2000000001"
        contact = "+82 010-4818-9993"
        email = "platticskwon@gmail.com"
        giftBadge = 5
        reviewsBadge = 1
    }
    
    /// 내 정보 조회
    func getMyInfo(completion: ResponseString = nil) {
        _cas.mypage.getMyInfo() { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "내 정보를 불러오지 못했습니다.", json: json))
                return
            }
            
            //      USER_ATTACH_INFO        <String>        프로필 사진 정보
            //      USER_EMAIL              <String>        이메일
            //      USER_ID                 <String>        아이디
            //      USER_NAME               <String>        이름
            //      USER_HP_NO              <String>        핸드폰번호
            //      ATTACH_GRP_NO           <Number>        첨부파일 시퀀스
            
            self.profile = json["USER_ATTACH_INFO"].stringValue
            self.email = json["USER_EMAIL"].stringValue
            self.id = json["USER_ID"].stringValue
            self.name = json["USER_NAME"].stringValue
            self.contact = json["USER_HP_NO"].stringValue
            self.attachGrpSeq = json["ATTACH_GRP_NO"].stringValue
            
            completion?(true, "")
        }
    }
    
    /// 프로필 이미지 등록
    func uploadProfileImage(imgData: Data, completion: ResponseString = nil) {
        uploadImage(imgData: imgData, attachType: AttachType.profile) { (success, msg) in
            _cas.mypage.registerProfilePicture(attachGrpSeq: self.attachGrpSeq) { (success, json) in
                var msg: String = ""
                if success {
//                    self.reset()
                } else {
                    msg = ApiManager.getFailedMsg(defaultMsg: "사진을 등록하지 못했습니다.", json: json)
                }
                completion?(success, msg)
            }
        }
    }
    
    /// 폰번호 변경
    func setPhone(phone: String, completion: ResponseString = nil) {
        _cas.mypage.setPhone(phone: phone) { (success, json) in
            guard success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "휴대폰 번호를 변경하지 못했습니다. 다시 시도해주시기 바랍니다.", json: json))
                return
            }
            
            completion?(true, "")
        }
    }
    
    /// 내 정보 저장
    func setMyinfo(email: String, completion: ResponseString = nil) {
        if attachGrpSeq.isEmpty {
            _cas.attach.getAttachGrpSeq() { (success, msg) in
                self.attachGrpSeq = msg
                self.requestSetMyInfo(email: email, completion: completion)
            }
        } else {
            requestSetMyInfo(email: email, completion: completion)
        }
        
    }
    
    private func requestSetMyInfo(email: String, completion: ResponseString = nil) {
        _cas.mypage.setMyinfo(email: email, attachGrpSeq: attachGrpSeq) { (success, json) in
            guard success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "저장을 완료하지 못했습니다.", json: json))
                return
            }
            
            completion?(true, "저장되었습니다.")
        }
    }
    
    /// 로그아웃
    func signout(completion: ResponseString = nil) {
        _cas.mypage.signout() { (success, json) in
            var message: String = ""
            if success { message = _strings[.signOutDone] }
            else { message = ApiManager.getFailedMsg(defaultMsg: "로그아웃을 완료하지 못했습니다.", json: json) }
            completion?(success, message)
        }
    }
}
