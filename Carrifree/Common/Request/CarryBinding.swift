//
//  CarryBinding.swift
//  Carrifree
//
//  Created by plattics-kwon on 2021/02/16.
//  Copyright © 2021 plattics. All rights reserved.
//
//
//  ## CarryBinding ##
//
//  CarryRequest에서 요청한 api에서 받은 정보를 사용할 수 있는 데이터로 변환한다
//

/*
import Foundation
import SwiftyJSON

class CarryBinding {
    init () {}
    
    func getRequestUrl(body: String) -> String {
        return "\(CarryRequest.shared.server)\(body)"
    }
    
    func bindingMain(json: JSON, completion: ResponseString = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      START_LAT               현재 내 위치 좌표
        //      START_LNG               현재 내 위치 좌표
        //      USER_SEQ                사용자 시퀀스
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (saverBizList)
        //      USER_SEQ                사용자 시퀀스
        //      USER_NAME               사용자 이름
        //      MAJOR_ATTACH_INFO       사진정보
        //      REVIEW_POINT_AVG        리뷰 평점
        //      REVIEW_POINT_CNT        리뷰 갯수
        //      DISTANCE                현 위치와의 거리
        //      BIZ_SIMPLE_ADDR         주소
        //      BIZ_DETAIL_ADDR         상세주소
        //
        //      (historyReserveList)
        //      ORDER_KIND_TXT          보관, 운송 텍스트 정보
        //      ORDER_KIND              보관, 운송 코드 정보
        //      SUBSTR_ENTRUST_ADDR     간단 시작 주소
        //      SUBSTR_TAKE_ADDR        간단 종료 주소
        //      ENTRUST_ADDR            시작 주소
        //      ENTRUST_LAT             시작 주소 좌표
        //      ENTRUST_LNG             시작 주소 좌표
        //      TAKE_ADDR               종료 주소
        //      TAKE_LAT                종료 주소 좌표
        //      TAKE_LNG                종료 주소 좌표
        //
        //------------------------------------------------------------- //
        
        let requestTitle = "[메인]"
        let msg = json["resMsg"].stringValue
        
        guard json["resCd"].stringValue == "0000" else {
            MyLog.logWithArrow("\(requestTitle) failed", msg)
            CarryEvents.shared.callSignInFailed()
            completion?(false, msg)
            return
        }
        
        CarrySearch.localStorage.removeAll()
        let saverArr = json["saverBizList"].arrayValue
        for saver in saverArr {
            let storage = Storage()
            let seq = saver["USER_SEQ"].stringValue
            let name = saver["USER_NAME"].stringValue
            
            let rating = saver["REVIEW_POINT_AVG"].floatValue
//            let reviewCount = saver["REVIEW_POINT_CNT"].stringValue
            let lat = saver["BIZ_LAT"].doubleValue
            let lng = saver["BIZ_LNG"].doubleValue
            let address = saver["BIZ_SIMPLE_ADDR"].stringValue
            let addressDetail = saver["BIZ_DETAIL_ADDR"].stringValue

            let distance = saver["DISTANCE"].stringValue
            
            var attachInfo = saver["MAJOR_ATTACH_INFO"].stringValue
            if attachInfo.contains("no_profile") { attachInfo = "" }
            
            storage.userSeq = seq
            storage.name = name
            storage.rating = rating
            storage.address = address
            storage.addressDetail = addressDetail
            storage.lat = lat
            storage.lng = lng
            storage.distance = distance
            
//            let imgUrl = CarryRequest.shared.getRequestUrl(body: attachInfo)
            storage.imgUrl = attachInfo
            CarrySearch.localStorage.append(storage)
        }
        
        CarryUser.recentReqeusts.removeAll()
        let requestArr = json["historyReserveList"].arrayValue
        for request in requestArr {
            let orderKindTxt = request["ORDER_KIND_TXT"].stringValue
            let orderKind = request["ORDER_KIND"].stringValue
            let startAddrSimple = request["SUBSTR_ENTRUST_ADDR"].stringValue
            let endAddrSimple = request["SUBSTR_TAKE_ADDR"].stringValue
            let startAddr = request["ENTRUST_ADDR"].stringValue
            let endAddr = request["TAKE_ADDR"].stringValue
            let startLat = request["ENTRUST_LAT"].doubleValue
            let startLng = request["ENTRUST_LNG"].doubleValue
            let endLat = request["TAKE_LAT"].doubleValue
            let endLng = request["TAKE_LNG"].doubleValue
            
            let recentRequest = RecentRequestData(serviceDetailTxt: orderKindTxt, serviceDetail: orderKind, startAddrSimple: startAddrSimple, startAddr: startAddr, endAddrSimple: endAddrSimple, endAddr: endAddr, startPoint: (startLat, startLng), endPoint: (endLat, endLng))
            CarryUser.recentReqeusts.append(recentRequest)
        }
        
        let driverArr = json["driverList"].arrayValue
        for driver in driverArr {
//            let attachGrpSeq = driver["ATTACH_GRP_SEQ"].stringValue
//            let majorAttachSeq = driver["MAJOR_ATTACH_SEQ"].stringValue
            
            let name = driver["BIZ_NAME"].stringValue
            let endAddr = driver["END_POINT_ADDR"].stringValue
            let startAddr = driver["STA_POINT_ADDR"].stringValue
            let workStartTime = driver["WORK_OUT_TIME"].stringValue
            let workEndTime = driver["WORK_STA_TIME"].stringValue
            var attachInfo = driver["USER_ATTACH_INFO"].stringValue
            if attachInfo.contains("no_profile") { attachInfo = "" }
            
            let driver = Driver()
            driver.name = name
            driver.endAddr = endAddr
            driver.startAddr = startAddr
            driver.imgUrl = attachInfo
            driver.workStartTime = workStartTime
            driver.workEndTime = workEndTime
            
            CarrySearch.newDrivers.append(driver)
        }

        MyLog.log("\(requestTitle) success")
        CarryEvents.shared.callSignInSuccess()
        completion?(true, "")
    }
    
    // MARK:- 배너
    func bindingBanner(json: JSON, completion: ResponseString = nil) {
        // -------------------------- Request -------------------------- //
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      LINK_URL                링크 주소
        //      BANNER_ATTACH_INFO      배너 사진 정보
        //      BOARD_TITLE             배너 제목(간단 설명)
        //
        //      ATTACH_SEQ              (안쓰임)
        //      BOARD_SEQ               (안쓰임)
        //      BRD_ATTACH_GRP_SEQ      (안쓰임)
        //
        // ------------------------------------------------------------- //
        
        let requestTitle = "[배너]"
        let msg = json["resMsg"].stringValue
        
        guard json["resCd"].stringValue == "0000" else {
            MyLog.logWithArrow("\(requestTitle) failed", msg)
            completion?(false, msg)
            return
        }
        
        let arr = json["bannerList"].arrayValue
        for value in arr {
            let pageUrl = value["LINK_URL"].stringValue
            let imgUrl = value["BANNER_ATTACH_INFO"].stringValue
            let desc = value["BOARD_TITLE"].stringValue
            let bgHexColor = value["BACKGROUND_COLOR"].stringValue
            let banner = BannerData(pageUrl: pageUrl, imgUrl: imgUrl, desc: desc, bgHexColor: bgHexColor)
            CarryPublic.banners.append(banner)
        }
        
        MyLog.log("\(requestTitle) success")
        completion?(true, "")
    }
    
    // MARK:- 메인화면 운송사업자 상세 정보
    func bindingLocalDriverDetail(json: JSON, completion: ResponseString = nil) {
        
        // ---------------------------- json --------------------------- //
        //
        //      POSSIBLE_RATE           적재 가용비율
        //      USER_SEQ                사용자 시퀀스
        //      MASTER_SEQ              마스터 사용자 시퀀스
        //      USER_NAME               운송 사업자 명
        //      VECHILE_TYPE            운송 수단 코드
        //      VECHILE_TYPE_NAME       운송 수단 명
        //      PRO_PRICE               운송 비용
        //      ATTACH_INFO             운송 사용자 대표 사진
        //      CARRYING_ISSUE          비고(주가내용)
        //      WORK_STA_TIME           근무 시작시간
        //      WORK_OUT_TIME           근무 종료 시간
        //      REVIEW_POINT_AVG        평점
        //
        //      (getReviewList)         리뷰
        //      REVIEW_SEQ              리뷰 시퀀스
        //      REVIEW_POINT            리뷰 점수
        //      REVIEW_BODY             리뷰 내용
        //      REVIEW_DATE             리뷰 등록일
        //
        //      (getBoxList)            짐
        //      ORDER_SEQ               짐 시퀀스
        //      ITEM_KIND               짐 종류 코드
        //      ITEM_KIND_TXT           짐 종류 텍스트
        //      ITEM_QUANTITY           짐 종료 수량
        //
        // ------------------------------------------------------------- //
        
        
        let requestTitle = "[메인화면 운송사업자 상세 정보 요청]"
        let msg = json["resMsg"].stringValue
        
        guard json["resCd"].stringValue == "0000" else {
            MyLog.logWithArrow("\(requestTitle) failed", msg)
            completion?(false, msg)
            return
        }
        
        let driver = Driver()
        
        var possibleRate = json["getReserveDriverDetail"]["POSSIBLE_RATE"].intValue
        if possibleRate < 0 { possibleRate = 0 }
        
        let userSeq = json["getReserveDriverDetail"]["USER_SEQ"].stringValue
        let masterSeq = json["getReserveDriverDetail"]["MASTER_SEQ"].stringValue
        let userName = json["getReserveDriverDetail"]["USER_NAME"].stringValue
        let vehicleType = json["getReserveDriverDetail"]["VECHILE_TYPE"].stringValue
        let vehivleName = json["getReserveDriverDetail"]["VECHILE_TYPE_NAME"].stringValue
        let attach = json["getReserveDriverDetail"]["USER_ATTACH_INFO"].stringValue
        let pr = json["getReserveDriverDetail"]["CARRYING_ISSUE"].stringValue
        let workStartTime = json["getReserveDriverDetail"]["WORK_STA_TIME"].stringValue
        let workEndTime = json["getReserveDriverDetail"]["WORK_OUT_TIME"].stringValue
        let rating = json["getReserveDriverDetail"]["REVIEW_POINT_AVG"].floatValue
        
        driver.possibleRate = possibleRate
        driver.userSeq = userSeq
        driver.masterSeq = masterSeq
        driver.name = userName
        driver.vehicleType = vehicleType
        driver.vehicleTypeName = vehivleName
        driver.cost = 0
        driver.pr = pr
        driver.workStartTime = workStartTime
        driver.workEndTime = workEndTime
        driver.rating = rating
        driver.imgUrl = attach
        
        let imgUrl = self.getRequestUrl(body: driver.imgUrl)
        driver.img = _utils.getImageFromUrl(url: imgUrl)
        
        let reviewArr = json["getReviewList"].arrayValue
        for review in reviewArr {
            let content = review["REVIEW_BODY"].stringValue
            let rating = review["REVIEW_POINT"].floatValue
            let name = review["USER_NAME"].stringValue
            let seq = review["REVIEW_SEQ"].stringValue
            let date = review["REVIEW_DATE"].doubleValue
            let simpleReview = ReviewSimple(seq: seq, rating: rating, content: content, name: name, date: date)
            driver.reviews.append(simpleReview)
        }
        
        let luggageArr = json["getBoxList"].arrayValue
        
        for luggage in luggageArr {
            let luggageType = luggage["ITEM_KIND"].stringValue
            let luggageCount = luggage["ITEM_QUANTITY"].intValue
            switch luggageType {
            case LuggageType.mini.type:
                driver.mini = luggageCount
            case LuggageType.small.type:
                driver.small = luggageCount
            case LuggageType.normal.type:
                driver.normal = luggageCount
            case LuggageType.big.type:
                driver.big = luggageCount
            default:
                break
            }
            
        }
        
        CarrySearch.driver = driver
        
        MyLog.log("\(requestTitle) success")
        completion?(true, "")
    }
    
    // MARK:- 검색한 보관사업자 상세 정보
    func bindingStorageDetail(json: JSON, completion: ResponseString = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            사용자 시퀀스
        //      MASTER_SEQ          보관사업자 마스터 시퀀스
        //      SAVER_USER_SEQ      보관사업자 시퀀스
        //      SAVER_TYPE          결제 시간 - 날짜 종류 (24시간이 지나면 001 / 24시간이 지나지 않으면 002)
        //      SAVER_TIME          결제 시간 - 날짜 값 (24시간이 지나면 24시간 단위로 1일 전달 값은 1,2 / 24시간이 지나지 않으면 시간 단위로 8,11)
        //      S_TYPE              미니짐 갯수
        //      M_TYPE              작은짐 갯수
        //      L_TYPE              보통짐 갯수
        //      XL_TYPE             큰짐 갯수
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      (getReserveDriverDetail)
        //      POSSIBLE_RATE       적재 가용비율
        //      USER_SEQ            사용자 시퀀스
        //      MASTER_SEQ          마스터 사용자 시퀀스
        //      BIZ_NAME            보관 사업자 명
        //      COM_NM              보관 사업 종류
        //      REVIEW_POINT_AVG    평점
        //      CARRYING_ISSUE      소개글
        //
        //      (getReviewList)
        //      REVIEW_SEQ          평가 시퀀스
        //      REVIEW_POINT        평가 점수
        //      REVIEW_BODY         평가 내용
        //      REVIEW_DATE         평가 등록일
        //
        //      (basicPriceList)
        //      RATE_SEQ            기본 가격 시퀀스
        //      RATE_KIND           기본 가격 종류
        //      RATE_SECTION        기본 적용시간
        //      RATE_PRICE          기본 가격
        //
        //      (overPriceList)
        //      RATE_SEQ            할증 가격 시퀀스
        //      RATE_KIND           할증 가격 종류
        //      RATE_SECTION        할증 적용시간
        //      RATE_PRICE          할증 가격
        //
        //      (oneDayPriceList)
        //      RATE_SEQ            할증 가격 시퀀스
        //      RATE_KIND           할증 가격 종류
        //      RATE_SECTION        할증 적용시간
        //      RATE_PRICE          할증 가격
        //
        // ------------------------------------------------------------- //
        
        let requestTitle = "[검색한 보관사업자 상세 정보]"
        let msg = json["resMsg"].stringValue
        
        guard json["resCd"].stringValue == "0000" else {
            MyLog.logWithArrow("\(requestTitle) failed", msg)
            completion?(false, msg)
            return
        }
        
        let seq = json["getReserveDriverDetail"]["MASTER_SEQ"].stringValue
        let ratingAvg = json["getReserveDriverDetail"]["REVIEW_POINT_AVG"].floatValue
        let pr = json["getReserveDriverDetail"]["CARRYING_ISSUE"].stringValue
        
        guard let oper = CarrySearch.storages.filter({ $0.masterSeq == seq }).first else { completion?(false, "\(MyStrings.alertFailedToThisProviderInfo.rawValue). \(MyStrings.pleaseRetry.rawValue)"); return }
        oper.rating = ratingAvg
        oper.pr = pr
        
        /*
         REVIEW_SEQ          평가 시퀀스
         REVIEW_POINT        평가 점수
         REVIEW_BODY         평가 내용
         REVIEW_DATE         평가 등록일
         */
        
        CarrySearch.storage?.reviews.removeAll()
        CarrySearch.storage?.costInfo.defaults.removeAll()
        CarrySearch.storage?.costInfo.extras.removeAll()
        CarrySearch.storage?.costInfo.dayOvers.removeAll()
        CarrySearch.storage?.rating = ratingAvg
        CarrySearch.storage?.pr = pr
        
        let reviews = json["getReviewList"].arrayValue
        for review in reviews {
            let seq = review["REVIEW_SEQ"].stringValue
            let rating = review["REVIEW_POINT"].floatValue
            let content = review["REVIEW_BODY"].stringValue
            let name = review["USER_NAME"].stringValue
            let date = review["REVIEW_DATE"].doubleValue
            let reviewObj = ReviewSimple(seq: seq, rating: rating, content: content, name: name, date: date)
            CarrySearch.storage?.reviews.append(reviewObj)
        }
        
        let defaultCosts = json["basicPriceList"].arrayValue
        for value in defaultCosts {
            let storageCost = StorageCost()
            storageCost.price = value["RATE_USER_PRICE"].stringValue
            storageCost.section = value["RATE_USER_SECTION"].stringValue
            storageCost.type = value["RATE_KIND"].stringValue
            storageCost.seq = value["RATE_SEQ"].stringValue
            CarrySearch.storage?.costInfo.defaults.append(storageCost)
        }
        
        let extraCosts = json["overPriceList"].arrayValue
        for value in extraCosts {
            let storageCost = StorageCost()
            storageCost.price = value["RATE_USER_PRICE"].stringValue
            storageCost.section = value["RATE_USER_SECTION"].stringValue
            storageCost.type = value["RATE_KIND"].stringValue
            storageCost.seq = value["RATE_SEQ"].stringValue
            CarrySearch.storage?.costInfo.extras.append(storageCost)
        }
        
        let dayOverCosts = json["oneDayPriceList"].arrayValue
        for value in dayOverCosts {
            let storageCost = StorageCost()
            storageCost.price = value["RATE_USER_PRICE"].stringValue
            storageCost.section = value["RATE_USER_SECTION"].stringValue
            storageCost.type = value["RATE_KIND"].stringValue
            storageCost.seq = value["RATE_SEQ"].stringValue
            CarrySearch.storage?.costInfo.dayOvers.append(storageCost)
        }
        
        let storagePictures = json["getFileList"].arrayValue
        CarrySearch.storage?.imgUrls.removeAll()
        for value in storagePictures {
            let url = value["FILE_INFO"].stringValue
            CarrySearch.storage?.imgUrls.append(url)
        }
        
        MyLog.log("\(requestTitle) success")
        completion?(true, "")
    }
    
    // MARK:- 메인화면 보관사업자 상세 정보
    func bindingLocalStorageDetail(json: JSON, completion: ResponseString = nil) {
        
        // ---------------------------- json --------------------------- //
        //
        //      POSSIBLE_RATE           적재 가용비율
        //      USER_SEQ                사용자 시퀀스
        //      MASTER_SEQ              마스터 사용자 시퀀스
        //      BIZ_NAME                보관 사업자 명
        //      COM_NM                  보관 사업 종류
        //      REVIEW_POINT_AVG        평점
        //      CARRYING_ISSUE          소개글
        //
        //      (getReviewList)         리뷰
        //      REVIEW_SEQ              리뷰 시퀀스
        //      REVIEW_POINT            리뷰 점수
        //      REVIEW_BODY             리뷰 내용
        //      REVIEW_DATE             리뷰 등록일
        //
        //      (basicPriceList)        기본요금(1일 이내)
        //      RATE_SEQ                기본 가격 시퀀스
        //      RATE_KIND               기본 가격 종류
        //      RATE_USER_SECTION       기본 적용시간
        //      RATE_USER_PRICE         기본 가격
        //
        //      (overPriceList)         추가요금(1일 이내)
        //      RATE_SEQ                기본 가격 시퀀스
        //      RATE_KIND               기본 가격 종류
        //      RATE_USER_SECTION       기본 적용시간
        //      RATE_USER_PRICE         기본 가격
        //
        //      (oneDayPriceList)       추가요금(1일 이후)
        //      RATE_SEQ                기본 가격 시퀀스
        //      RATE_KIND               기본 가격 종류
        //      RATE_USER_SECTION       기본 적용시간
        //      RATE_USER_PRICE         기본 가격
        //
        // ------------------------------------------------------------- //
        
        
        let requestTitle = "[메인화면 보관사업자 상세 정보 요청]"
        let msg = json["resMsg"].stringValue
        
        guard json["resCd"].stringValue == "0000" else {
            MyLog.logWithArrow("\(requestTitle) failed", msg)
            completion?(false, msg)
            return
        }
        
        let storage = Storage()
        
        let possibleRate = json["getReserveSaverDetail"]["POSSIBLE_RATE"].intValue
        let userSeq = json["getReserveSaverDetail"]["USER_SEQ"].stringValue
        let masterSeq = json["getReserveSaverDetail"]["MASTER_SEQ"].stringValue
        let userName = json["getReserveSaverDetail"]["BIZ_NAME"].stringValue
        let category = json["getReserveSaverDetail"]["COM_NM"].stringValue
        let pr = json["getReserveSaverDetail"]["CARRYING_ISSUE"].stringValue
        let rating = json["getReserveSaverDetail"]["REVIEW_POINT_AVG"].floatValue
        let address = json["getReserveSaverDetail"]["BIZ_SIMPLE_ADDR"].stringValue
        let addressDetail = json["getReserveSaverDetail"]["BIZ_DETAIL_ADDR"].stringValue
        var attach = json["getReserveSaverDetail"]["SAVER_ATTACH_INFO"].stringValue
        if attach.contains("no_profile") { attach = "" }
        
        let lat = json["getReserveSaverDetail"]["BIZ_LAT"].doubleValue
        let lng = json["getReserveSaverDetail"]["BIZ_LNG"].doubleValue
        let openTime = json["getReserveSaverDetail"]["WORK_STA_TIME"].stringValue
        let closeTime = json["getReserveSaverDetail"]["WORK_OUT_TIME"].stringValue
        
        
        storage.possibleRate = possibleRate
        storage.userSeq = userSeq
        storage.masterSeq = masterSeq
        storage.name = userName
        storage.pr = pr
        storage.category = category
        storage.rating = rating
        storage.imgUrl = attach
        storage.address = address
        storage.addressDetail = addressDetail
        storage.lat = lat
        storage.lng = lng
        storage.workEndTime = closeTime
        storage.workStartTime = openTime
        
        if false == storage.imgUrl.isEmpty {
            let imgUrl = self.getRequestUrl(body: storage.imgUrl)
            storage.img = _utils.getImageFromUrl(url: imgUrl)
        }
        
        let reviewArr = json["getReviewList"].arrayValue
        for review in reviewArr {
            
            let content = review["REVIEW_BODY"].stringValue
            let rating = review["REVIEW_POINT"].floatValue
            let seq = review["REVIEW_SEQ"].stringValue
            let name = review["USER_NAME"].stringValue
            let seconds = review["REVIEW_DATE"].doubleValue
//            let upperReviewSeq = review["UPPER_REVIEW_SEQ"].stringValue
            let simpleReview = ReviewSimple(seq: seq, rating: rating, content: content, name: name, date: seconds)
            
            storage.reviews.append(simpleReview)
            
            // 리뷰인지 댓글인지 구분함
//            if let upperReview = storage.reviews.filter({ $0.seq == upperReviewSeq }).first {
//                upperReview.setReply(reply: content)        // 댓글
//            } else {
                storage.reviews.append(simpleReview)         // 리뷰
//            }
        }
        
        let luggageArr = json["getBoxList"].arrayValue
        
        for luggage in luggageArr {
            let luggageType = luggage["ITEM_KIND"].stringValue
            let luggageCount = luggage["ITEM_QUANTITY"].intValue
            switch luggageType {
            case LuggageType.mini.type:
                storage.mini = luggageCount
            case LuggageType.small.type:
                storage.small = luggageCount
            case LuggageType.normal.type:
                storage.normal = luggageCount
            case LuggageType.big.type:
                storage.big = luggageCount
            default:
                break
            }
        }
        
        let defaultCosts = json["basicPriceList"].arrayValue
        for value in defaultCosts {
            let storageCost = StorageCost()
            storageCost.price = value["RATE_USER_PRICE"].stringValue
            storageCost.section = value["RATE_USER_SECTION"].stringValue
            storageCost.type = value["RATE_KIND"].stringValue
            storageCost.seq = value["RATE_SEQ"].stringValue
            storage.costInfo.defaults.append(storageCost)
        }
        
        let extraCosts = json["overPriceList"].arrayValue
        for value in extraCosts {
            let storageCost = StorageCost()
            storageCost.price = value["RATE_USER_PRICE"].stringValue
            storageCost.section = value["RATE_USER_SECTION"].stringValue
            storageCost.type = value["RATE_KIND"].stringValue
            storageCost.seq = value["RATE_SEQ"].stringValue
            storage.costInfo.extras.append(storageCost)
        }
        
        let dayOverCosts = json["oneDayPriceList"].arrayValue
        for value in dayOverCosts {
            let storageCost = StorageCost()
            storageCost.price = value["RATE_USER_PRICE"].stringValue
            storageCost.section = value["RATE_USER_SECTION"].stringValue
            storageCost.type = value["RATE_KIND"].stringValue
            storageCost.seq = value["RATE_SEQ"].stringValue
            storage.costInfo.dayOvers.append(storageCost)
        }
        
        CarrySearch.storage = storage
        
        MyLog.log("\(requestTitle) success")
        completion?(true, "")
    }
    
    // MARK:- 운송사업자 상세 정보
    func bindingDriverDetail(json: JSON, completion: ResponseString = nil) {
        // -------------------------- Request -------------------------- //
        //      USER_SEQ            사용자 시퀀스
        //      DEAL_SEQ
        //      DRIVER_USER_SEQ     운송사업자 시퀀스
        //      DEAL_SEQ            딜 시퀀스
        //      START_LNG           맡기는곳 경도
        //      START_LAT           맡기는곳 위도
        //      END_LNG             찾는곳 경도
        //      END_LAT             찾는곳 위도
        //      S_TYPE              미니짐 갯수
        //      M_TYPE              작은짐 갯수
        //      L_TYPE              보통짐 갯수
        //      XL_TYPE             큰짐 갯수
        //      POSSIBLE_RATE       적재 가용비율
        //      USER_SEQ            사용자 시퀀스
        //      MASTER_SEQ          마스터 사용자 시퀀스
        //      USER_NAME           운송 사업자 명
        //      VECHILE_TYPE        운송 수단 코드
        //      VECHILE_TYPE_NAME   운송 수단 명
        //      PRO_PRICE           운송 비용
        //      ATTACH_INFO         운송 사용자 대표 사진
        //      CARRYING_ISSUE      비고(주가내용)
        //      WORK_STA_TIME       근무 시작시간
        //      WORK_OUT_TIME       근무 종료 시간
        //      REVIEW_POINT_AVG    평점
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response -------------------------- //
        //      getReviewList
        //      REVIEW_SEQ          평가 시퀀스
        //      REVIEW_POINT        평가 점수
        //      REVIEW_BODY         평가 내용
        //      REVIEW_DATE         평가 등록일
        //
        //      getBoxList
        //      ORDER_SEQ           짐 시퀀스       1,001, 미니짐,5
        //      ITEM_KIND           짐 종류 코드     2.003, 보통짐,2
        //      ITEM_KIND_TXT       짐 종류 텍스트
        //      ITEM_QUANTITY       짐 종료 수량
        // -------------------------------------------------------------- //
        
        let requestTitle = "[운송사업자 상세 정보 요청]"
        let msg = json["resMsg"].stringValue
        
        guard json["resCd"].stringValue == "0000" else {
            MyLog.logWithArrow("\(requestTitle) failed", msg)
            completion?(false, msg)
            return
        }
        
        let oper = CarrySearch.driver
        let detail = json["getReserveDriverDetail"]
        
        // 근무 시간
        oper?.workStartTime = detail["WORK_STA_TIME"].stringValue
        oper?.workEndTime = detail["WORK_OUT_TIME"].stringValue
        
        // 평점
        oper?.rating = detail["REVIEW_POINT_AVG"].floatValue
        
        // 소개
        oper?.pr = detail["CARRYING_ISSUE"].stringValue
        
        // 이미지
        var imgUrl = detail["ATTACH_INFO"].stringValue
        if imgUrl.isEmpty { imgUrl = detail["USER_ATTACH_INFO"].stringValue }
        oper?.img = _utils.getImageFromUrl(url: self.getRequestUrl(body: imgUrl))
        
        // 운송 수단
        let vehicleType = detail["VECHILE_TYPE"].stringValue
        oper?.vehicleType = vehicleType
        
        // 가격
        let cost = detail["PRO_PRICE"].intValue
        oper?.cost = cost
        
        // 짐 정보
        if let luggages = json["getBoxList"].array {
            for luggage in luggages {
                let itemType = luggage["ITEM_KIND"].stringValue
                switch itemType {
                case LuggageType.mini.type:
                    oper?.mini = luggage["ITEM_QUANTITY"].intValue
                case LuggageType.small.type:
                    oper?.small = luggage["ITEM_QUANTITY"].intValue
                case LuggageType.normal.type:
                    oper?.normal = luggage["ITEM_QUANTITY"].intValue
                case LuggageType.big.type:
                    oper?.big = luggage["ITEM_QUANTITY"].intValue
                default:
                    break
                }
            }
        }
        
        // 리뷰
        if let reviews = json["getReviewList"].array {
            oper?.reviews.removeAll()
            for review in reviews {
                let content = review["REVIEW_BODY"].stringValue
                let rating = review["REVIEW_POINT"].floatValue
                let seq = review["REVIEW_SEQ"].stringValue
                let name = review["USER_NAME"].stringValue
                let date = review["REVIEW_DATE"].doubleValue
                //                                let upperReviewSeq = review["UPPER_REVIEW_SEQ"].stringValue
                let reviewObj = ReviewSimple(seq: seq, rating: rating, content: content, name: name, date: date)
                
                // 리뷰인지 댓글인지 구분함
                //                                if let upperReview = oper?.reviews.filter({ $0.seq == upperReviewSeq }).first {
                //                                    upperReview.setReply(reply: content)        // 댓글
                //                                } else {
                oper?.reviews.append(reviewObj)             // 리뷰
                //                                }
            }
        }
        
        let driverPictures = json["getFileList"].arrayValue
        oper?.imgUrls.removeAll()
        for value in driverPictures {
            let imgUrl = value["FILE_INFO"].stringValue
            oper?.imgUrls.append(imgUrl)
        }
        
        MyLog.log("\(requestTitle) success")
        completion?(true, "")
    }
    
    // MARK:- 약관
    func bindingTerms(type: TermType, json: JSON, completion: ResponseString = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      board_seq               약관 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        // ---------------------------- json --------------------------- //
        //
        //      BOARD_SEQ               이용약관 시퀀스
        //      BOARD_TITLE             이용약관 제목
        //      BOARD_MEMO              이용약관 내용
        //
        // ------------------------------------------------------------- //
        
        let requestTitle = "[약관 요청]"
        let msg = json["resMsg"].stringValue
        
        guard json["resCd"].stringValue == "0000" else {
            MyLog.logWithArrow("\(requestTitle) failed", msg)
            completion?(false, msg)
            return
        }
        
        var renewals = [(String, String)]()
        let content = json["termsItem"]["BOARD_MEMO"].stringValue
        let arr = json["termsOptList"].arrayValue
        for value in arr {
            let renewal: (String, String)
            renewal.0 = value["BOARD_SEQ"].stringValue
            renewal.1 = value["BOARD_TITLE"].stringValue
            
            renewals.append(renewal)
        }
        
        let term = CarryTerm(type: type, content: content, renewals: renewals)
        
        switch type {
        case .use:
            CarryUser.myTerms.use = nil
            CarryUser.myTerms.use = term
        case .info:
            CarryUser.myTerms.info = nil
            CarryUser.myTerms.info = term
        case .marketting:
            CarryUser.myTerms.marketting = nil
            CarryUser.myTerms.marketting = term
        default: break
        }
        
        MyLog.log("\(requestTitle) success")
        completion?(true, "")
    }
    
    // MARK:- 대기중인 의뢰
    func bindingMyRequestList (json: JSON, completion: ResponseString = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_BUYER_SEQ          리뷰 작성하는 사용자 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [gerReserveDriverList]
        //      DEAL_SEQ                요청 시퀀스
        //      DEAL_KIND_TXT           요청 타이틀
        //      DEAL_KIND               요청 코드
        //      PLAY_DATE               의뢰 기간
        //      ENTRUST_DATE            맡기는 시간
        //      ENTRUST_LAT             맡기는 좌표의 위도
        //      ENTRUST_LNG             맡기는 좌표의 경도
        //      TAKE_DATE               찾는 시간
        //      TAKE_LAT                찾는 좌표의 위도
        //      TAKE_LNG                찾는 좌표의 경도
        //      USER_SEQ                안쓰임..
        //
        // ------------------------------------------------------------- //
        
        let requestTitle = "[대기중인 의뢰]"
        let msg = json["resMsg"].stringValue
        
        guard json["resCd"].stringValue == "0000" else {
            MyLog.logWithArrow("\(requestTitle) failed", msg)
            completion?(false, msg)
            return
        }
        
        let arr = json["gerReserveDriverList"].arrayValue
        if arr.count > 0 { CarryDatas.shared.user.myRequets.removeAll() }
        
        for value in arr {
            let dealSeq = value["DEAL_SEQ"].stringValue
            let requestTypeName = value["DEAL_KIND_TXT"].stringValue
            let requestType = value["DEAL_KIND"].stringValue
            let dueDate = value["PLAY_DATE"].stringValue
            let startDate = value["ENTRUST_DATE"].doubleValue
            let startLat = value["ENTRUST_LAT"].doubleValue
            let startLng = value["ENTRUST_LNG"].doubleValue
            let endDate = value["TAKE_DATE"].doubleValue
            let endLat = value["TAKE_LAT"].doubleValue
            let endLng = value["TAKE_LNG"].doubleValue
            let orderType = value["BUSINESS_TYPE"].stringValue
            let requestComment = value["BUYER_MEMO"].stringValue
            let startAddr = value["ENTRUST_ADDR"].stringValue
            let endAddr = value["TAKE_ADDR"].stringValue
            let attachGrpSeq = value["ATTACH_GRP_SEQ"].stringValue
            
            var startBaseSeq = value["ENTRUST_BASE_SEQ"].stringValue
            if startBaseSeq == "0" { startBaseSeq = ""}
            
            var endBaseSeq = value["TAKE_BASE_SEQ"].stringValue
            if endBaseSeq == "0" { endBaseSeq = ""}
            
            let myRequest = MyRequest(dueDate: dueDate, requestType: requestType, requestTypeName: requestTypeName, dealSeq: dealSeq, startDate: startDate, startLat: startLat, startLng: startLng, endDate: endDate, endLat: endLat, endLng: endLng, requestComment: requestComment, orderType: orderType, startBaseSeq: startBaseSeq, endBaseSeq: endBaseSeq, startAddr: startAddr, endAddr: endAddr, attachGrpSeq: attachGrpSeq)
            
            let luggages = value["getBoxList"].arrayValue
            for luggage in luggages {
                let type = luggage["ITEM_KIND"].stringValue
                let quantity = luggage["ITEM_QUANTITY"].intValue
                switch type {
                case LuggageType.mini.type      : myRequest.sCount = quantity
                case LuggageType.small.type     : myRequest.mCount = quantity
                case LuggageType.normal.type    : myRequest.lCount = quantity
                case LuggageType.big.type       : myRequest.xlCount = quantity
                default: break
                }
            }
            
            CarryUser.myRequets.append(myRequest)
        }
        
        MyLog.log("\(requestTitle) success")
        completion?(true, "")
    }
    
    // MARK:- 회원 탈퇴
    func bindingWithDrawal(json: JSON, completion: ResponseString = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_ID             유저 ID
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        // ------------------------------------------------------------- //
        
        let requestTitle = "[탈퇴 요청]"
        let msg = json["resMsg"].stringValue
        
        guard json["resCd"].stringValue == "0000" else {
            MyLog.logWithArrow("\(requestTitle) failed", msg)
            completion?(false, msg)
            return
        }
        
        CarryDatas.shared.user.removeData()
        CarryEvents.shared.callSignOutSuccess()
        
        MyLog.log("\(requestTitle) success")
        completion?(true, "")
    }

    // MARK:- 환불 정보 조회
    func bindingRefundInfo(json: JSON, completion: ResponseString = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      ORDER_SEQ           주문 시퀀스
        //      USER_SEQ_BUYER      유저 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      PAY_APPNUM          아임포트 결제 시퀀스
        //      CANCEL_PRICE        환불 결정 금액
        //      CANCEL_PERCENT      환불 결정 퍼센트
        //      ORDER_KIND          결제 종류
        //      PAYMENT_TYPE        결제 타입
        //      REFUND_STATUS       환불 가능 여부
        //      BUY_DAY
        //      DIFF_DAY
        //      ENTRUST_DATE
        //      ORDER_DATE
        //      ORDER_STATUS
        //      TOTAL_AMOUNT
        //      TOTAL_AMOUNT_TXT
        //      PAY_APPNUM
        //
        // ------------------------------------------------------------- //
        
        let requestTitle = "[환불 정보 조회]"
        let msg = json["resMsg"].stringValue
        
        guard json["resCd"].stringValue == "0000" else {
            MyLog.logWithArrow("\(requestTitle) failed", msg)
            completion?(false, msg)
            return
        }
        
        let value = json["refundInfo"]
        let iamportOrderSeq = value["PAY_APPNUM"].stringValue
        let refundAmount = value["CANCEL_PRICE"].stringValue
        let refuncPercent = value["CANCEL_PERCENT"].stringValue
        let refundPossible = value["REFUND_STATUS"].stringValue
        let requestDate = value["ORDER_DATE"].stringValue
        let serviceDate = value["ENTRUST_DATE"].stringValue
        let serviceCost = value["TOTAL_AMOUNT_TXT"].stringValue
        let orderKind = value["ORDER_KIND"].stringValue
        let paymentType = value["PAYMENT_TYPE"].stringValue
        
        CarryUser.refund.setData(iamportOrderSeq: iamportOrderSeq, refundAmount: refundAmount, refundPercent: refuncPercent, refundPossible: refundPossible, requestDate: requestDate, serviceDate: serviceDate, serviceCost: serviceCost, orderKind: orderKind, paymentType: paymentType)
        
        MyLog.log("\(requestTitle) success")
        completion?(true, "")
    }

    // MARK:- 프로필 사진 조회
    func bindingProfilePicture(json: JSON, completion: ResponseString = nil) {
        
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                사용자 시퀀스
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      USER_ATTACH_INFO        프로필 사진
        //      ATTACH_GRP_SEQ          프로필 사진 시퀀스
        //
        //------------------------------------------------------------- //
        
        let requestTitle = "[프로필 사진 조회]"
        let msg = json["resMsg"].stringValue
        
        guard json["resCd"].stringValue == "0000" else {
            MyLog.logWithArrow("\(requestTitle) failed", msg)
            completion?(false, msg)
            return
        }
        
        var pictureUrl = json["USER_ATTACH_INFO"].stringValue
        let pictureSeq = json["ATTACH_GRP_SEQ"].stringValue
        
        if pictureUrl.contains("no_profileImg") { pictureUrl = "" }
        CarryUser.profilePicture.url = pictureUrl
        CarryUser.profilePicture.seq = pictureSeq
        
        MyLog.log("\(requestTitle) success")
        completion?(true, "")
    }
    
    
    // MARK:- 공항 목록 조회
    func bindingAirport(json: JSON, completion: ResponseString = nil) {
        
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                사용자 시퀀스
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      USER_ATTACH_INFO        프로필 사진
        //      ATTACH_GRP_SEQ          프로필 사진 시퀀스
        //
        //------------------------------------------------------------- //
        
        let requestTitle = "[공항 목록 조회]"
        let msg = json["resMsg"].stringValue
        
        guard json["resCd"].stringValue == "0000" else {
            MyLog.logWithArrow("\(requestTitle) failed", msg)
            completion?(false, msg)
            return
        }
        
        CarryUser.airports.removeAll()
        let arr = json["airportList"].arrayValue
        
        for val in arr {
            let code = val["CD_CATEGORY"].stringValue
            let name = val["CATEGORY_NM"].stringValue
            let lng = val["CATEGORY_LNG"].doubleValue
            let lat = val["CATEGORY_LAT"].doubleValue
            let airport = AirportData(lat: lat, lng: lng, name: name, code: code)
            CarryUser.airports.append(airport)
        }
        
        MyLog.log("\(requestTitle) success")
        completion?(true, "")
    }
}
*/
