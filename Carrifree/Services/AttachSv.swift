//
//  AttachSv.swift
//  Carrifree
//
//  Created by orca on 2022/02/18.
//  Copyright © 2022 plattics. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class AttachSv: Service {
    
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    func getAttachGrpSeq(completeion: ResponseString = nil) {
        let url = getRequestUrl(body: "/sys/attach/admin/getFileGrpSeqAjax.do")
        apiManager.requestSimpleGetString(api: .getAttachGrpSeq, url: url) { (success, msg) in
            completeion?(success, msg)
        }
    }
    
    /// 이미지 업로드
    func uploadImage(url: String, imgData: Data, attachSeq: String, attachGrpSeq: String, completeion: ResponseString = nil) {
        
        // 업로드
        self.apiManager.requestUpload(isPrivate: false, data: imgData, url: url) { (uploadSuccess, msg) in
            if uploadSuccess {
                guard let headers = self.getHeader() else { completeion?(false, msg); return }
                let uploadCompleteUrl = _utils.getRequestUrl(body: "/sys/attach/image/completeUpload.do")
                
                let param: [String: String] = [
                    "ATTACH_SEQ": attachSeq,
                    "ATTACH_GRP_SEQ": attachGrpSeq
                ]
                
                // 업로드 완료 상태 저장
                self.apiManager.request(api: .none, url: uploadCompleteUrl, headers: headers, parameters: param) { (finishSuccess, json) in
                    if finishSuccess { completeion?(true, "") }
                    else {
                        let failedMsg = ApiManager.getFailedMsg(defaultMsg: "업로드 완료 상태를 저장하지 못했습니다.", json: json)
                        completeion?(false, failedMsg)
                    }
                }
            } else {
                completeion?(false, msg)
            }
        }
    }
    
    /// 업로드할 PreSigned URL 요청
    func getPresignedUrl(attachType: AttachType, attachGrpSeq: String, completion: ResponsePresignedUrl = nil) {
        //-------------------------- Request -------------------------- //
        //
        //          USER_SEQ                유저 seq
        //          module                  첨부파일 저장 공간 코드 (AttachModule)
        //          type                    첨부파일 타입 (AttachType)
        //          file_name               첨부파일 이름
        //          ATTACH_GRP_SEQ          첨부파일 그룹 시퀀스
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        let param: [String: String] = [
            "USER_SEQ": _user.seq,
            "module": AttachModule.user.rawValue,
            "type": attachType.rawValue,
            "file_name": "\(_user.id)_\(attachType.rawValue)_\(Date().timestampString).jpg",
            "ATTACH_GRP_SEQ": attachGrpSeq
        ]
        
        // 공개 이미지 업로드 presigned
        var url = getRequestUrl(body: "/sys/attach/image/setUploadPreSignedUrl.do")
        
        // 비공개 이미지 업로드 presigned url 요청
        if attachType.isPrivate { url = getRequestUrl(body: "/sys/attachV2/app/setUploadPreSignedUrl.do") }
        
        apiManager.request(api: .uploadPreSign, url: url, parameters: param) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, "", "", "", ApiManager.getFailedMsg(defaultMsg: "pre-signed url 요청을 완료하지 못했습니다.", json: json))
                return
            }
            
            let presignedUrl = json["preSignedInfo"]["preSignedUrl"].stringValue
            let attachGrpSeq = json["attachInfo"]["ATTACH_GRP_SEQ"].stringValue
            let attachSeq = json["attachInfo"]["ATTACH_SEQ"].stringValue
            completion?(true, presignedUrl, attachGrpSeq, attachSeq, "")
        }
    }
    
    /// 비공개 이미지 다운로드
    func getPrivateImage(attachGrpSeq: String, attachSeq: String, completion: ResponseString = nil) {
        
        guard let headers = getHeader() else { completion?(false, ""); return }
        
        let param: [String: String] = [
            "USER_SEQ": _user.seq,
            "ATTACH_GRP_SEQ": attachGrpSeq,
            "ATTACH_SEQ": attachSeq
        ]
        
        let url = getRequestUrl(body: "/sys/attachV2/app/loadFile.do")
        apiManager.request(api: .requestPrivateDownload, url: url, headers: headers, parameters: param) { (success, json) in
            if success {
                completion?(true, "")
            } else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg:"파일을 다운로드하지 못했습니다.", json: json))
            }
        }
        
    }
    
}
