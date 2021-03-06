//
//  MainSv.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/12/20.
//
//
//  ๐ฌ ## HomeSv ##
//  ๐ฌ ๋ฉ์ธ(ํ) ํ๋ฉด์์ ํ์ํ ์ ๋ณด๋ฅผ ์์ฒญํ๋ API ๋ชจ์
//

import Foundation
import Alamofire
import SwiftyJSON

class HomeSv: Service {
    
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: - ๋ฐฐ๋
    /// ๋ฐฐ๋ ์์ฒญ
    func getBanners(bannerCase: String, bannerGroup: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      CD_CATEGORY                             ๋ฐฐ๋ ์ฑ ๋ถ๋ฅ 1 (๋ฐฐ๋๊ฐ ๋ณด์ฌ์ง ์ฑ์ ์ข๋ฅ)
        //      BRD_GROUP                               ๋ฐฐ๋ ์ฑ ๋ถ๋ฅ 2 (๋ฐฐ๋ ๊ทธ๋ฃน)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (bannerList)
        //      BOARD_SEQ               <Number>        ๊ฒ์ํ ์ํ์ค
        //      BOARD_TITLE             <String>        ๊ฒ์ํ ์ ๋ชฉ
        //      BANNER_ATTACH_INFO      <String>        ์ด๋ฏธ์ง ๊ฒฝ๋ก
        //      BRD_ATTACH_GRP_SEQ      <Number>        ๊ฒ์ํ ๋ฉ์ธ ๋ธ์ถ ์ด๋ฏธ์ง
        //      ATTACH_SEQ              <Number>        ํ์ผ ์ํ์ค
        //      LINK_URL                <String>        ์ฐ๊ฒฐ ๋งํฌ ์ ๋ณด
        //      BACKGROUND_COLOR        <String>        ๋ฐฐ๊ฒฝ ์์ ์ฝ๋
        //      resCd                   <String>        ๊ฒฐ๊ณผ ์ฝ๋
        //
        //------------------------------------------------------------- //
        
        let param: [String: String] = [
            "CD_CATEGORY": bannerCase,
            "BRD_GROUP": bannerGroup
        ]
        
        let url = getRequestUrl(body: "/sys/contents/appMain/bannerList.do")
        apiManager.request(api: .getBanners, url: url, parameters: param, completion: completion)
    }

    // MARK: - ์ฃผ๋ณ ๋ณด๊ด์
    /// ์ฃผ๋ณ ๋ณด๊ด์ ์กฐํ
    func getStorages(coordinate: Coordinate, align: AlignNearStorage, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //          USER_SEQ                ์ฌ์ฉ์ ์ํ์ค
        //          START_LAT               ์ฌ์ฉ์ ํ์ฌ ์์น(์๋)
        //          START_LNG               ์ฌ์ฉ์ ํ์ฌ ์์น(๊ฒฝ๋)
        //          sort                    ์ ๋ ฌ ์ฝ๋ (๊ธฐ๋ณธ๊ฐ: 001)    * 001: ๊ฑฐ๋ฆฌ์
        //                                                           002: ํ์ ์
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //          (nearWareHouseList)
        //          DISTANCE                ๊ฑฐ๋ฆฌ <Number>
        //          MAJOR_ATTACH_INFO       ์ฌ์ง <String>
        //          USER_NAME               ์ํธ๋ช <String>
        //          REVIEW_POINT_AVG        ๋ฆฌ๋ทฐ ํ์  <Number>
        //          resCd                   ๊ฒฐ๊ณผ ์ฝ๋ <String>
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "START_LAT": coordinate.lat,
            "START_LNG": coordinate.lng,
            "sort": align.rawValue
        ]
        
        let url = getRequestUrl(body: "/sys/wareHouseReqV2/app/getNearWareHouseList.do")
        apiManager.request(api: .nearStorages, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - ์ฃผ๋ณ ๋ณด๊ด์ ๋ฆฌ๋ทฐ
    /// ์ฃผ๋ณ ๋ณด๊ด์ ๋ฆฌ๋ทฐ ์กฐํ
    func getReviews(all: Bool, lat: Double, lng: Double, category: String, align: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //          USER_SEQ                ์ฌ์ฉ์ ์ํ์ค
        //          START_LAT               ์ฌ์ฉ์ ํ์ฌ ์์น(์๋)
        //          START_LNG               ์ฌ์ฉ์ ํ์ฌ ์์น(๊ฒฝ๋)
        //          category01              ์์ข ์ฝ๋ (StorageCategory) - ์์ข ์ฝ๋๋ฅผ ๋ณด๋ด์ง์์ผ๋ฉด ์์ข ๊ตฌ๋ถ์๋ ์ ์ฒด ๋ฆฌ๋ทฐ๋ฅผ ๋ฐ์
        //          category02              ์ ๋ ฌ ์ฝ๋ (๊ธฐ๋ณธ๊ฐ: 001)    * 001: ๊ฑฐ๋ฆฌ์
        //                                                           002: ํ์ ์
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //          (wareHouseReviewList)
        //          BIZ_NAME                ์ํธ๋ช <String>
        //          REVIEW_RECOMMEND        ์ถ์ฒ์ <String>
        //          REVIEW_BODY             ๋ฆฌ๋ทฐ ๋ด์ฉ <String>
        //          MAJOR_ATTACH_INFO       ์ฌ์ง <Number>
        //          USER_NAME               ์์ฑ์ <String>
        //          REVIEW_POINT            ๋ฆฌ๋ทฐ ์ ์ <Number>
        //          REVIEW_SEQ              ๋ฆฌ๋ทฐ ์ํ์ค <String>
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        var param: Parameters = [
            "USER_SEQ": _user.seq,
            "START_LAT": lat,
            "START_LNG": lng,
            "category02": align
        ]
        
        if all {
            param["DISPLAY_ALL"] = "Y"
        }
            
        if false == category.isEmpty {
            param["category01"] = category
        }
        
        let url = getRequestUrl(body: "/sys/wareHouseReqV2/app/getWareHouseReviewList.do")
        apiManager.request(api: .nearReviews, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    
}
