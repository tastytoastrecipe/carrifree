//
//  PurchasingDat.swift
//  Carrifree
//
//  Created by orca on 2022/03/23.
//  Copyright © 2022 plattics. All rights reserved.
//

import Foundation

struct PurchasingData {
    var masterSeq: String               // 운송사업자 마스터 시퀀스, 보관사업자 마스터 시퀀스
    var driverSeq: String               // 운송사업자 시퀀스 (보관 사업자일 경우 0 전달)
    var storageSeq: String              // 보관사업자 시퀀스
    var userSeq: String                 // 구매자(사용자) 시퀀스
    var vehicleType: String             // 운송수단 타입
    var orderKind: String               // 주문 유형
    var usingStorage: String            // 보관소 사용 유형
    var payMethod: String               // 주문 방식 (001: 카드)
    var startAddr: String               // 맡기는곳 주소
    var startDate: String               // 맡기는 날짜 (yyyy-MM-dd HH:mm:ss)
    var startTime: String               // 맡기는 시간 (HH:mm:ss)
    var endAddr: String                 // 찾는곳 주소
    var endDate: String                 // 찾는 날짜 (yyyy-MM-dd HH:mm:ss)
    var endTime: String                 // 찾는 시간 (HH:mm:ss)
    var userName: String                // 구매자 이름
    var userPhone: String               // 구매자 휴대폰 번호
    var comment: String                 // 요청사항
    var startLat: Double                // 맡기는곳 위도
    var startLng: Double                // 맡기는곳 경도
    var endLat: Double                  // 찾는곳 위도
    var endLng: Double                  // 찾는곳 경도
    var luggages: Luggages              // 짐 개수
    var luggagePictures: [Data]         // 짐 사진
    var cost: String                    // 요금
    
    var orderSeq: String = ""
    var impUid: String = ""
    var attachGrpSeq: String = ""
    var bizName: String = ""
    var orderNo: String = ""
    var careCost: String = ""           // 지원(할인) 요금
    
    // 보관 시간 타입
    var storageTimeType: String {
        get {
            let startTimeInterval = startDate.toDate()?.timeIntervalSince1970 ?? 0       // second
            let endTimeInterval = endDate.toDate()?.timeIntervalSince1970 ?? 0
            if startTimeInterval == 0 || endTimeInterval == 0 { return "" }
            
            let during = endTimeInterval - startTimeInterval
            let oneDaySecond: Double = 60 * 60 * 24     // 하루(second)
            var dayOverType = StorageDayType.dayIn      // 맡기는 시간 차이
            
            if during > oneDaySecond {
                dayOverType = StorageDayType.dayOver
            }
            
            return dayOverType.rawValue
        }
    }
    
    // 총 보관 시간
    var storageTime: Int {
        get {
            let time = _utils.getTimeIntervalInt(start: startDate.toDate(), end: endDate.toDate())
            return time
        }
    }
}

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
