//
//  RelatadWordsSv.swift
//  Carrifree
//
//  Created by orca on 2022/03/16.
//  Copyright Β© 2022 plattics. All rights reserved.
//
//
//  π¬ RelatedWordsSv
//  π¬ μ§λ, λ³΄κ΄μ κ²μ κ΄λ ¨ api λͺ¨μ
//

import Foundation
import SwiftyJSON
import Alamofire

class RelatedWordsSv: Service {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    /// λ³΄κ΄μ κ²μ (μ°κ΄ κ²μμ΄ μμ²­)
    func lookup(lat: Double, lng: Double, word: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            μ¬μ©μ μνμ€
        //      START_LAT           μ¬μ©μ νμ¬ μμΉ(μλ)
        //      START_LNG           μ¬μ©μ νμ¬ μμΉ(κ²½λ)
        //      USER_KEYWORD        κ²μ ν€μλ
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [keywordWareHouseList]
        //      USER_NAME           <String>        μνΈλͺ
        //      BIZ_USER_SEQ        <Number>        λ³΄κ΄μ¬μμ¬ μνμ€
        //      BIZ_SIMPLE_ADDR     <String>        λ³΄κ΄μ κ°λ¨ μ£Όμ
        //      DISTANCE            <Number>        κ±°λ¦¬
        //      BIZ_LAT             <String>        λ³΄κ΄μ μλ
        //      BIZ_LNG             <String>        λ³΄κ΄μ κ²½λ
        //
        //      resCd               <String>        κ²°κ³Ό μ½λ
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, "μμ²­ ν€λλ₯Ό μμ±νμ§ λͺ»νμ΅λλ€."); return }
        
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
