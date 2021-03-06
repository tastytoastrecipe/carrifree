//
//  BilldocVm.swift
//  Carrifree
//
//  Created by orca on 2022/03/26.
//  Copyright Β© 2022 plattics. All rights reserved.
//
//
//  π¬ StorageBillVm
//  μ¬μ© λ΄μ­ 'μμΈ' νλ©΄ View Model
//

import Foundation

class BilldocVm {
    let maxPictureCount: Int = 10
    
    var data: StorageBillDocData!
    private var impSeq: String = ""         // νλΆ μμ²­μ νμν μμν¬νΈ κ²°μ  μνμ€
    private var usingStorage = ""           // νλΆ μμ²­μ νμν λ³΄κ΄μ μ¬μ© μ ν (UsingStorageCase)
    
    func setDummyDatas() {
        data = StorageBillDocData(orderNo: "20000000001")
        data.setOrderCase(orderCase: OrderCase.storage.rawValue)
        data.setOrderStatus(orderStatus: OrderStatus.reserved.rawValue)
        data.setBizName(bizName: "μ§νκ²ν° μλ¦¬μ¬")
        data.setAddress(address: "μμΈ μ©μ°κ΅¬ μ΄μ΄λ‘75κΈΈ 10-3")
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
        data.setComment(comment: "γ2")
        data.setCost(cost: 13000)
        
    }
    
    // MARK: - μ£Όλ¬Έ μμΈλ΄μ­ μ‘°ν
    /// μ£Όλ¬Έ μμΈλ΄μ­ μ‘°ν
    func getBilldoc(orderSeq: String, completion: ResponseString = nil) {
        _cas.bills.getBilldoc(orderSeq: orderSeq) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "μ£Όλ¬Έ λ΄μ­μ λΆλ¬μ€μ§ λͺ»νμ΅λλ€.", json: json))
                return
            }
            
            //      (orderDetail)
            //      S_TYPE                  <Number>        μμμ§
            //      ORDER_DATE              <String>        μμ²­μκ°
            //      WORK_STA_TIME           <String>        μ΄μμκ°(μμ)
            //      WORK_OUT_TIME           <String>        μ΄μμκ°(μ’λ£)
            //      CD_BIZ_TYPE             <String>        μμ’μ½λ
            //      TAKE_DATE               <String>        λ³΄κ΄μ’λ£
            //      M_TYPE                  <Number>        μ€κ°μ§
            //      BIZ_NAME                <String>        μνΈλͺ
            //      ENTRUST_DATE            <String>        λ³΄κ΄μμ
            //      XL_TYPE                 <Number>        λνμ§
            //      DELIVERY_NO             <String>        μ£Όλ¬Έλ²νΈ
            //      ORDER_SEQ               <Number>        μ£Όλ¬Έ λ²νΈ μνμ€
            //      BIZ_SIMPLE_ADDR         <String>        λ³΄κ΄μ κ°λ¨ μ£Όμ
            //      TOTAL_AMOUNT            <Number>        κ²°μ  κΈμ‘
            //      L_TYPE                  <Number>        ν°μ§
            //      USER_SEQ                <Number>        λ³΄κ΄μ¬μμ μ¬μ©μ μνμ€
            //      BIZ_LAT                 <String>        λ³΄κ΄μ μμΉ (μλ)
            //      BIZ_LNG                 <String>        λ³΄κ΄μ μμΉ (κ²½λ)
            //      ORDER_STATUS            <String>        μ£Όλ¬Έ μν (OrderStatus)
            //      ORDER_KIND              <String>        μ£Όλ¬Έ μ’λ₯ (OrderCase)
            //      ORDER_ATTACH_GRP_SEQ    <Number>        μ²¨λΆνμΌ κ·Έλ£Έ μνμ€
            
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
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "μ£Όλ¬Έ μ·¨μλ₯Ό μλ£νμ§ λͺ»νμ΅λλ€.", json: json))
                return
            }
            
            //      (refundInfo)
            //      PAY_APPNUM              μμν¬νΈ κ²°μ  μνμ€
            //      CANCEL_PRICE            νλΆ κ²°μ  κΈμ‘
            //      CANCEL_PERCENT          νλΆ κ²°μ  νΌμΌνΈ
            //      ORDER_KIND              κ²°μ  μ’λ₯
            //      PAYMENT_TYPE            κ²°μ  νμ
            //      REFUND_STATUS           νλΆ κ°λ₯ μ¬λΆ
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
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "μ£Όλ¬Έ μ·¨μλ₯Ό μλ£νμ§ λͺ»νμ΅λλ€.\n(impSeq is empty)", json: json))
            } else {
                completion?(true, "")
            }
        }
    }
    
    /// μ£Όλ¬Έ μ·¨μ(νλΆ)
    private func cancel(completion: ResponseString = nil) {
        let orderCase = OrderCase(rawValue: data.orderCase)?.type ?? ""
        if orderCase.isEmpty == true { completion?(false, "μ£Όλ¬Έ μ·¨μλ₯Ό μλ£νμ§ λͺ»νμ΅λλ€.\n(orderKind is empty)"); return }
        
        _cas.bills.cancel(orderSeq: data.orderSeq, impSeq: impSeq, cost: data.cost, orderCase: orderCase, usingStorage: usingStorage) { (success, json) in
            guard success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "μ£Όλ¬Έ μ·¨μλ₯Ό μλ£νμ§ λͺ»νμ΅λλ€.", json: json))
                return
            }
            
            completion?(true, "")
        }
    }
    
    /// μ£Όλ¬Έ μν λ³κ²½ 
    func changeOrderStatus(orderStatus: String, storageSeq: String, completion: ResponseString = nil) {
        _cas.bills.changeOrderStatus(orderSeq: data.orderSeq, orderStatus: orderStatus, storageSeq: storageSeq) { (success, json) in
            guard success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "μ£Όλ¬Έ μνλ₯Ό λ³κ²½νμ§ λͺ»νμ΅λλ€. λ€μ μλν΄μ£ΌμκΈ° λ°λλλ€.", json: json))
                return
            }
            self.data.setOrderStatus(orderStatus: orderStatus)
            completion?(true, "")
        }
    }
    
    /// μ¬λλ (μμΌ) μ‘°ν
    func getDayoff(completion: (() -> Void)? = nil) {
        _cas.general.getStorageCodes(all: false, userSeq: self.data.storageSeq, code: .weeks) { (codes) in
            for code in codes {
                let weekdayInt = Weekday.getWeekday(type: code.code).rawValue
                self.data.dayoff.append(weekdayInt)
            }
            
            completion?()
        }
    }
    
    /// μ§ μ¬μ§ μ‘°ν
    func getLuggagePictures(completion: ResponseString = nil) {
        _cas.bills.getLuggagePictures(orderSeq: data.orderSeq, attachType: AttachType.luggage.rawValue, attachGrpSeq: data.attachGrpSeq) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "μ§ μ¬μ§μ λΆλ¬μ€μ§ λͺ»νμ΅λλ€.", json: json))
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
