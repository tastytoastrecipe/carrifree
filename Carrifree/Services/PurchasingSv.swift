//
//  StorageOrderSv.swift
//  Carrifree
//
//  Created by orca on 2022/03/23.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 PurchasingSv
//  💬 결제 관련 api 모음
//

import Foundation
import Alamofire

class PurchasingSv: Service {
    
    var apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    /// 결제 요청
    func requestPurchsing(data: PurchasingData, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      DRIVER_MASTER_SEQ       운송사업자 마스터 시퀀스, 보관사업자 마스터 시퀀스
        //      DRIVER_USER_SEQ         운송사업자 시퀀스 (보관 사업자일 경우 0 전달)
        //      SAVER_USER_SEQ          보관사업자 시퀀스
        //      USER_SEQ                사용자 시퀀스
        //      VECHILE_TYPE            운송수단 타입
        //      ORDER_KIND              주문 유형
        //      PAY_METHOD              주문방식
        //      ENTRUST_ADDR            맡기는곳 주소
        //      ENTRUST_DATE            맡기는 날짜
        //      TAKE_ADDR               찾는곳 주소
        //      TAKE_DATE               찾는곳 날짜
        //      START_TIME
        //      END_TIME
        //      BUYER_NAME              주문자 이름
        //      BUYER_PHONE             주문자 전화번호
        //      BUYER_MEMO              주문시 유의사항
        //      START_LNG               맡기는곳 경도
        //      START_LAT               맡기는곳 위도
        //      END_LNG                 찾는곳 경도
        //      END_LAT                 찾는곳 위도
        //      S_TYPE                  미니짐 갯수
        //      M_TYPE                  작은짐 갯수
        //      L_TYPE                  보통짐 갯수
        //      XL_TYPE                 큰짐 갯수
        //      fileList
        //      module
        //      ATTACH_TYPE
        //      DEAL_SEQ                요청 시퀀스 (가격요청일 경우에만 DEAL_SEQ를 전달하고 나머지 경우는 0으로 전달한다)
        //      DEAL_SEQ_ORDER          요청 시퀀스 (예약일때에만 0 전달, 가격요청/오늘운송일 경우 DEAL_SEQ 전달)
        //      PRO_COST                결제 금액
        //
        //      PAYMENT_TYPE            결제 타입
        //      ENTRUST_BASE_SEQ        맡기는 캐리어베이스 사업자 코드
        //      TAKE_BASE_SEQ           찾는 캐리어베이스 사업자 코드
        //      SAVER_TYPE              결제 주문 시간 종류(보관일 경우)
        //      SAVER_TIME              결제 주문 시간(보관일 경우)
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        var saverType = StorageDayType.dayIn.rawValue
        let storageTime = data.storageTime
        if storageTime >= 24 { saverType = StorageDayType.dayOver.rawValue }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "DRIVER_MASTER_SEQ": data.masterSeq,
            "DRIVER_USER_SEQ": data.storageSeq,
            "SAVER_USER_SEQ": data.storageSeq,
            "USER_SEQ": data.userSeq,
            "VECHILE_TYPE": data.vehicleType,
            "ORDER_KIND": data.orderKind,
            "PAY_METHOD": data.payMethod,
            "ENTRUST_ADDR": data.startAddr,
            "ENTRUST_DATE": data.startDate,
            "TAKE_ADDR": data.endAddr,
            "TAKE_DATE": data.endDate,
            "START_TIME": data.startTime,
            "END_TIME": data.endTime,
            "BUYER_NAME": data.userName,
            "BUYER_PHONE": data.userPhone,
            "BUYER_MEMO": data.comment,
            "START_LNG": data.startLat,
            "START_LAT": data.startLng,
            "END_LNG": data.endLat,
            "END_LAT": data.endLng,
            "S_TYPE": data.luggages.s,
            "M_TYPE": data.luggages.m,
            "L_TYPE": data.luggages.l,
            "XL_TYPE": data.luggages.xl,
            "DEAL_SEQ": "0",
            "DEAL_SEQ_ORDER": "0",
            "PRO_COST": data.cost,
            "PAYMENT_TYPE": data.usingStorage,
            "ENTRUST_BASE_SEQ": data.storageSeq,
            "TAKE_BASE_SEQ": data.storageSeq,
            "SAVER_TYPE": saverType,
            "SAVER_TIME": storageTime,
            "module": "3",
            "ATTACH_TYPE": AttachType.luggage.rawValue,
            "ATTACH_GRP_SEQ": data.attachGrpSeq
        ]
        
        let urlString = "/sys/payment/app/payMajorProcess.do"
        let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""      // 한글 encoding
        let url = getRequestUrl(body: encodedUrlString)
        apiManager.request(api: .requestPurchasing, url: url, headers: headers, parameters: param, completion: completion)
        
    }
    
    /// 결제 완료
    func finishPurchasing(data: PurchasingData, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            유저 시퀀스
        //      SAVER_USER_SEQ      보관사업자 시퀀스
        //      ORDER_KIND          주문 유형
        //      START_TIME          물건 맡기는 시간
        //      END_TIME            물건 찾는 시간
        //      SAVER_TIME          결제 주문 시간 (보관일 경우)
        //      SAVER_TYPE          결제 주문 시간 타입 (보관일 경우)
        //      DRIVER_USER_SEQ     결제 전문 번호?
        //      START_LNG           맡기는곳 경도
        //      START_LAT           맡기는곳 위도
        //      END_LNG             찾는곳 경도
        //      END_LAT             찾는곳 위도
        //      S_TYPE              미니짐 갯수
        //      M_TYPE              작은짐 갯수
        //      L_TYPE              보통짐 갯수
        //      XL_TYPE             큰짐 갯수
        //      ORDER_SEQ           상품 결제 금액
        //      imp_uid             아임포트 uid
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        var saverType = StorageDayType.dayIn.rawValue
        let storageTime = data.storageTime
        if storageTime >= 24 { saverType = StorageDayType.dayOver.rawValue }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ": data.userSeq,
            "DRIVER_USER_SEQ": data.storageSeq,
            "SAVER_USER_SEQ": data.storageSeq,
            "DEAL_SEQ": "0",
            "ORDER_KIND": data.orderKind,
            "SAVER_TIME": storageTime,
            "SAVER_TYPE": saverType,
            "ORDER_SEQ": data.orderSeq,
            "imp_uid": data.impUid,
            "START_TIME": data.startTime,
            "END_TIME": data.endTime,
            "START_LNG": data.startLat,
            "START_LAT": data.startLng,
            "END_LNG": data.endLat,
            "END_LAT": data.endLng,
            "S_TYPE": data.luggages.s,
            "M_TYPE": data.luggages.m,
            "L_TYPE": data.luggages.l,
            "XL_TYPE": data.luggages.xl
            ]
        
        let urlString = "/sys/payment/app/payFinishProcess.do"
        let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""      // 한글 encoding
        let url = getRequestUrl(body: encodedUrlString)
        apiManager.request(api: .requestPurchasing, url: url, headers: headers, parameters: param, completion: completion)
    }
}
