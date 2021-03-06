//
//  StorageOrderSv.swift
//  Carrifree
//
//  Created by orca on 2022/03/23.
//  Copyright ยฉ 2022 plattics. All rights reserved.
//
//
//  ๐ฌ PurchasingSv
//  ๐ฌ ๊ฒฐ์  ๊ด๋ จ api ๋ชจ์
//

import Foundation
import Alamofire

class PurchasingSv: Service {
    
    var apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    /// ๊ฒฐ์  ์์ฒญ
    func requestPurchsing(data: PurchasingData, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      DRIVER_MASTER_SEQ       ์ด์ก์ฌ์์ ๋ง์คํฐ ์ํ์ค, ๋ณด๊ด์ฌ์์ ๋ง์คํฐ ์ํ์ค
        //      DRIVER_USER_SEQ         ์ด์ก์ฌ์์ ์ํ์ค (๋ณด๊ด ์ฌ์์์ผ ๊ฒฝ์ฐ 0 ์ ๋ฌ)
        //      SAVER_USER_SEQ          ๋ณด๊ด์ฌ์์ ์ํ์ค
        //      USER_SEQ                ์ฌ์ฉ์ ์ํ์ค
        //      VECHILE_TYPE            ์ด์ก์๋จ ํ์
        //      ORDER_KIND              ์ฃผ๋ฌธ ์ ํ
        //      PAY_METHOD              ์ฃผ๋ฌธ๋ฐฉ์
        //      ENTRUST_ADDR            ๋งก๊ธฐ๋๊ณณ ์ฃผ์
        //      ENTRUST_DATE            ๋งก๊ธฐ๋ ๋ ์ง
        //      TAKE_ADDR               ์ฐพ๋๊ณณ ์ฃผ์
        //      TAKE_DATE               ์ฐพ๋๊ณณ ๋ ์ง
        //      START_TIME
        //      END_TIME
        //      BUYER_NAME              ์ฃผ๋ฌธ์ ์ด๋ฆ
        //      BUYER_PHONE             ์ฃผ๋ฌธ์ ์ ํ๋ฒํธ
        //      BUYER_MEMO              ์ฃผ๋ฌธ์ ์ ์์ฌํญ
        //      START_LNG               ๋งก๊ธฐ๋๊ณณ ๊ฒฝ๋
        //      START_LAT               ๋งก๊ธฐ๋๊ณณ ์๋
        //      END_LNG                 ์ฐพ๋๊ณณ ๊ฒฝ๋
        //      END_LAT                 ์ฐพ๋๊ณณ ์๋
        //      S_TYPE                  ๋ฏธ๋์ง ๊ฐฏ์
        //      M_TYPE                  ์์์ง ๊ฐฏ์
        //      L_TYPE                  ๋ณดํต์ง ๊ฐฏ์
        //      XL_TYPE                 ํฐ์ง ๊ฐฏ์
        //      fileList
        //      module
        //      ATTACH_TYPE
        //      DEAL_SEQ                ์์ฒญ ์ํ์ค (๊ฐ๊ฒฉ์์ฒญ์ผ ๊ฒฝ์ฐ์๋ง DEAL_SEQ๋ฅผ ์ ๋ฌํ๊ณ  ๋๋จธ์ง ๊ฒฝ์ฐ๋ 0์ผ๋ก ์ ๋ฌํ๋ค)
        //      DEAL_SEQ_ORDER          ์์ฒญ ์ํ์ค (์์ฝ์ผ๋์๋ง 0 ์ ๋ฌ, ๊ฐ๊ฒฉ์์ฒญ/์ค๋์ด์ก์ผ ๊ฒฝ์ฐ DEAL_SEQ ์ ๋ฌ)
        //      PRO_COST                ๊ฒฐ์  ๊ธ์ก
        //
        //      PAYMENT_TYPE            ๊ฒฐ์  ํ์
        //      ENTRUST_BASE_SEQ        ๋งก๊ธฐ๋ ์บ๋ฆฌ์ด๋ฒ ์ด์ค ์ฌ์์ ์ฝ๋
        //      TAKE_BASE_SEQ           ์ฐพ๋ ์บ๋ฆฌ์ด๋ฒ ์ด์ค ์ฌ์์ ์ฝ๋
        //      SAVER_TYPE              ๊ฒฐ์  ์ฃผ๋ฌธ ์๊ฐ ์ข๋ฅ(๋ณด๊ด์ผ ๊ฒฝ์ฐ)
        //      SAVER_TIME              ๊ฒฐ์  ์ฃผ๋ฌธ ์๊ฐ(๋ณด๊ด์ผ ๊ฒฝ์ฐ)
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
        let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""      // ํ๊ธ encoding
        let url = getRequestUrl(body: encodedUrlString)
        apiManager.request(api: .requestPurchasing, url: url, headers: headers, parameters: param, completion: completion)
        
    }
    
    /// ๊ฒฐ์  ์๋ฃ
    func finishPurchasing(data: PurchasingData, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            ์ ์  ์ํ์ค
        //      SAVER_USER_SEQ      ๋ณด๊ด์ฌ์์ ์ํ์ค
        //      ORDER_KIND          ์ฃผ๋ฌธ ์ ํ
        //      START_TIME          ๋ฌผ๊ฑด ๋งก๊ธฐ๋ ์๊ฐ
        //      END_TIME            ๋ฌผ๊ฑด ์ฐพ๋ ์๊ฐ
        //      SAVER_TIME          ๊ฒฐ์  ์ฃผ๋ฌธ ์๊ฐ (๋ณด๊ด์ผ ๊ฒฝ์ฐ)
        //      SAVER_TYPE          ๊ฒฐ์  ์ฃผ๋ฌธ ์๊ฐ ํ์ (๋ณด๊ด์ผ ๊ฒฝ์ฐ)
        //      DRIVER_USER_SEQ     ๊ฒฐ์  ์ ๋ฌธ ๋ฒํธ?
        //      START_LNG           ๋งก๊ธฐ๋๊ณณ ๊ฒฝ๋
        //      START_LAT           ๋งก๊ธฐ๋๊ณณ ์๋
        //      END_LNG             ์ฐพ๋๊ณณ ๊ฒฝ๋
        //      END_LAT             ์ฐพ๋๊ณณ ์๋
        //      S_TYPE              ๋ฏธ๋์ง ๊ฐฏ์
        //      M_TYPE              ์์์ง ๊ฐฏ์
        //      L_TYPE              ๋ณดํต์ง ๊ฐฏ์
        //      XL_TYPE             ํฐ์ง ๊ฐฏ์
        //      ORDER_SEQ           ์ํ ๊ฒฐ์  ๊ธ์ก
        //      imp_uid             ์์ํฌํธ uid
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
        let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""      // ํ๊ธ encoding
        let url = getRequestUrl(body: encodedUrlString)
        apiManager.request(api: .requestPurchasing, url: url, headers: headers, parameters: param, completion: completion)
    }
}
