//
//  HomeVm.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/07.
//

import Foundation
import SwiftyJSON

@objc protocol HomeVmDelegate {
    @objc optional func ready()
}

class HomeVm {
    
    var delegate: HomeVmDelegate?
    var banners: [BannerData]
    var storages: [StorageData]
    var reviews: [ReviewData]
    
    init(delegate: HomeVmDelegate) {
        self.delegate = delegate
        banners = []
        storages = []
        reviews = []
        
//        setDummyDatas()
    }
    
    func setDummyDatas() {
        banners = [BannerData(seq: "", pageUrl: "https://www.daum.net", imgUrl: "img-banner-0"),
                   BannerData(seq: "", pageUrl: "https://www.daum.net", imgUrl: "img-banner-1"),
                   BannerData(seq: "", pageUrl: "https://www.daum.net", imgUrl: "img-banner-2")]
        
        storages = [StorageData(name: "보관소 01", imgUrl: "img-test-storage-0", distance: 0.8, rating: 4.5, seq: ""),
                    StorageData(name: "보관소 02", imgUrl: "img-test-storage-1", distance: 3.0, rating: 3.2, seq: ""),
                    StorageData(name: "보관소 03", imgUrl: "img-test-storage-2", distance: 1.0, rating: 5.0, seq: ""),
                    StorageData(name: "보관소 04", imgUrl: "img-test-storage-3", distance: 2.3, rating: 3.6, seq: ""),
                    StorageData(name: "보관소 05", imgUrl: "img-test-storage-4", distance: 0.4, rating: 2.5, seq: "")
        ]
        
        reviews = [ReviewData(seq: "", imgUrl: "img-test-storage-0", bizname: "보관소 01", content: "안녕하세요\n리뷰 내용입니다", username: "유저 01", like: Int.random(in: 0 ... 100), rating: 4.5, attachGrpSeq: ""),
                   ReviewData(seq: "", imgUrl: "img-test-storage-1", bizname: "보관소 02", content: "안녕하세요\n리뷰 내용입니다", username: "유저 02", like: Int.random(in: 0 ... 100), rating: 2.5, attachGrpSeq: ""),
                   ReviewData(seq: "", imgUrl: "img-test-storage-2", bizname: "보관소 03", content: "안녕하세요\n리뷰 내용입니다", username: "유저 03", like: Int.random(in: 0 ... 100), rating: 3.1, attachGrpSeq: ""),
                   ReviewData(seq: "", imgUrl: "img-test-storage-3", bizname: "보관소 04", content: "안녕하세요\n리뷰 내용입니다", username: "유저 04", like: Int.random(in: 0 ... 100), rating: 1.1, attachGrpSeq: ""),
                   ReviewData(seq: "", imgUrl: "img-test-storage-4", bizname: "보관소 05", content: "안녕하세요\n리뷰 내용입니다", username: "유저 05", like: Int.random(in: 0 ... 100), rating: 4.8, attachGrpSeq: ""),
                   ReviewData(seq: "", imgUrl: "img-test-storage-0", bizname: "보관소 06", content: "안녕하세요\n리뷰 내용입니다", username: "유저 06", like: Int.random(in: 0 ... 100), rating: 2.3, attachGrpSeq: ""),
                   ReviewData(seq: "", imgUrl: "img-test-storage-1", bizname: "보관소 07", content: "안녕하세요\n리뷰 내용입니다", username: "유저 07", like: Int.random(in: 0 ... 100), rating: 4.4, attachGrpSeq: ""),
                   ReviewData(seq: "", imgUrl: "img-test-storage-2", bizname: "보관소 08", content: "안녕하세요\n리뷰 내용입니다", username: "유저 08", like: Int.random(in: 0 ... 100), rating: 3.9, attachGrpSeq: ""),
                   ReviewData(seq: "", imgUrl: "img-test-storage-3", bizname: "보관소 09", content: "안녕하세요\n리뷰 내용입니다", username: "유저 09", like: Int.random(in: 0 ... 100), rating: 4.0, attachGrpSeq: ""),
                   ReviewData(seq: "", imgUrl: "img-test-storage-4", bizname: "보관소 10", content: "안녕하세요\n리뷰 내용입니다", username: "유저 10", like: Int.random(in: 0 ... 100), rating: 3.3, attachGrpSeq: ""),
                   ReviewData(seq: "", imgUrl: "img-test-storage-0", bizname: "보관소 11", content: "안녕하세요\n리뷰 내용입니다", username: "유저 11", like: Int.random(in: 0 ... 100), rating: 2.7, attachGrpSeq: ""),
                   ReviewData(seq: "", imgUrl: "img-test-storage-1", bizname: "보관소 12", content: "안녕하세요\n리뷰 내용입니다", username: "유저 12", like: Int.random(in: 0 ... 100), rating: 2.0, attachGrpSeq: ""),
                   ReviewData(seq: "", imgUrl: "img-test-storage-2", bizname: "보관소 13", content: "안녕하세요\n리뷰 내용입니다", username: "유저 13", like: Int.random(in: 0 ... 100), rating: 4.8, attachGrpSeq: ""),]
    }
    
    /// 배너 정보 요청
    func getBanners(completion: ResponseString = nil) {
        banners.removeAll()
        _cas.home.getBanners(bannerCase: BannerCase.user.rawValue, bannerGroup: BannerGroup.user01.rawValue) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "배너 데이터를 받지 못했습니다.", json: json))
                return
            }
            
            let arr = json["bannerList"].arrayValue
            for val in arr {
                /*
                let seq = val["BOARD_SEQ"].stringValue
                let title = val["BOARD_TITLE"].stringValue
                let attachGrpSeq = val["BRD_ATTACH_GRP_SEQ"].stringValue
                let attachSeq = val["ATTACH_SEQ"].stringValue
                let bgColor = val["BACKGROUND_COLOR"].stringValue
                */
                
                let seq = val["BOARD_SEQ"].stringValue
                let imgUrl = val["BANNER_ATTACH_INFO"].stringValue
                let pageUrl = val["LINK_URL"].stringValue
                let data = BannerData(seq: seq, pageUrl: pageUrl, imgUrl: imgUrl)
                self.banners.append(data)
            }
            
            completion?(true, "")
        }
    }
    
    /// 주변 보관소 조회
    func getStorages(coordinate: Coordinate, align: AlignNearStorage, completion: ResponseString = nil) {
        storages.removeAll()
        
        _cas.home.getStorages(coordinate: coordinate, align: align) { (success, json) in
            var msg: String = ""
            if let json = json, true == success {
                let arr = json["nearWareHouseList"].arrayValue
                for val in arr {
                    let name = val["USER_NAME"].stringValue
                    let dist = val["DISTANCE"].doubleValue
                    let imgUrl = val["MAJOR_ATTACH_INFO"].stringValue
                    let rating = val["REVIEW_POINT_AVG"].doubleValue
                    let seq = val["BIZ_USER_SEQ"].stringValue
                    let data = StorageData(name: name, imgUrl: imgUrl, distance: dist, rating: rating, seq: seq)
                    self.storages.append(data)
                }
                
            } else {
                msg = self.getFailedMsg(defaultMsg: "주변 보관소 정보를 불러오지 못했습니다.", json: json)
            }
            
            completion?(success, msg)
        }
    }
    
    /// 주변 보관소들의 리뷰 조회
    func getReviews(all: Bool, coordinate: Coordinate, category: StorageCategory, align: AlignNearReview, completion: ResponseString = nil) {
        reviews.removeAll()
        
        _cas.home.getReviews(all: all, lat: coordinate.lat, lng: coordinate.lng, category: category.rawValue, align: align.rawValue) { (success, json) in
            var msg: String = ""
            if let json = json, true == success {
                let arr = json["wareHouseReviewList"].arrayValue
                for val in arr {
                    let userName = val["USER_NAME"].stringValue
                    let bizName = val["BIZ_NAME"].stringValue
                    let imgUrl = val["MAJOR_ATTACH_INFO"].stringValue
                    let content = val["REVIEW_BODY"].stringValue
                    let like = val["REVIEW_RECOMMEND"].intValue
                    let rating = val["REVIEW_POINT"].doubleValue
                    let seq = val["REVIEW_SEQ"].stringValue
                    let grpSeq = val["REVIEW_ATTACH_GRP_SEQ"].stringValue
                    let data = ReviewData(seq: seq, imgUrl: imgUrl, bizname: bizName, content: content, username: userName, like: like, rating: rating, attachGrpSeq: grpSeq)
                    self.reviews.append(data)
                }
                
            } else {
                msg = self.getFailedMsg(defaultMsg: "주변 보관소 리뷰를 불러오지 못했습니다.", json: json)
            }
            
            completion?(success, msg)
        }
    }
    
    private func getFailedMsg(defaultMsg: String, json: JSON?) -> String {
        guard let json = json else { return defaultMsg }
        
        var msg = defaultMsg
        let errMsg = json["resMsg"].stringValue
        if errMsg.count > 0 { msg += "\n(\(errMsg))" }
        else { return msg }
        
        return msg
    }
}



