//
//  BilldocVm.swift
//  Carrifree
//
//  Created by orca on 2022/03/26.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 StorageBillVm
//  사용 내역 '상세' 화면 View Model
//

import Foundation

class BilldocVm {
    let maxPictureCount: Int = 10
    
    var data: StorageBillDocData!
    private var impSeq: String = ""         // 환불 요청시 필요한 아임포트 결제 시퀀스
    private var usingStorage = ""           // 환불 요청시 필요한 보관소 사용 유형 (UsingStorageCase)
    
    func setDummyDatas() {
        data = StorageBillDocData(orderNo: "20000000001")
        data.setOrderCase(orderCase: OrderCase.storage.rawValue)
        data.setOrderStatus(orderStatus: OrderStatus.reserved.rawValue)
        data.setBizName(bizName: "짜파게티 요리사")
        data.setAddress(address: "서울 용산구 이촌로75길 10-3")
        data.setOrderDate(orderDate: "2022-02-16 17:30")
        data.setCategory(category: StorageCategory.storage001.rawValue)
        data.setLat(lat: 37.520388)
        data.setLng(lng: 126.974350)
        data.setWorktime(worktime: "10:00 ~ 20:00")
        data.setDayoff(dayoff: [Weekday.sunday.rawValue, Weekday.monday.rawValue])
        data.setHoliday(holiday: true)
        data.setSchedule(schedule: Schedule(start: "2022-02-14  11:00", end: "2022-02-14  13:00"))
        data.setLuggages(luggages: Luggages(s: 0, m: 1, l: 2, xl:0))
        data.setImgUrls(imgUrls: ["https://t1.daumcdn.net/cfile/tistory/9940AE3C5A765A881A",
             "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTsKYp1Kav7T3nYgcQomfbBWQd9FY5CGSgJeNj4Ydy3inBOMu-TMn9dFR5EqBdOnaqYp6k&usqp=CAU",
             "https://recipe1.ezmember.co.kr/cache/recipe/2021/10/28/0240f6da1381ee94cad48102c63787281.jpg",
             "https://blog.kakaocdn.net/dn/cvUGS6/btqRAktUP6E/kA3jVyqW0Bvi29srdPRkw1/img.jpg",
             "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcREiEDDzAt0yGk5xFrgz3ztt66HbCmyKfgAcvQucGiS7u4rwposQVm_QFN6arv7It2b53k&usqp=CAU",
                                  ])
        data.setComment(comment: "ㅎ2")
        data.setCost(cost: 13000)
        
    }
    
    // MARK: - 주문 상세내역 조회
    /// 주문 상세내역 조회
    func getBilldoc(orderSeq: String, completion: ResponseString = nil) {
        _cas.bills.getBilldoc(orderSeq: orderSeq) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "주문 내역을 불러오지 못했습니다.", json: json))
                return
            }
            
            //      (orderDetail)
            //      S_TYPE                  <Number>        작은짐
            //      ORDER_DATE              <String>        요청시간
            //      WORK_STA_TIME           <String>        운영시간(시작)
            //      WORK_OUT_TIME           <String>        운영시간(종료)
            //      CD_BIZ_TYPE             <String>        업종코드
            //      TAKE_DATE               <String>        보관종료
            //      M_TYPE                  <Number>        중간짐
            //      BIZ_NAME                <String>        상호명
            //      ENTRUST_DATE            <String>        보관시작
            //      XL_TYPE                 <Number>        대형짐
            //      DELIVERY_NO             <String>        주문번호
            //      ORDER_SEQ               <Number>        주문 번호 시퀀스
            //      BIZ_SIMPLE_ADDR         <String>        보관소 간단 주소
            //      TOTAL_AMOUNT            <Number>        결제 금액
            //      L_TYPE                  <Number>        큰짐
            //      USER_SEQ                <Number>        보관사업자 사용자 시퀀스
            //      BIZ_LAT                 <String>        보관소 위치 (위도)
            //      BIZ_LNG                 <String>        보관소 위치 (경도)
            //      ORDER_STATUS            <String>        주문 상태 (OrderStatus)
            //      ORDER_KIND              <String>        주문 종류 (OrderCase)
            //      ORDER_ATTACH_GRP_SEQ    <Number>        첨부파일 그룸 시퀀스
            
            let val = json["orderDetail"]
            let s = val["S_TYPE"].intValue
            let m = val["M_TYPE"].intValue
            let l = val["L_TYPE"].intValue
            let xl = val["XL_TYPE"].intValue
            let orderDate = val["ORDER_DATE"].stringValue
            let open = val["WORK_STA_TIME"].stringValue
            let close = val["WORK_OUT_TIME"].stringValue
            let category = val["CD_BIZ_TYPE"].stringValue
            let endDate = val["TAKE_DATE"].stringValue
            let startDate = val["ENTRUST_DATE"].stringValue
            let bizName = val["BIZ_NAME"].stringValue
            let orderNo = val["DELIVERY_NO"].stringValue
            let orderSeq = val["ORDER_SEQ"].stringValue
            let address = val["BIZ_SIMPLE_ADDR"].stringValue
            let costStr = val["TOTAL_AMOUNT"].stringValue
            let storageSeq = val["USER_SEQ"].stringValue
            let lat = val["BIZ_LAT"].doubleValue
            let lng = val["BIZ_LNG"].doubleValue
            let orderStatus = val["ORDER_STATUS"].stringValue
            let orderCase = val["ORDER_KIND"].stringValue
            let attachGrpSeq = val["ORDER_ATTACH_GRP_SEQ"].stringValue
            
            let luggages = Luggages(s: s, m: m, l: l, xl: xl)
            let workTime = "\(open) ~ \(close)"
            let cost = _utils.getIntFromDelimiter(str: costStr)
            var data = StorageBillDocData(orderNo: orderNo)
            data.setStorageSeq(storageSeq: storageSeq)
            data.setOrderDate(orderDate: orderDate)
            data.setWorktime(worktime: workTime)
            data.setCategory(category: category)
            data.setSchedule(schedule: Schedule(start: startDate, end: endDate))
            data.setBizName(bizName: bizName)
            data.setOrderNo(orderNo: orderNo)
            data.setOrderSeq(orderSeq: orderSeq)
            data.setLuggages(luggages: luggages)
            data.setCost(cost: cost)
            data.setAddress(address: address)
            data.setOrderStatus(orderStatus: orderStatus)
            let orderCaseInt = OrderCase.getCase(type: orderCase).rawValue
            data.setOrderCase(orderCase: orderCaseInt)
            data.setLat(lat: lat)
            data.setLng(lng: lng)
            data.setOrderStatus(orderStatus: orderStatus)
            data.setOrderCase(orderCase: OrderCase.getCase(type: orderCase).rawValue )
            data.setAttachGrpSeq(attachGrpSeq: attachGrpSeq)
            
            self.data = data
            completion?(true, "")
        }
    }
    
    func requestCancel(completion: ResponseString = nil) {
        getCancelInfo() { (success, msg) in
            guard success else { completion?(false, msg); return }
            
            self.cancel() { (success, msg) in
                guard success else { completion?(false, msg); return }
                completion?(true, "")
            }
        }
    }
    
    private func getCancelInfo(completion: ResponseString = nil) {
        _cas.bills.getCancelInfo(orderSeq: data.orderSeq) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "주문 취소를 완료하지 못했습니다.", json: json))
                return
            }
            
            //      (refundInfo)
            //      PAY_APPNUM              아임포트 결제 시퀀스
            //      CANCEL_PRICE            환불 결정 금액
            //      CANCEL_PERCENT          환불 결정 퍼센트
            //      ORDER_KIND              결제 종류
            //      PAYMENT_TYPE            결제 타입
            //      REFUND_STATUS           환불 가능 여부
            let val = json["refundInfo"]
            let impSeq = val["PAY_APPNUM"].stringValue
            let usingStorage = val["PAYMENT_TYPE"].stringValue
            
            /*
            let costStr = val["CANCEL_PRICE"].stringValue
            let cost = _utils.getIntFromDelimiter(str: costStr)
            let per = val["CANCEL_PERCENT"].intValue
            let orderCase = val["ORDER_KIND"].stringValue
            let enableStr = val["REFUND_STATUS"].stringValue
            let enable = (enableStr == "Y")
            */
            
            self.impSeq = impSeq
            self.usingStorage = usingStorage
            if impSeq.isEmpty {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "주문 취소를 완료하지 못했습니다.\n(impSeq is empty)", json: json))
            } else {
                completion?(true, "")
            }
        }
    }
    
    /// 주문 취소(환불)
    private func cancel(completion: ResponseString = nil) {
        let orderCase = OrderCase(rawValue: data.orderCase)?.type ?? ""
        if orderCase.isEmpty == true { completion?(false, "주문 취소를 완료하지 못했습니다.\n(orderKind is empty)"); return }
        
        _cas.bills.cancel(orderSeq: data.orderSeq, impSeq: impSeq, cost: data.cost, orderCase: orderCase, usingStorage: usingStorage) { (success, json) in
            guard success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "주문 취소를 완료하지 못했습니다.", json: json))
                return
            }
            
            completion?(true, "")
        }
    }
    
    /// 주문 상태 변경 
    func changeOrderStatus(orderStatus: String, storageSeq: String, completion: ResponseString = nil) {
        _cas.bills.changeOrderStatus(orderSeq: data.orderSeq, orderStatus: orderStatus, storageSeq: storageSeq) { (success, json) in
            guard success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "주문 상태를 변경하지 못했습니다. 다시 시도해주시기 바랍니다.", json: json))
                return
            }
            self.data.setOrderStatus(orderStatus: orderStatus)
            completion?(true, "")
        }
    }
    
    /// 쉬는날(요일) 조회
    func getDayoff(completion: (() -> Void)? = nil) {
        _cas.general.getStorageCodes(all: false, userSeq: self.data.storageSeq, code: .weeks) { (codes) in
            for code in codes {
                let weekdayInt = Weekday.getWeekday(type: code.code).rawValue
                self.data.dayoff.append(weekdayInt)
            }
            
            completion?()
        }
    }
    
    /// 짐 사진 조회
    func getLuggagePictures(completion: ResponseString = nil) {
        _cas.bills.getLuggagePictures(orderSeq: data.orderSeq, attachType: AttachType.luggage.rawValue, attachGrpSeq: data.attachGrpSeq) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "짐 사진을 불러오지 못했습니다.", json: json))
                return
            }
            
            let arr = json["orderPicList"].arrayValue
            for val in arr {
                let imgUrl = val["ORDER_ATTACH_INFO"].stringValue
                self.data.imgUrls.append(imgUrl)
            }
            
            completion?(true, "")
        }
    }
}
