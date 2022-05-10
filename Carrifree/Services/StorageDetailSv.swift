//
//  StorageDetailSv.swift
//  Carrifree
//
//  Created by orca on 2022/03/20.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 StorageDetailSv
//  💬 보관소 상세 정보 api 모음
//

import Foundation
import SwiftyJSON
import Alamofire

class StorageDetailSv: Service {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    /// 보관소 상세 정보 조회
    func getStorageInfo(storageSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ                사용자 시퀀스
        //      BIZ_USER_SEQ            보관소 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      (detailWareHouseInfo)
        //      USER_NAME               <String>        상호명
        //      REVIEW_POINT_AVG        <Number>        사용자 리뷰 평점
        //      BIZ_SIMPLE_ADDR         <String>        보관소 간단 주소
        //      WAREHOUSE_ISSUE         <String>        보관업체 설명
        //      WAREHOUSE_RATE          <String>        보관율
        //      WAREHOUSE_RATE_TEXT     <String>        보관 상태
        //      MAJOR_ATTACH_INFO       <String>        보관소 메인사진 정보
        //      CD_BIZ_TYPE             <String>        업종 코드
        //      WORK_BASE_HOLIDAY       <String>        업무 기본 공휴일 사용 유무
        //      WORK_STA_TIME           <String>        업무 시작 시간
        //      WORK_OUT_TIME           <String>        업무 종료 시간
        //      USER_WAREHOUSE_SEQ      <String>        보관소 시퀀스
        //      MASTER_SEQ              <String>        마스터 시퀀스
        //      resCd                   <String>        결과 코드
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, "요청 헤더를 생성하지 못했습니다."); return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "BIZ_USER_SEQ": storageSeq
        ]
        
        let url = getRequestUrl(body: "/sys/wareHouseReqV2/app/getDetailWareHouseInfo.do")
        apiManager.request(api: .getStorageDetail, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    /// 보관소 사진 조회
    func getStoragePictures(storageSeq: String, attachGrpSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ                보관소 시퀀스
        //      ATTACH_GRP_SEQ          보관소 사진 그룹 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [saverPicList]
        //      ATTACH_GRP_SEQ          <Number>        보관 장소 사진 그룹 시퀀스
        //      ATTACH_SEQ              <Number>        보관 장소 사진 시퀀스
        //      ATTACH_INFO             <String>        보관 장소 사진 정보
        //
        //      [majorPicList]
        //      ATTACH_GRP_SEQ          <Number>        보관소 메인 사진 그룹 시퀀스
        //      ATTACH_SEQ              <Number>        보관소 메인 사진 시퀀스
        //      ATTACH_INFO             <String>        보관소 메인 사진 정보
        //
        //      [beforeAfterPicList]
        //      ATTACH_GRP_SEQ          <Number>        보관소 전/후면 사진 그룹 시퀀스
        //      ATTACH_SEQ              <Number>        보관소 전/후면 사진 시퀀스
        //      ATTACH_INFO             <String>        보관소 전/후면 사진 정보
        //
        //      resCd                   <String>        결과 코드
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, "요청 헤더를 생성하지 못했습니다."); return }
        
        let param: Parameters = [
            "USER_SEQ": storageSeq,
            "ATTACH_GRP_SEQ": attachGrpSeq
        ]
        
        let url = getRequestUrl(body: "/sys/saver/app/getPictureList.do")
        apiManager.request(api: .getStoragePictures, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    /// 보관소 요금 조회
    func getCosts(storageSeq: String, completion: ResponseJson = nil) {
        
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                보관소 시퀀스
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (basicPriceList)
        //      RATE_SEQ                기본 가격 시퀀스
        //      RATE_KIND               기본 가격 종류
        //      RATE_USER_SECTION       기본 적용시간
        //      RATE_USER_PRICE         기본 가격
        //
        //      (overPriceList)
        //      RATE_SEQ                할증 가격 시퀀스
        //      RATE_KIND               할증 가격 종류
        //      RATE_USER_SECTION       할증 적용시간
        //      RATE_USER_PRICE         할증 가격
        //
        //      (oneDayPriceList)
        //      RATE_SEQ                할증 가격 시퀀스
        //      RATE_KIND               할증 가격 종류
        //      RATE_SECTION            할증 적용시간
        //      RATE_PRICE              할증 가격
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
    
    /// 리뷰 조회
    func getReviews(storageSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ                사용자 시퀀스
        //      BIZ_USER_SEQ            보관소 시퀀스
        //      BIZ_LAT                 보관소 위치 (위도)
        //      BIZ_LNG                 보관소 위치 (경도)
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [getSearchWareHouseReviewList]
        //      USER_NAME               <String>        리뷰작성자
        //      MAJOR_ATTACH_INFO       <String>        보관소 사진 정보
        //      BIZ_NAME                <String>        상호명
        //      REVIEW_BODY             <String>        리뷰 내용
        //      REVIEW_RECOMMEND        <Number>        리뷰 추천수
        //      REVIEW_POINT            <Number>        보관소에 부여한 리뷰 점수
        //      REVIEW_SEQ              <Number>        리뷰 시퀀스
        //      REVIEW_ATTACH_GRP_SEQ   <Number>        리뷰 사진 그룹 시퀀스
        //      resCd                   <String>        결과 코드
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, "요청 헤더를 생성하지 못했습니다."); return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "BIZ_USER_SEQ": storageSeq,
//            "page": 1
        ]
        
        let url = getRequestUrl(body: "/sys/wareHouseReqV2/app/getSearchWareHouseReviewList.do")
        apiManager.request(api: .getStorageReviews, url: url, headers: headers, parameters: param, completion: completion)
    }
}
