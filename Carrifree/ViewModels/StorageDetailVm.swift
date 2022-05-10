//
//  StorageDetailVm.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/18.
//
//
//  💬 StorageDetailVm
//  보관소 상세 화면 View Model
//

import Foundation
import SwiftyJSON

@objc protocol StorageDetailVmDelegate {
    @objc optional func ready()
    @objc optional func notReady(msg: String)
}

class StorageDetailVm {
    
    let maxPictureCount: Int = 10
    
    var delegate: StorageDetailVmDelegate?
    var data: StorageDetailData!
    var pictures: [PictureData] = []
    var attachGrpSeq: String = ""
    var delSeq: String = ""             // 지우는 사진의 seq
    
    init(storageSeq: String, lat: Double, lng: Double, delegate: StorageDetailVmDelegate?) {
        self.delegate = delegate
        
//        setDummyDatas()
        
        if storageSeq.isEmpty { delegate?.notReady?(msg: "잘못된 보관소 정보입니다.\n(empty seq)") }
        
        // 보관소 정보
        getStorageInfo(storageSeq: storageSeq, lat: lat, lng: lng) { (success, msg) in
            var message: String = ""
            if false == success { message = msg }
            
            // 쉬는날
            self.getDayoff() {
                if false == success { message = msg }
                // 보관 장점
                self.getMerits() { (success, msg) in
                    if false == success { message = msg }
                    
                    // 가격
                    self.getCosts(storageSeq: storageSeq) { (success, msg) in
                        if false == success { message = msg }
                        
                        self.getReviews(storageSeq: storageSeq) { (success, msg) in
                            if false == success { message = msg }
                            guard message.isEmpty else { self.delegate?.notReady?(msg: message); return }
                            self.delegate?.ready?()
                        }
                        
                    }
                }
            }
        }
    }
    
    /// 가격 데이터에서 가격 string을 가져옴
    func getCostStrings(costs: [CostData]) -> [String] {
        var costString: [String] = []
        for cost in costs {
            costString.append(cost.price)
        }
        
        return costString
    }
    
    /// 삭제할 파일 시퀀스 추가
    func deletePicture(seq: String) {
        if seq.isEmpty { return }
        
        if delSeq.isEmpty {
            delSeq = seq
        } else {
            
            // 중복 seq가 입력되지않게 함
            let delSeqArr = delSeq.split(separator: ",").map { (value) -> String in return String(value) }
            for value in delSeqArr { if seq == value { return } }
            
            delSeq += ",\(seq)"
        }
    }
    
    /// delSeq 초기화
    func initDelSeq() {
        delSeq = ""
    }
    
    /// 쉬는날(요일) 조회
    func getDayoff(completion: (() -> Void)? = nil) {
        _cas.general.getStorageCodes(all: false, userSeq: data.seq, code: .weeks) { (codes) in
            for code in codes {
                let weekdayInt = Weekday.getWeekday(type: code.code).rawValue
                self.data.dayoff.append(weekdayInt)
            }
            
            completion?()
        }
    }
    
    func getCost(startDate: String, endDate: String, luggages: Luggages) -> String {
        let startDateObj = startDate.toDate()
        let endDateObj = endDate.toDate()
        let storageTime = _utils.getTimeIntervalInt(start: startDateObj, end: endDateObj)
        
        let defaultTime: Int = 4
        let dayTime: Int = 24
        
        var totalCost: Int = 0
        
        // 기본 요금 (보관시시간이 기본(4시간) 이하)
        if storageTime <= defaultTime {
            for _ in 0 ..< luggages.s { totalCost += getDefaultCost(luggageType: .s) }
            for _ in 0 ..< luggages.m { totalCost += getDefaultCost(luggageType: .m) }
            for _ in 0 ..< luggages.l { totalCost += getDefaultCost(luggageType: .l) }
            for _ in 0 ..< luggages.xl { totalCost += getDefaultCost(luggageType: .xl) }
        }
        // 기본 요금 + 추가 요금 (보관시시간이 기본(4시간) 초과)
        else if storageTime < dayTime {
            for _ in 0 ..< luggages.s { totalCost += getExtraCost(luggageType: .s, storageTime: storageTime) }
            for _ in 0 ..< luggages.m { totalCost += getExtraCost(luggageType: .m, storageTime: storageTime) }
            for _ in 0 ..< luggages.l { totalCost += getExtraCost(luggageType: .l, storageTime: storageTime) }
            for _ in 0 ..< luggages.xl { totalCost += getExtraCost(luggageType: .xl, storageTime: storageTime) }
        }
        // 1일 최대 요금 (보관 시간 1일 이상)
        else {
            for _ in 0 ..< luggages.s { totalCost += getDayCost(luggageType: .s, storageTime: storageTime) }
            for _ in 0 ..< luggages.m { totalCost += getDayCost(luggageType: .m, storageTime: storageTime) }
            for _ in 0 ..< luggages.l { totalCost += getDayCost(luggageType: .l, storageTime: storageTime) }
            for _ in 0 ..< luggages.xl { totalCost += getDayCost(luggageType: .xl, storageTime: storageTime) }
        }
        
        return "\(totalCost)"
    }
    
    /// 특정 짐의 기본 보관 요금 반환
    func getDefaultCost(luggageType: LuggageType) -> Int {
        var cost: Int = 0
        
        for defaultCost in data.defaultCosts {
            if defaultCost.type == luggageType.type {
                cost = _utils.getIntFromDelimiter(str: defaultCost.price)
                break
            }
        }
        
        return cost
    }
    
    /// 특정 짐의 추가 보관 요금 반환
    func getExtraCost(luggageType: LuggageType, storageTime: Int) -> Int {
        var defaultCost: Int = 0
        for cost in data.defaultCosts {
            if cost.type == luggageType.type {
                defaultCost = _utils.getIntFromDelimiter(str: cost.price)
                break
            }
        }
        
        var extraCost: Int = 0
        for cost in data.extraCosts {
            if cost.type == luggageType.type {
                extraCost = _utils.getIntFromDelimiter(str: cost.price)
                break
            }
        }
        
        var dayCost: Int = 0
        for cost in data.dayCosts {
            if cost.type == luggageType.type {
                dayCost = _utils.getIntFromDelimiter(str: cost.price)
                break
            }
        }
        
        let defaultTime: Int = 4
        let extraTime = storageTime - defaultTime
        var totalCost = defaultCost + (extraCost * extraTime)
        if totalCost > dayCost { totalCost = dayCost }
        return totalCost
    }
    
    /// 특정 짐의 1일 최대 보관 요금 반환
    func getDayCost(luggageType: LuggageType, storageTime: Int) -> Int {
        var dayCost: Int = 0
        for cost in data.dayCosts {
            if cost.type == luggageType.type {
                dayCost = _utils.getIntFromDelimiter(str: cost.price)
                break
            }
        }
        
        var extraCost: Int = 0
        for cost in data.extraCosts {
            if cost.type == luggageType.type {
                extraCost = _utils.getIntFromDelimiter(str: cost.price)
                break
            }
        }
        
        let dayTime: Int = 24
        let day = storageTime / dayTime
        var totalCost = dayCost * day
        
        let remain = storageTime % dayTime
        var remainCost = remain * extraCost
        if remainCost > dayCost { remainCost = dayCost }
        totalCost += remainCost
                
        return totalCost
    }
    
    // MARK: - 보관소 상세 정보 조회
    /// 보관소 상세 정보 조회
    func getStorageInfo(storageSeq: String, lat: Double, lng: Double, completion: ResponseString = nil) {
        _cas.storageDetail.getStorageInfo(storageSeq: storageSeq) { (success, json) in
            guard let json = json, true == success else {
//                self.delegate?.notReady?(msg: ApiManager.getFailedMsg(defaultMsg: "보관소 정보를 불러오지 못했습니다. 다시 시도해주시기 바랍니다.", json: json))
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "보관소 정보를 불러오지 못했습니다. 다시 시도해주시기 바랍니다.", json: json))
                return
            }
            
            let val = json["detailWareHouseInfo"]
            let name = val["USER_NAME"].stringValue
            let category = val["CD_BIZ_TYPE"].stringValue
            let address = val["BIZ_SIMPLE_ADDR"].stringValue
            let pr = val["WAREHOUSE_ISSUE"].stringValue
            let statusText = val["WAREHOUSE_RATE_TEXT"].stringValue
            let mainPicture = val["MAJOR_ATTACH_INFO"].stringValue
            let open = val["WORK_STA_TIME"].stringValue
            let close = val["WORK_OUT_TIME"].stringValue
            let rating = val["REVIEW_POINT_AVG"].doubleValue
            let masterSeq = val["MASTER_SEQ"].stringValue
            let attachGrpSeq = val["ATTACH_GRP_SEQ"].stringValue
//            let storageSeq = val["USER_WAREHOUSE_SEQ"].stringValue
            
            var storage = StorageDetailData(name: name)
            storage.setCategory(category: category)
            storage.setAddress(address: address)
            storage.setPr(pr: pr)
            storage.setStatus(status: statusText)
            storage.setImgUrls(imgUrls: [mainPicture])
            storage.setWorktime(worktime: "\(open) - \(close)")
            storage.setRating(rating: rating)
            storage.setMasterSeq(masterSeq: masterSeq)
            storage.setSeq(seq: storageSeq)
            storage.setLat(lat: lat)
            storage.setLng(lng: lng)
            self.attachGrpSeq = attachGrpSeq
            self.data = storage
            
            completion?(true, "")
        }
        
    }
    
    /// 보관소 사진 조회
    func getStoragePictures(completion: ResponseJson = nil) {
        _cas.storageDetail.getStoragePictures(storageSeq: data.seq, attachGrpSeq: attachGrpSeq) { (success, json) in
            guard let json = json, true == success else {
                completion?(true, "")
                return
            }
            
            var imgUrls: [String] = []
            let arr0 = json["saverPicList"].arrayValue
            for val in arr0 {
                let imgUrl = val["ATTACH_INFO"].stringValue
                imgUrls.append(imgUrl)
            }
            
            let arr1 = json["majorPicList"].arrayValue
            for val in arr1 {
                let imgUrl = val["ATTACH_INFO"].stringValue
                imgUrls.append(imgUrl)
            }
            
            let arr2 = json["beforeAfterPicList"].arrayValue
            for val in arr2 {
                let imgUrl = val["ATTACH_INFO"].stringValue
                imgUrls.append(imgUrl)
            }
            self.data.imgUrls = imgUrls
            completion?(true, "")
        }
    }
    
    // MARK: - 보관 장점 조회
    /// 보관 장점 조회
    func getMerits(completion: ResponseString = nil) {
        if nil == data { completion?(false, "잘못된 보관소 정보입니다. 다시 시도해주시기 바랍니다."); return }
        self.data.merits.removeAll()
        
        _cas.general.getStorageCodes(all: false, userSeq: data.seq, code: .merit) { (codes) in
            for code in codes {
                let name = StorageMerit(rawValue: code.code)?.name ?? ""
                self.data.merits.append(name)
            }
            
            completion?(true, "")
        }
    }
    
    // MARK: - 요금 조회
    /// 요금 조회
    func getCosts(storageSeq: String, completion: ResponseString = nil) {
        _cas.storageDetail.getCosts(storageSeq: storageSeq) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "보관 요금을 불러오지 못했습니다.", json: json))
                return
            }
            
            self.data.defaultCosts.removeAll()
            let defaultCostArr = json["basicPriceList"].arrayValue
            for val in defaultCostArr {
                let cost = self.parseCosts(json: val)
                self.data.defaultCosts.append(cost)
            }
            
            self.data.extraCosts.removeAll()
            let extraCostArr = json["overPriceList"].arrayValue
            for val in extraCostArr {
                let cost = self.parseCosts(json: val)
                self.data.extraCosts.append(cost)
            }
            
            self.data.dayCosts.removeAll()
            let dayCostArr = json["oneDayPriceList"].arrayValue
            for val in dayCostArr {
                let cost = self.parseCosts(json: val)
                self.data.dayCosts.append(cost)
            }
                
            completion?(true, "")
        }
    }
    
    /// 보관소 요금 parsing
    func parseCosts(json: JSON) -> CostData {
        let storageCost = CostData()
        storageCost.seq = json["RATE_SEQ"].stringValue
        storageCost.type = json["RATE_KIND"].stringValue
        storageCost.section = json["RATE_USER_SECTION"].stringValue
        storageCost.price = json["RATE_USER_PRICE"].stringValue
        return storageCost
    }
    
    // MARK: - 리뷰 조회
    /// 리뷰 조회
    func getReviews(storageSeq: String, completion: ResponseString = nil) {
        data.reviews.removeAll()
        _cas.storageDetail.getReviews(storageSeq: storageSeq) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "리뷰를 불러오지 못했습니다.", json: json))
                return
            }
            
            //      [getSearchWareHouseReviewList]
            //      USER_NAME               <String>        리뷰작성자
            //      MAJOR_ATTACH_INFO       <String>        보관소 사진 정보
            //      BIZ_NAME                <String>        상호명
            //      REVIEW_BODY             <String>        리뷰 내용
            //      REVIEW_RECOMMEND        <Number>        리뷰 추천수
            //      REVIEW_POINT            <Number>        보관소에 부여한 리뷰 점수
            //      REVIEW_SEQ              <Number>        리뷰 시퀀스
            //      REVIEW_ATTACH_GRP_SEQ   <Number>        리뷰 사진 그룹 시퀀스
            
            let arr = json["getSearchWareHouseReviewList"].arrayValue
            for val in arr {
                let seq = val["REVIEW_SEQ"].stringValue
                let imgUrl = val["MAJOR_ATTACH_INFO"].stringValue
                let bizname = val["BIZ_NAME"].stringValue
                let content = val["REVIEW_BODY"].stringValue
                let rating = val["REVIEW_POINT"].doubleValue
                let attachGrpSeq = val["REVIEW_ATTACH_GRP_SEQ"].stringValue
                let username = val["USER_NAME"].stringValue
                let like = val["REVIEW_RECOMMEND"].intValue
                
                let review = ReviewData(seq: seq, imgUrl: imgUrl, bizname: bizname, content: content, username: username, like: like, rating: rating, attachGrpSeq: attachGrpSeq)
                self.data.reviews.append(review)
            }
            
            completion?(true, "")
        }
    }
}
