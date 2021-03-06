//
//  StorageDetailSv.swift
//  Carrifree
//
//  Created by orca on 2022/03/20.
//  Copyright ยฉ 2022 plattics. All rights reserved.
//
//
//  ๐ฌ StorageDetailSv
//  ๐ฌ ๋ณด๊ด์ ์์ธ ์ ๋ณด api ๋ชจ์
//

import Foundation
import SwiftyJSON
import Alamofire

class StorageDetailSv: Service {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    /// ๋ณด๊ด์ ์์ธ ์ ๋ณด ์กฐํ
    func getStorageInfo(storageSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ                ์ฌ์ฉ์ ์ํ์ค
        //      BIZ_USER_SEQ            ๋ณด๊ด์ ์ํ์ค
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      (detailWareHouseInfo)
        //      USER_NAME               <String>        ์ํธ๋ช
        //      REVIEW_POINT_AVG        <Number>        ์ฌ์ฉ์ ๋ฆฌ๋ทฐ ํ์ 
        //      BIZ_SIMPLE_ADDR         <String>        ๋ณด๊ด์ ๊ฐ๋จ ์ฃผ์
        //      WAREHOUSE_ISSUE         <String>        ๋ณด๊ด์์ฒด ์ค๋ช
        //      WAREHOUSE_RATE          <String>        ๋ณด๊ด์จ
        //      WAREHOUSE_RATE_TEXT     <String>        ๋ณด๊ด ์ํ
        //      MAJOR_ATTACH_INFO       <String>        ๋ณด๊ด์ ๋ฉ์ธ์ฌ์ง ์ ๋ณด
        //      CD_BIZ_TYPE             <String>        ์์ข ์ฝ๋
        //      WORK_BASE_HOLIDAY       <String>        ์๋ฌด ๊ธฐ๋ณธ ๊ณตํด์ผ ์ฌ์ฉ ์ ๋ฌด
        //      WORK_STA_TIME           <String>        ์๋ฌด ์์ ์๊ฐ
        //      WORK_OUT_TIME           <String>        ์๋ฌด ์ข๋ฃ ์๊ฐ
        //      USER_WAREHOUSE_SEQ      <String>        ๋ณด๊ด์ ์ํ์ค
        //      MASTER_SEQ              <String>        ๋ง์คํฐ ์ํ์ค
        //      resCd                   <String>        ๊ฒฐ๊ณผ ์ฝ๋
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, "์์ฒญ ํค๋๋ฅผ ์์ฑํ์ง ๋ชปํ์ต๋๋ค."); return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "BIZ_USER_SEQ": storageSeq
        ]
        
        let url = getRequestUrl(body: "/sys/wareHouseReqV2/app/getDetailWareHouseInfo.do")
        apiManager.request(api: .getStorageDetail, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    /// ๋ณด๊ด์ ์ฌ์ง ์กฐํ
    func getStoragePictures(storageSeq: String, attachGrpSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ                ๋ณด๊ด์ ์ํ์ค
        //      ATTACH_GRP_SEQ          ๋ณด๊ด์ ์ฌ์ง ๊ทธ๋ฃน ์ํ์ค
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [saverPicList]
        //      ATTACH_GRP_SEQ          <Number>        ๋ณด๊ด ์ฅ์ ์ฌ์ง ๊ทธ๋ฃน ์ํ์ค
        //      ATTACH_SEQ              <Number>        ๋ณด๊ด ์ฅ์ ์ฌ์ง ์ํ์ค
        //      ATTACH_INFO             <String>        ๋ณด๊ด ์ฅ์ ์ฌ์ง ์ ๋ณด
        //
        //      [majorPicList]
        //      ATTACH_GRP_SEQ          <Number>        ๋ณด๊ด์ ๋ฉ์ธ ์ฌ์ง ๊ทธ๋ฃน ์ํ์ค
        //      ATTACH_SEQ              <Number>        ๋ณด๊ด์ ๋ฉ์ธ ์ฌ์ง ์ํ์ค
        //      ATTACH_INFO             <String>        ๋ณด๊ด์ ๋ฉ์ธ ์ฌ์ง ์ ๋ณด
        //
        //      [beforeAfterPicList]
        //      ATTACH_GRP_SEQ          <Number>        ๋ณด๊ด์ ์ /ํ๋ฉด ์ฌ์ง ๊ทธ๋ฃน ์ํ์ค
        //      ATTACH_SEQ              <Number>        ๋ณด๊ด์ ์ /ํ๋ฉด ์ฌ์ง ์ํ์ค
        //      ATTACH_INFO             <String>        ๋ณด๊ด์ ์ /ํ๋ฉด ์ฌ์ง ์ ๋ณด
        //
        //      resCd                   <String>        ๊ฒฐ๊ณผ ์ฝ๋
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, "์์ฒญ ํค๋๋ฅผ ์์ฑํ์ง ๋ชปํ์ต๋๋ค."); return }
        
        let param: Parameters = [
            "USER_SEQ": storageSeq,
            "ATTACH_GRP_SEQ": attachGrpSeq
        ]
        
        let url = getRequestUrl(body: "/sys/saver/app/getPictureList.do")
        apiManager.request(api: .getStoragePictures, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    /// ๋ณด๊ด์ ์๊ธ ์กฐํ
    func getCosts(storageSeq: String, completion: ResponseJson = nil) {
        
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                ๋ณด๊ด์ ์ํ์ค
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (basicPriceList)
        //      RATE_SEQ                ๊ธฐ๋ณธ ๊ฐ๊ฒฉ ์ํ์ค
        //      RATE_KIND               ๊ธฐ๋ณธ ๊ฐ๊ฒฉ ์ข๋ฅ
        //      RATE_USER_SECTION       ๊ธฐ๋ณธ ์ ์ฉ์๊ฐ
        //      RATE_USER_PRICE         ๊ธฐ๋ณธ ๊ฐ๊ฒฉ
        //
        //      (overPriceList)
        //      RATE_SEQ                ํ ์ฆ ๊ฐ๊ฒฉ ์ํ์ค
        //      RATE_KIND               ํ ์ฆ ๊ฐ๊ฒฉ ์ข๋ฅ
        //      RATE_USER_SECTION       ํ ์ฆ ์ ์ฉ์๊ฐ
        //      RATE_USER_PRICE         ํ ์ฆ ๊ฐ๊ฒฉ
        //
        //      (oneDayPriceList)
        //      RATE_SEQ                ํ ์ฆ ๊ฐ๊ฒฉ ์ํ์ค
        //      RATE_KIND               ํ ์ฆ ๊ฐ๊ฒฉ ์ข๋ฅ
        //      RATE_SECTION            ํ ์ฆ ์ ์ฉ์๊ฐ
        //      RATE_PRICE              ํ ์ฆ ๊ฐ๊ฒฉ
        //
        //------------------------------------------------------------- //
                
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_SEQ": storageSeq,
            "userPriceExistYn": "Y"
        ]
        
        let url = getRequestUrl(body: "/sys/price/app/getSaveUserPriceRate.do")
        apiManager.request(api: .getCosts, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    /// ๋ฆฌ๋ทฐ ์กฐํ
    func getReviews(storageSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ                ์ฌ์ฉ์ ์ํ์ค
        //      BIZ_USER_SEQ            ๋ณด๊ด์ ์ํ์ค
        //      BIZ_LAT                 ๋ณด๊ด์ ์์น (์๋)
        //      BIZ_LNG                 ๋ณด๊ด์ ์์น (๊ฒฝ๋)
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [getSearchWareHouseReviewList]
        //      USER_NAME               <String>        ๋ฆฌ๋ทฐ์์ฑ์
        //      MAJOR_ATTACH_INFO       <String>        ๋ณด๊ด์ ์ฌ์ง ์ ๋ณด
        //      BIZ_NAME                <String>        ์ํธ๋ช
        //      REVIEW_BODY             <String>        ๋ฆฌ๋ทฐ ๋ด์ฉ
        //      REVIEW_RECOMMEND        <Number>        ๋ฆฌ๋ทฐ ์ถ์ฒ์
        //      REVIEW_POINT            <Number>        ๋ณด๊ด์์ ๋ถ์ฌํ ๋ฆฌ๋ทฐ ์ ์
        //      REVIEW_SEQ              <Number>        ๋ฆฌ๋ทฐ ์ํ์ค
        //      REVIEW_ATTACH_GRP_SEQ   <Number>        ๋ฆฌ๋ทฐ ์ฌ์ง ๊ทธ๋ฃน ์ํ์ค
        //      resCd                   <String>        ๊ฒฐ๊ณผ ์ฝ๋
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, "์์ฒญ ํค๋๋ฅผ ์์ฑํ์ง ๋ชปํ์ต๋๋ค."); return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "BIZ_USER_SEQ": storageSeq,
//            "page": 1
        ]
        
        let url = getRequestUrl(body: "/sys/wareHouseReqV2/app/getSearchWareHouseReviewList.do")
        apiManager.request(api: .getStorageReviews, url: url, headers: headers, parameters: param, completion: completion)
    }
}
