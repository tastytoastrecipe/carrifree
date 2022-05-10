//
//  UploadVm.swift
//  Carrifree
//
//  Created by orca on 2022/02/24.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 UploadVm
//  이미지 업로드 기능을 가진 View Model Protocol
//

import Foundation

@objc protocol UploadVm {
    var presignedUrl: String { get set }
    var attachGrpSeq: String { get set }
    var attachSeq: String { get set }
}

extension UploadVm {
    /// 이미지 업로드
    func uploadImage(imgData: Data, attachType: AttachType, completion: ResponseString = nil) {
        // attachGrpSeq 받아오기
        if attachGrpSeq.isEmpty {
            _cas.attach.getAttachGrpSeq() { (success, msg) in
                if true == success, false == msg.isEmpty {
                    _log.logWithArrow("AttachGrpSeq 요청 성공", "<\(msg)>")
                    self.attachGrpSeq = msg
                    self.uploadStart(imgData: imgData, attachType: attachType, attachGrpSeq: self.attachGrpSeq, completion: completion)
                } else {
                    completion?(false, "AttachGrpSeq를 불러오지 못했습니다. \(_strings[.plzTryAgain])")
                }
            }
        } else {
            uploadStart(imgData: imgData, attachType: attachType, attachGrpSeq: attachGrpSeq, completion: completion)
        }
    }
    
    /// 이미지 업로드
    /*
    func uploadImage(imgData: Data, attachType: AttachType, completion: ResponseString = nil) {
        // attachGrpSeq 받아오기
        uploadStart(imgData: imgData, attachType: attachType, attachGrpSeq: attachGrpSeq, completion: completion)
    }
    */
    
    /// 이미지 업로드
    private func uploadStart(imgData: Data, attachType: AttachType, attachGrpSeq: String, completion: ResponseString = nil) {
        // 업로드할 URL 요청
        _cas.attach.getPresignedUrl(attachType: attachType, attachGrpSeq: attachGrpSeq) { (success, url, attachGrpSeq, attachSeq, msg) in
            let presignedUrl = url
            self.attachGrpSeq = attachGrpSeq
            self.attachSeq = attachSeq
            if url.isEmpty || attachGrpSeq.isEmpty { completion?(false, msg) }
            _log.logWithArrow("pre-signed url 요청 성공", "pre-sigend url: \(presignedUrl)\n\nAttachGrpSeq<\(attachGrpSeq)> / AttachSeq<\(attachSeq)>")
            
            // 업로드
            _cas.attach.uploadImage(url: presignedUrl, imgData: imgData, attachSeq: self.attachSeq, attachGrpSeq: self.attachGrpSeq) { (success, msg) in
                completion?(success, msg)
            }
        }
    }
    
    func reset() {
        presignedUrl = ""
        attachSeq = ""
        attachGrpSeq = ""
    }
}
