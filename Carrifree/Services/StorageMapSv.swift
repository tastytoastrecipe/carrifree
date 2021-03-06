//
//  StorageMapSv.swift
//  Carrifree
//
//  Created by orca on 2022/03/16.
//  Copyright ยฉ 2022 plattics. All rights reserved.
//
//
//  ๐ฌ StorageMapSv
//  ๐ฌ ์ง๋, ๋ณด๊ด์ ๊ฒ์ ๊ด๋ จ api ๋ชจ์
//

import Foundation
import SwiftyJSON
import Alamofire

class StorageMapSv: Service {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
 
    /// ๊ฒ์์ด ์๋ ฅ
    func enterWord(word: String, lat: Double, lng: Double) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            ์ฌ์ฉ์ ์ํ์ค
        //      USER_KEYWORD        ๊ฒ์ ํค์๋
        //      SEARCH_LAT          ์ฌ์ฉ์ ์๋
        //      SEARCH_LNG          ์ฌ์ฉ์ ๊ฒฝ๋
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      resCd               <String>        ๊ฒฐ๊ณผ ์ฝ๋
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "USER_KEYWORD": word,
            "SEARCH_LAT": lat,
            "SEARCH_LNG": lng
        ]
        
        let url = getRequestUrl(body: "/sys/memberV3/app/setUserKeyword.do")
        apiManager.request(api: .enterWord, url: url, headers: headers, parameters: param)
    }
    
    /// ๋ง์ด ๊ฒ์ํ ๋จ์ด ์กฐํ
    func getHotWords(lat: Double, lng: Double, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            ์ฌ์ฉ์ ์ํ์ค
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [popularKeywordList]
        //      POPULAR_WORD            <String>        ๊ฒ์์ด
        //      WORDCNT                 <Number>        ๊ฒ์๋ ํ์
        //      resCd                   <String>        ๊ฒฐ๊ณผ ์ฝ๋
        //
        // ------------------------------------------------------------- //
        guard let headers = getHeader() else { completion?(false, "์์ฒญ ํค๋๋ฅผ ์์ฑํ์ง ๋ชปํ์ต๋๋ค."); return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "START_LAT": lat,
            "START_LNG": lng
        ]
        
        let url = getRequestUrl(body: "/sys/memberV3/app/getPopularKeywordList.do")
        apiManager.request(api: .getHotWords, url: url, headers: headers, parameters: param, completion: completion)
        
    }
    
    /// ์ฃผ๋ณ์ ๋ณด๊ด์ ๊ฒ์
    func lookupStoragesNearby(lat: Double, lng: Double, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            ์ฌ์ฉ์ ์ํ์ค
        //      START_LAT           ์ฌ์ฉ์ ํ์ฌ ์์น(์๋)
        //      START_LNG           ์ฌ์ฉ์ ํ์ฌ ์์น(๊ฒฝ๋)
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [searchNearWareHouseList]
        //      USER_NAME           <String>        ์ํธ๋ช
        //      BIZ_USER_SEQ        <Number>        ๋ณด๊ด์ฌ์์ฌ ์ํ์ค
        //      resCd               <String>        ๊ฒฐ๊ณผ ์ฝ๋
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, "์์ฒญ ํค๋๋ฅผ ์์ฑํ์ง ๋ชปํ์ต๋๋ค."); return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "START_LAT": lat,
            "START_LNG": lng,
        ]
        
        let url = getRequestUrl(body: "/sys/wareHouseReqV2/app/getSearchNearWareHouseList.do")
        apiManager.request(api: .lookupStorageNearby, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    /// ์ง๋์ ํ์๋  ๋ณด๊ด์ ์ ๋ณด ์์ฒญ
    func getStorage(lat: Double, lng: Double, storageSeq: String = "", word: String = "", completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            ์ฌ์ฉ์ ์ํ์ค
        //      START_LAT           ์ฌ์ฉ์ ํ์ฌ ์์น(์๋)
        //      START_LNG           ์ฌ์ฉ์ ํ์ฌ ์์น(๊ฒฝ๋)
        //      BIZ_USER_SEQ        ๋ณด๊ด์ฌ์์ ์ํ์ค - optional
        //      USER_KEYWORD        ๊ฒ์ ํค์๋ - optional
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      (searchWareHouse)
        //      CD_BIZ_TYPE         <String>        ์์ข ์ฝ๋
        //      BIZ_TYPE_TEXT       <String>        ์์ข๋ช
        //      USER_NAME           <String>        ์ํธ๋ช
        //      BIZ_SIMPLE_ADDR     <String>        ๋ณด๊ด์ ๊ฐ๋จ ์ฃผ์
        //      DISTANCE            <Number>        ๊ฑฐ๋ฆฌ
        //      REVIEW_POINT_AVG    <Number>        ๋ฆฌ๋ทฐ ํ์ 
        //      AVAILABLE_YN        <String>        ์ด์ฉ๊ฐ๋ฅ ์ฌ๋ถ(Y/N)
        //      WAREHOUSE_RATE      <Number>        ๋ณด๊ด์จ
        //      WAREHOUSE_RATE_TEXT <String>        ๋ณด๊ด์ํ
        //      resCd               <String>        ๊ฒฐ๊ณผ ์ฝ๋
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, "์์ฒญ ํค๋๋ฅผ ์์ฑํ์ง ๋ชปํ์ต๋๋ค."); return }
        
        var param: Parameters = [
            "USER_SEQ": _user.seq,
            "START_LAT": lat,
            "START_LNG": lng,
            "BIZ_USER_SEQ": storageSeq
        ]
        
        if word.count > 0 { param["USER_KEYWORD"] = word }
        
        let url = getRequestUrl(body: "/sys/wareHouseReqV2/app/getSearchWareHouse.do")
        apiManager.request(api: .lookupStorageNearby, url: url, headers: headers, parameters: param, completion: completion)
    }
}
