//
//  MainSv.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/12/20.
//
//
//  💬 ## HomeSv ##
//  💬 메인(홈) 화면에서 필요한 정보를 요청하는 API 모음
//

import Foundation
import Alamofire
import SwiftyJSON

class HomeSv: Service {
    
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: - 배너
    /// 배너 요청
    func getBanners(bannerCase: String, bannerGroup: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      CD_CATEGORY                             배너 앱 분류 1 (배너가 보여질 앱의 종류)
        //      BRD_GROUP                               배너 앱 분류 2 (배너 그룹)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (bannerList)
        //      BOARD_SEQ               <Number>        게시판 시퀀스
        //      BOARD_TITLE             <String>        게시판 제목
        //      BANNER_ATTACH_INFO      <String>        이미지 경로
        //      BRD_ATTACH_GRP_SEQ      <Number>        게시판 메인 노출 이미지
        //      ATTACH_SEQ              <Number>        파일 시퀀스
        //      LINK_URL                <String>        연결 링크 정보
        //      BACKGROUND_COLOR        <String>        배경 색상 코드
        //      resCd                   <String>        결과 코드
        //
        //------------------------------------------------------------- //
        
        let param: [String: String] = [
            "CD_CATEGORY": bannerCase,
            "BRD_GROUP": bannerGroup
        ]
        
        let url = getRequestUrl(body: "/sys/contents/appMain/bannerList.do")
        apiManager.request(api: .getBanners, url: url, parameters: param, completion: completion)
    }

    // MARK: - 주변 보관소
    /// 주변 보관소 조회
    func getStorages(coordinate: Coordinate, align: AlignNearStorage, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //          USER_SEQ                사용자 시퀀스
        //          START_LAT               사용자 현재 위치(위도)
        //          START_LNG               사용자 현재 위치(경도)
        //          sort                    정렬 코드 (기본값: 001)    * 001: 거리순
        //                                                           002: 평점순
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //          (nearWareHouseList)
        //          DISTANCE                거리 <Number>
        //          MAJOR_ATTACH_INFO       사진 <String>
        //          USER_NAME               상호명 <String>
        //          REVIEW_POINT_AVG        리뷰 평점 <Number>
        //          resCd                   결과 코드 <String>
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
    
    // MARK: - 주변 보관소 리뷰
    /// 주변 보관소 리뷰 조회
    func getReviews(all: Bool, lat: Double, lng: Double, category: String, align: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //          USER_SEQ                사용자 시퀀스
        //          START_LAT               사용자 현재 위치(위도)
        //          START_LNG               사용자 현재 위치(경도)
        //          category01              업종 코드 (StorageCategory) - 업종 코드를 보내지않으면 업종 구분없는 전체 리뷰를 받음
        //          category02              정렬 코드 (기본값: 001)    * 001: 거리순
        //                                                           002: 평점순
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //          (wareHouseReviewList)
        //          BIZ_NAME                상호명 <String>
        //          REVIEW_RECOMMEND        추천수 <String>
        //          REVIEW_BODY             리뷰 내용 <String>
        //          MAJOR_ATTACH_INFO       사진 <Number>
        //          USER_NAME               작성자 <String>
        //          REVIEW_POINT            리뷰 점수 <Number>
        //          REVIEW_SEQ              리뷰 시퀀스 <String>
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
