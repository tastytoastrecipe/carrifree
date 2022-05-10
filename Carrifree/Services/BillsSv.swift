//
//  BillsSv.swift
//  Carrifree
//
//  Created by orca on 2022/03/25.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 BillsSv
//  💬 결제 관련 api 모음
//

import Foundation
import Alamofire

class BillsSv: Service {
    
    var apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: - 주문 내역이 있는 년/월 조회
    /// 주문 내역이 있는 년/월 조회
    func getMonths(orderStatus: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ                사용자 시퀀스
        //      ORDER_STATUS            주문 상태
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [orderYearMonthList]
        //      ORDER_YEAR_MONTH        <String>        주문 년월
        //      resCd                   <String>        결과 코드
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        var param: [String: String] = [
            "USER_SEQ_BUYER": _user.seq
        ]
        
        if false == orderStatus.isEmpty {
            param["ORDER_STATUS"] = orderStatus
        }
        
        let url = getRequestUrl(body: "/sys/payment/app/getOrderYearMonthList.do")
        apiManager.request(api: .getBills, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 주문 내역 조회
    /// 주문 내역 조회
    func getBills(month: String, orderStatus: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ_BUYER          사용자 시퀀스
        //      ORDER_YEAR_MONTH        주문 년월
        //      ORDER_STATUS            주문 상태
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [orderInfoList]
        //      ORDER_YEAR_MONTH        <String>        주문 년월
        //      BIZ_NAME                <String>        보관소 이름
        //      ORDER_DATE              <String>        주문날짜
        //      ENTRUST_BASE_SEQ        <Number>        보관소 시퀀스
        //      DELIVERY_NO             <String>        주문 번호
        //      ORDER_SEQ               <Number>        주문 번호 시퀀스
        //      BIZ_SIMPLE_ADDR         <String>        보관소 간단 주소
        //      ORDER_STATUS            <String>        주문 상태
        //      ORDER_KIND              <String>        주문 종류
        //      resCd                   <String>        결과 코드
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        var param: [String: String] = [
            "USER_SEQ_BUYER": _user.seq,
            "ORDER_YEAR_MONTH": month
        ]
        
        if false == orderStatus.isEmpty {
            param["ORDER_STATUS"] = orderStatus
        }
        
        let url = getRequestUrl(body: "/sys/payment/app/getOrderInfo.do")
        apiManager.request(api: .getBills, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 주문 상세내역 조회
    /// 주문 상세내역 조회
    func getBilldoc(orderSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ_BUYER          사용자 시퀀스
        //      ORDER_SEQ               주문 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
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
        //
        //      resCd                   <String>        결과 코드
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: [String: String] = [
            "USER_SEQ_BUYER": _user.seq,
            "ORDER_SEQ": orderSeq
        ]
        
        let url = getRequestUrl(body: "/sys/payment/app/getOrderDetail.do")
        apiManager.request(api: .getBillDoc, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 주문 취소 정보 조회
    /// 주문 취소 정보 조회
    func getCancelInfo(orderSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      ORDER_SEQ               결제 시퀀스
        //      USER_SEQ_BUYER          사용자 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      (refundInfo)
        //      PAY_APPNUM              아임포트 결제 시퀀스
        //      CANCEL_PRICE            환불 결정 금액
        //      CANCEL_PERCENT          환불 결정 퍼센트
        //      ORDER_KIND              결제 종류
        //      PAYMENT_TYPE            결제 타입
        //      REFUND_STATUS           환불 가능 여부
        //      resCd                   결과 코드
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: Parameters = [
            "USER_SEQ_BUYER": _user.seq,
            "ORDER_SEQ": orderSeq
        ]
        
        let url = getRequestUrl(body: "/sys/payment/app/refundForm.do")
        apiManager.request(api: .cancelOrder, url: url, headers: headers, parameters: param, completion: completion)
        
    }

    // MARK: - 주문 취소(환불)
    /// 주문 취소(환불)
    func cancel(orderSeq: String, impSeq: String, cost: Int, orderCase: String, usingStorage: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      ORDER_SEQ               결제 시퀀스
        //      USER_SEQ_BUYER          사용자 시퀀스
        //      PAY_APPNUM              아임포트 결제 시퀀스 ('주문 취소 정보 조회'에서 받음)
        //      REFUND_AMOUNT           환불 결정 금액
        //      REFUND_PERCENT          환불 결정 퍼센트
        //      ORDER_KIND              결제 종류 (OrderCase)
        //      PAYMENT_TYPE            결제 타입 (UsingStorageCase)
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      resCd                   결과 코드
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: Parameters = [
            "USER_SEQ_BUYER": _user.seq,
            "ORDER_SEQ": orderSeq,
            "PAY_APPNUM": impSeq,
            "REFUND_AMOUNT": cost,
            "REFUND_PERCENT": 100,
            "ORDER_KIND": orderCase,
            "PAYMENT_TYPE": usingStorage,
        ]
        
        let url = getRequestUrl(body: "/sys/payment/app/refundProcess.do")
        apiManager.request(api: .cancelOrder, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - 주문 상태 변경
    /// 주문 상태 변경
    func changeOrderStatus(orderSeq: String, orderStatus: String, storageSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      ORDER_SEQ               결제 시퀀스
        //      USER_SEQ_BUYER          사용자 시퀀스
        //      ORDER_STATUS            주문 상태
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      resCd                   결과 코드
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: Parameters = [
            "USER_SEQ_BUYER": _user.seq,
            "ORDER_SEQ": orderSeq,
            "ORDER_STATUS": orderStatus,
            "ENTRUST_BASE_SEQ": storageSeq
        ]
        
        let url = getRequestUrl(body: "/sys/payment/app/setChangePaymentProcess.do")
        apiManager.request(api: .changeOrderStatus, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    /// 짐 사진 조회
    func getLuggagePictures(orderSeq: String, attachType: String, attachGrpSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      ORDER_SEQ               결제 시퀀스
        //      ATTACH_TYPE             파일 타입
        //      ORDER_ATTACH_GRP_SEQ    첨부파일 그룹 시퀀스
        //      ORDER_SEQ               주문 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [orderPicList]
        //      ORDER_ATTACH_SEQ        첨부 파일 시퀀스
        //      ORDER_ATTACH_GRP_SEQ    첨부 파일 그룹 시퀀스
        //      ORDER_ATTACH_INFO       짐사진 url
        //      resCd                   결과 코드
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: Parameters = [
            "USER_SEQ_BUYER": _user.seq,
            "ATTACH_TYPE": attachType,
            "ORDER_ATTACH_GRP_SEQ": attachGrpSeq,
            "ORDER_SEQ": orderSeq
        ]
        
        let url = getRequestUrl(body: "/sys/payment/app/getOrderPicList.do")
        apiManager.request(api: .getLuggagePictures, url: url, headers: headers, parameters: param, completion: completion)
    }
}
