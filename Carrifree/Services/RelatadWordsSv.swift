//
//  RelatadWordsSv.swift
//  Carrifree
//
//  Created by orca on 2022/03/16.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 RelatedWordsSv
//  💬 지도, 보관소 검색 관련 api 모음
//

import Foundation
import SwiftyJSON
import Alamofire

class RelatedWordsSv: Service {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    /// 보관소 검색 (연관 검색어 요청)
    func lookup(lat: Double, lng: Double, word: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            사용자 시퀀스
        //      START_LAT           사용자 현재 위치(위도)
        //      START_LNG           사용자 현재 위치(경도)
        //      USER_KEYWORD        검색 키워드
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [keywordWareHouseList]
        //      USER_NAME           <String>        상호명
        //      BIZ_USER_SEQ        <Number>        보관사업사 시퀀스
        //      BIZ_SIMPLE_ADDR     <String>        보관소 간단 주소
        //      DISTANCE            <Number>        거리
        //      BIZ_LAT             <String>        보관소 위도
        //      BIZ_LNG             <String>        보관소 경도
        //
        //      resCd               <String>        결과 코드
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, "요청 헤더를 생성하지 못했습니다."); return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "START_LAT": lat,
            "START_LNG": lng,
            "USER_KEYWORD": word
        ]
        
        let url = getRequestUrl(body: "/sys/wareHouseReqV2/app/getKeywordWareHouseList.do")
        apiManager.request(api: .lookupStorage, url: url, headers: headers, parameters: param, completion: completion)
    }
}
