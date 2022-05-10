//
//  ReviewDetailVm.swift
//  Carrifree
//
//  Created by orca on 2022/03/18.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 ReviewDetailVm
//  리뷰 상세 정보 화면 veiw model
//

import Foundation

protocol ReviewDetailVmDelegate {
    func ready()
    func notReady(msg: String)
}

class ReviewDetailVm {
    var delegate: ReviewDetailVmDelegate?
    var reviewSeq: String = ""
    var storageName: String = ""
    var userName: String = ""
    var reviewDate: String = ""
    var reviewContent: String = ""
    var imgUrls: [String] = []
    var attachGrpSeq: String = ""
    var storageSeq: String = ""
    var lat: Double = 0
    var lng: Double = 0
    
    init(reviewSeq: String, delegate: ReviewDetailVmDelegate) {
        self.reviewSeq = reviewSeq
        self.delegate = delegate
        getReviewContent(reviewSeq: reviewSeq) { (success, msg) in
            if success {
                self.delegate?.ready()
            } else {
                self.delegate?.notReady(msg: msg)
            }
        }
    }
    
    /// 리뷰 상세내용 보기
    func getReviewContent(reviewSeq: String, completion: ResponseString = nil) {
        _cas.reviewDetail.getReviewContent(reviewSeq: reviewSeq) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "리뷰 내용을 불러오지 못했습니다.", json: json))
                return
            }
            
            let val = json["getSearchWareHouseReviewDetail"]
            self.reviewSeq = val["REVIEW_SEQ"].stringValue
            self.userName = val["USER_NAME"].stringValue
            self.reviewContent = val["REVIEW_BODY"].stringValue
            self.reviewDate = val["REVIEW_DATE"].stringValue
            self.storageName = val["BIZ_NAME"].stringValue
            self.storageSeq = val["BIZ_USER_SEQ"].stringValue
            self.lat = val["BIZ_LAT"].doubleValue
            self.lng = val["BIZ_LNG"].doubleValue
            completion?(true, "")
        }
    }
    
    /// 리뷰 사진 목록 요청
    func getReviewPictures(attachGrpSeq: String, completion: ResponseString = nil) {
        _cas.reviewDetail.getReviewPictures(attachGrpSeq: attachGrpSeq) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "리뷰 사진을 불러오지 못했습니다.", json: json))
                return
            }
            
            let arr = json["reviewPicList"].arrayValue
            for val in arr {
//                let attachSeq = val["REVIEW_ATTACH_SEQ"].stringValue
//                let attachGrpSeq = val["REVIEW_ATTACH_GRP_SEQ"].stringValue
                let imgUrl = val["REVIEW_ATTACH_INFO"].stringValue
                self.imgUrls.append(imgUrl)
            }
            completion?(true, "")
        }
    }
    
}

