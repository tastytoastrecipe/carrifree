//
//  StorageMapSv.swift
//  Carrifree
//
//  Created by orca on 2022/03/16.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 StorageMapSv
//  💬 지도, 보관소 검색 관련 api 모음
//

import Foundation
import SwiftyJSON
import Alamofire

class StorageMapSv: Service {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
 
    /// 검색어 입력
    func enterWord(word: String, lat: Double, lng: Double) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            사용자 시퀀스
        //      USER_KEYWORD        검색 키워드
        //      SEARCH_LAT          사용자 위도
        //      SEARCH_LNG          사용자 경도
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      resCd               <String>        결과 코드
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
    
    /// 많이 검색한 단어 조회
    func getHotWords(lat: Double, lng: Double, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            사용자 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [popularKeywordList]
        //      POPULAR_WORD            <String>        검색어
        //      WORDCNT                 <Number>        검색된 횟수
        //      resCd                   <String>        결과 코드
        //
        // ------------------------------------------------------------- //
        guard let headers = getHeader() else { completion?(false, "요청 헤더를 생성하지 못했습니다."); return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "START_LAT": lat,
            "START_LNG": lng
        ]
        
        let url = getRequestUrl(body: "/sys/memberV3/app/getPopularKeywordList.do")
        apiManager.request(api: .getHotWords, url: url, headers: headers, parameters: param, completion: completion)
        
    }
    
    /// 주변의 보관소 검색
    func lookupStoragesNearby(lat: Double, lng: Double, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            사용자 시퀀스
        //      START_LAT           사용자 현재 위치(위도)
        //      START_LNG           사용자 현재 위치(경도)
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [searchNearWareHouseList]
        //      USER_NAME           <String>        상호명
        //      BIZ_USER_SEQ        <Number>        보관사업사 시퀀스
        //      resCd               <String>        결과 코드
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, "요청 헤더를 생성하지 못했습니다."); return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "START_LAT": lat,
            "START_LNG": lng,
        ]
        
        let url = getRequestUrl(body: "/sys/wareHouseReqV2/app/getSearchNearWareHouseList.do")
        apiManager.request(api: .lookupStorageNearby, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    /// 지도에 표시될 보관소 정보 요청
    func getStorage(lat: Double, lng: Double, storageSeq: String = "", word: String = "", completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            사용자 시퀀스
        //      START_LAT           사용자 현재 위치(위도)
        //      START_LNG           사용자 현재 위치(경도)
        //      BIZ_USER_SEQ        보관사업자 시퀀스 - optional
        //      USER_KEYWORD        검색 키워드 - optional
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      (searchWareHouse)
        //      CD_BIZ_TYPE         <String>        업종 코드
        //      BIZ_TYPE_TEXT       <String>        업종명
        //      USER_NAME           <String>        상호명
        //      BIZ_SIMPLE_ADDR     <String>        보관소 간단 주소
        //      DISTANCE            <Number>        거리
        //      REVIEW_POINT_AVG    <Number>        리뷰 평점
        //      AVAILABLE_YN        <String>        이용가능 여부(Y/N)
        //      WAREHOUSE_RATE      <Number>        보관율
        //      WAREHOUSE_RATE_TEXT <String>        보관상태
        //      resCd               <String>        결과 코드
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, "요청 헤더를 생성하지 못했습니다."); return }
        
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
