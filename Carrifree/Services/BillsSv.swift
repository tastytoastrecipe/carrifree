//
//  BillsSv.swift
//  Carrifree
//
//  Created by orca on 2022/03/25.
//  Copyright ยฉ 2022 plattics. All rights reserved.
//
//
//  ๐ฌ BillsSv
//  ๐ฌ ๊ฒฐ์  ๊ด๋ จ api ๋ชจ์
//

import Foundation
import Alamofire

class BillsSv: Service {
    
    var apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: - ์ฃผ๋ฌธ ๋ด์ญ์ด ์๋ ๋/์ ์กฐํ
    /// ์ฃผ๋ฌธ ๋ด์ญ์ด ์๋ ๋/์ ์กฐํ
    func getMonths(orderStatus: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ                ์ฌ์ฉ์ ์ํ์ค
        //      ORDER_STATUS            ์ฃผ๋ฌธ ์ํ
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [orderYearMonthList]
        //      ORDER_YEAR_MONTH        <String>        ์ฃผ๋ฌธ ๋์
        //      resCd                   <String>        ๊ฒฐ๊ณผ ์ฝ๋
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
    
    // MARK: - ์ฃผ๋ฌธ ๋ด์ญ ์กฐํ
    /// ์ฃผ๋ฌธ ๋ด์ญ ์กฐํ
    func getBills(month: String, orderStatus: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ_BUYER          ์ฌ์ฉ์ ์ํ์ค
        //      ORDER_YEAR_MONTH        ์ฃผ๋ฌธ ๋์
        //      ORDER_STATUS            ์ฃผ๋ฌธ ์ํ
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [orderInfoList]
        //      ORDER_YEAR_MONTH        <String>        ์ฃผ๋ฌธ ๋์
        //      BIZ_NAME                <String>        ๋ณด๊ด์ ์ด๋ฆ
        //      ORDER_DATE              <String>        ์ฃผ๋ฌธ๋ ์ง
        //      ENTRUST_BASE_SEQ        <Number>        ๋ณด๊ด์ ์ํ์ค
        //      DELIVERY_NO             <String>        ์ฃผ๋ฌธ ๋ฒํธ
        //      ORDER_SEQ               <Number>        ์ฃผ๋ฌธ ๋ฒํธ ์ํ์ค
        //      BIZ_SIMPLE_ADDR         <String>        ๋ณด๊ด์ ๊ฐ๋จ ์ฃผ์
        //      ORDER_STATUS            <String>        ์ฃผ๋ฌธ ์ํ
        //      ORDER_KIND              <String>        ์ฃผ๋ฌธ ์ข๋ฅ
        //      resCd                   <String>        ๊ฒฐ๊ณผ ์ฝ๋
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
    
    // MARK: - ์ฃผ๋ฌธ ์์ธ๋ด์ญ ์กฐํ
    /// ์ฃผ๋ฌธ ์์ธ๋ด์ญ ์กฐํ
    func getBilldoc(orderSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ_BUYER          ์ฌ์ฉ์ ์ํ์ค
        //      ORDER_SEQ               ์ฃผ๋ฌธ ์ํ์ค
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      (orderDetail)
        //      S_TYPE                  <Number>        ์์์ง
        //      ORDER_DATE              <String>        ์์ฒญ์๊ฐ
        //      WORK_STA_TIME           <String>        ์ด์์๊ฐ(์์)
        //      WORK_OUT_TIME           <String>        ์ด์์๊ฐ(์ข๋ฃ)
        //      CD_BIZ_TYPE             <String>        ์์ข์ฝ๋
        //      TAKE_DATE               <String>        ๋ณด๊ด์ข๋ฃ
        //      M_TYPE                  <Number>        ์ค๊ฐ์ง
        //      BIZ_NAME                <String>        ์ํธ๋ช
        //      ENTRUST_DATE            <String>        ๋ณด๊ด์์
        //      XL_TYPE                 <Number>        ๋ํ์ง
        //      DELIVERY_NO             <String>        ์ฃผ๋ฌธ๋ฒํธ
        //      ORDER_SEQ               <Number>        ์ฃผ๋ฌธ ๋ฒํธ ์ํ์ค
        //      BIZ_SIMPLE_ADDR         <String>        ๋ณด๊ด์ ๊ฐ๋จ ์ฃผ์
        //      TOTAL_AMOUNT            <Number>        ๊ฒฐ์  ๊ธ์ก
        //      L_TYPE                  <Number>        ํฐ์ง
        //      USER_SEQ                <Number>        ๋ณด๊ด์ฌ์์ ์ฌ์ฉ์ ์ํ์ค
        //      BIZ_LAT                 <String>        ๋ณด๊ด์ ์์น (์๋)
        //      BIZ_LNG                 <String>        ๋ณด๊ด์ ์์น (๊ฒฝ๋)
        //      ORDER_STATUS            <String>        ์ฃผ๋ฌธ ์ํ (OrderStatus)
        //      ORDER_KIND              <String>        ์ฃผ๋ฌธ ์ข๋ฅ (OrderCase)
        //      ORDER_ATTACH_GRP_SEQ    <Number>        ์ฒจ๋ถํ์ผ ๊ทธ๋ฃธ ์ํ์ค
        //
        //      resCd                   <String>        ๊ฒฐ๊ณผ ์ฝ๋
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
    
    // MARK: - ์ฃผ๋ฌธ ์ทจ์ ์ ๋ณด ์กฐํ
    /// ์ฃผ๋ฌธ ์ทจ์ ์ ๋ณด ์กฐํ
    func getCancelInfo(orderSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      ORDER_SEQ               ๊ฒฐ์  ์ํ์ค
        //      USER_SEQ_BUYER          ์ฌ์ฉ์ ์ํ์ค
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      (refundInfo)
        //      PAY_APPNUM              ์์ํฌํธ ๊ฒฐ์  ์ํ์ค
        //      CANCEL_PRICE            ํ๋ถ ๊ฒฐ์  ๊ธ์ก
        //      CANCEL_PERCENT          ํ๋ถ ๊ฒฐ์  ํผ์ผํธ
        //      ORDER_KIND              ๊ฒฐ์  ์ข๋ฅ
        //      PAYMENT_TYPE            ๊ฒฐ์  ํ์
        //      REFUND_STATUS           ํ๋ถ ๊ฐ๋ฅ ์ฌ๋ถ
        //      resCd                   ๊ฒฐ๊ณผ ์ฝ๋
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

    // MARK: - ์ฃผ๋ฌธ ์ทจ์(ํ๋ถ)
    /// ์ฃผ๋ฌธ ์ทจ์(ํ๋ถ)
    func cancel(orderSeq: String, impSeq: String, cost: Int, orderCase: String, usingStorage: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      ORDER_SEQ               ๊ฒฐ์  ์ํ์ค
        //      USER_SEQ_BUYER          ์ฌ์ฉ์ ์ํ์ค
        //      PAY_APPNUM              ์์ํฌํธ ๊ฒฐ์  ์ํ์ค ('์ฃผ๋ฌธ ์ทจ์ ์ ๋ณด ์กฐํ'์์ ๋ฐ์)
        //      REFUND_AMOUNT           ํ๋ถ ๊ฒฐ์  ๊ธ์ก
        //      REFUND_PERCENT          ํ๋ถ ๊ฒฐ์  ํผ์ผํธ
        //      ORDER_KIND              ๊ฒฐ์  ์ข๋ฅ (OrderCase)
        //      PAYMENT_TYPE            ๊ฒฐ์  ํ์ (UsingStorageCase)
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      resCd                   ๊ฒฐ๊ณผ ์ฝ๋
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
    
    // MARK: - ์ฃผ๋ฌธ ์ํ ๋ณ๊ฒฝ
    /// ์ฃผ๋ฌธ ์ํ ๋ณ๊ฒฝ
    func changeOrderStatus(orderSeq: String, orderStatus: String, storageSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      ORDER_SEQ               ๊ฒฐ์  ์ํ์ค
        //      USER_SEQ_BUYER          ์ฌ์ฉ์ ์ํ์ค
        //      ORDER_STATUS            ์ฃผ๋ฌธ ์ํ
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      resCd                   ๊ฒฐ๊ณผ ์ฝ๋
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
    
    /// ์ง ์ฌ์ง ์กฐํ
    func getLuggagePictures(orderSeq: String, attachType: String, attachGrpSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      ORDER_SEQ               ๊ฒฐ์  ์ํ์ค
        //      ATTACH_TYPE             ํ์ผ ํ์
        //      ORDER_ATTACH_GRP_SEQ    ์ฒจ๋ถํ์ผ ๊ทธ๋ฃน ์ํ์ค
        //      ORDER_SEQ               ์ฃผ๋ฌธ ์ํ์ค
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [orderPicList]
        //      ORDER_ATTACH_SEQ        ์ฒจ๋ถ ํ์ผ ์ํ์ค
        //      ORDER_ATTACH_GRP_SEQ    ์ฒจ๋ถ ํ์ผ ๊ทธ๋ฃน ์ํ์ค
        //      ORDER_ATTACH_INFO       ์ง์ฌ์ง url
        //      resCd                   ๊ฒฐ๊ณผ ์ฝ๋
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
