//
//  StorageOrderVm.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/07.
//

import Foundation

protocol StorageOrderVmDelegate {
    func ready()
}

class StorageOrderVm: UploadVm {
    var presignedUrl: String = ""
    var attachGrpSeq: String = ""
    var attachSeq: String = ""
    var uploadedCount: Int = 0
    
    let careCost: Int = 1000
    var purchasingData: PurchasingData!
    
    // MARK: - 짐 사진 등록
    /// 짐 사진 등록
    func registerLuggagePicutures(imgs: [Data?], completion: ResponseString = nil) {
        if imgs.isEmpty { completion?(true, ""); return }
        
        var message: String = ""
        self.uploadStoragePictures(imgDatas: imgs) { (success, msg) in
            if false == success, false == msg.isEmpty { message = msg }
            self.purchasingData.attachGrpSeq = self.attachGrpSeq
            completion?(success, message)
        }
    }
    
    /// 여러개의 이미지를 순서대로 업로드함
    func uploadStoragePictures(imgDatas: [Data?], completion: ResponseString = nil) {
        let maxUploadCount: Int = imgDatas.count
        guard maxUploadCount > 0 else { completion?(true, ""); return }
        uploadedCount = 0
        
        func upload(imgData: Data?, attachType: AttachType, completion: ResponseString = nil) {
            guard let imgData = imgData else {
                reUpload()
                return
            }
            
            uploadImage(imgData: imgData, attachType: attachType) { (success, msg) in
                reUpload()
            }
        }
        
        func reUpload() {
            if self.uploadedCount >= maxUploadCount - 1 {
                completion?(true, "")
                return
            }
            
            self.uploadedCount += 1
            upload(imgData: imgDatas[self.uploadedCount], attachType: .luggage)
        }
        
        upload(imgData: imgDatas[uploadedCount], attachType: .luggage)
    }
    
    // MARK: - 결제 요청
    /// 결제 요청
    func requestPurchasing(purchasingData: PurchasingData, completion: ResponseString = nil) {
        _cas.purchsing.requestPurchsing(data: purchasingData) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "결제를 완료하지 못했습니다.", json: json))
                return
            }
            
            let orderSeq = json["resMsg"].stringValue
            self.purchasingData.orderSeq = orderSeq
            completion?(true, "")
        }
    }

}
