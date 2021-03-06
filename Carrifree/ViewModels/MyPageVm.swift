//
//  MyPageVm.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/24.
//
//
//  ๐ฌ StorageDetailVmDelegate
//  ๋ณด๊ด์ ์์ธ ํ๋ฉด View Model
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
        name = "๊ถํ์  ๋"
        id = "M2000000001"
        contact = "+82 010-4818-9993"
        email = "platticskwon@gmail.com"
        giftBadge = 5
        reviewsBadge = 1
    }
    
    /// ๋ด ์ ๋ณด ์กฐํ
    func getMyInfo(completion: ResponseString = nil) {
        _cas.mypage.getMyInfo() { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "๋ด ์ ๋ณด๋ฅผ ๋ถ๋ฌ์ค์ง ๋ชปํ์ต๋๋ค.", json: json))
                return
            }
            
            //      USER_ATTACH_INFO        <String>        ํ๋กํ ์ฌ์ง ์ ๋ณด
            //      USER_EMAIL              <String>        ์ด๋ฉ์ผ
            //      USER_ID                 <String>        ์์ด๋
            //      USER_NAME               <String>        ์ด๋ฆ
            //      USER_HP_NO              <String>        ํธ๋ํฐ๋ฒํธ
            //      ATTACH_GRP_NO           <Number>        ์ฒจ๋ถํ์ผ ์ํ์ค
            
            self.profile = json["USER_ATTACH_INFO"].stringValue
            self.email = json["USER_EMAIL"].stringValue
            self.id = json["USER_ID"].stringValue
            self.name = json["USER_NAME"].stringValue
            self.contact = json["USER_HP_NO"].stringValue
            self.attachGrpSeq = json["ATTACH_GRP_NO"].stringValue
            
            completion?(true, "")
        }
    }
    
    /// ํ๋กํ ์ด๋ฏธ์ง ๋ฑ๋ก
    func uploadProfileImage(imgData: Data, completion: ResponseString = nil) {
        uploadImage(imgData: imgData, attachType: AttachType.profile) { (success, msg) in
            _cas.mypage.registerProfilePicture(attachGrpSeq: self.attachGrpSeq) { (success, json) in
                var msg: String = ""
                if success {
//                    self.reset()
                } else {
                    msg = ApiManager.getFailedMsg(defaultMsg: "์ฌ์ง์ ๋ฑ๋กํ์ง ๋ชปํ์ต๋๋ค.", json: json)
                }
                completion?(success, msg)
            }
        }
    }
    
    /// ํฐ๋ฒํธ ๋ณ๊ฒฝ
    func setPhone(phone: String, completion: ResponseString = nil) {
        _cas.mypage.setPhone(phone: phone) { (success, json) in
            guard success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "ํด๋ํฐ ๋ฒํธ๋ฅผ ๋ณ๊ฒฝํ์ง ๋ชปํ์ต๋๋ค. ๋ค์ ์๋ํด์ฃผ์๊ธฐ ๋ฐ๋๋๋ค.", json: json))
                return
            }
            
            completion?(true, "")
        }
    }
    
    /// ๋ด ์ ๋ณด ์ ์ฅ
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
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "์ ์ฅ์ ์๋ฃํ์ง ๋ชปํ์ต๋๋ค.", json: json))
                return
            }
            
            completion?(true, "์ ์ฅ๋์์ต๋๋ค.")
        }
    }
    
    /// ๋ก๊ทธ์์
    func signout(completion: ResponseString = nil) {
        _cas.mypage.signout() { (success, json) in
            var message: String = ""
            if success { message = _strings[.signOutDone] }
            else { message = ApiManager.getFailedMsg(defaultMsg: "๋ก๊ทธ์์์ ์๋ฃํ์ง ๋ชปํ์ต๋๋ค.", json: json) }
            completion?(success, message)
        }
    }
}
