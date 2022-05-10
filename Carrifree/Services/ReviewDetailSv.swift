//
//  ReviewDetailSv.swift
//  Carrifree
//
//  Created by orca on 2022/03/18.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 ReviewDetailSv
//  💬 리뷰 상세 정보 api 모음
//

import Foundation
import SwiftyJSON
import Alamofire

class ReviewDetailSv: Service {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    /// 리뷰 상세내용 보기
    func getReviewContent(reviewSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            사용자 시퀀스
        //      REVIEW_SEQ          리뷰 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      (getSearchWareHouseReviewDetail)
        //      REVIEW_SEQ          <String>        리뷰 작성자 시퀀스
        //      REVIEW_BODY         <String>        리뷰 내용
        //      REVIEW_POINT        <Number>        리뷰 점수
        //      REVIEW_DATE         <String>        리뷰 작성일
        //      USER_NAME           <String>        리뷰 작성자
        //      BIZ_NAME            <String>        리뷰 상호명
        //      BIZ_USER_SEQ        <Number>        보관사업자 사용자 시퀀스
        //      BIZ_MASTER_SEQ      <Number>        보관사업자 마스터 시퀀스
        //      BIZ_LAT             <String>        위도
        //      BIZ_LNG             <String>        경도
        //      USER_NAME           <String>        리뷰 작성자
        //      BIZ_NAME            <String>        리뷰 상호명
        //      BIZ_USER_SEQ        <Number>        보관사업자 사용자 시퀀스
        //      resCd               <String>        결과 코드
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, "요청 헤더를 생성하지 못했습니다."); return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "REVIEW_SEQ": reviewSeq
        ]
        
        let url = getRequestUrl(body: "/sys/wareHouseReqV2/app/getSearchWareHouseReviewDetail.do")
        apiManager.request(api: .getReviewContent, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    /// 리뷰 사진 목록 요청
    func getReviewPictures(attachGrpSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ                사용자 시퀀스
        //      REVIEW_ATTACH_GRP_SEQ   리뷰 사진 그룹 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [reviewPicList]
        //      REVIEW_ATTACH_INFO      <String>        리뷰 사진 정보 (url)
        //      REVIEW_ATTACH_SEQ       <String>        리뷰 사진 시퀀스
        //      REVIEW_ATTACH_GRP_SEQ   <Number>        리뷰 사진 그룹 시퀀스
        //
        //      resCd                   <String>        결과 코드
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, "요청 헤더를 생성하지 못했습니다."); return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "REVIEW_ATTACH_GRP_SEQ": attachGrpSeq
        ]
        
        let url = getRequestUrl(body: "/sys/wareHouseReqV2/app/getReviewPictureList.do")
        apiManager.request(api: .getReviewContent, url: url, headers: headers, parameters: param, completion: completion)
    }
}
