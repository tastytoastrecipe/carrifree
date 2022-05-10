//
//  CarryRequest.swift
//  Carrifree
//
//  Created by orca on 2020/10/26.
//  Copyright © 2020 plattics. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

var _cas: CarrifreeApiService = {
    return CarrifreeApiService.shared
}()

class CarrifreeApiService {
    static let shared = CarrifreeApiService()
    
    lazy var apiManager = ApiManager()
    
    /// 로딩화면 api service
    lazy var load = LoadSv(apiManager: apiManager)
    
    /// 메인(홈) 화면 api service
    lazy var home = HomeSv(apiManager: apiManager)
    
    /// 내정보 화면 api service
    lazy var mypage = MyPageSv(apiManager: apiManager)
    
    /// 파일 업로드/다운로드 api service
    lazy var attach = AttachSv(apiManager: apiManager)
    
    /// 회원가입 api service
    lazy var signup = SignupSv(apiManager: apiManager)
    
    /// 로그인 api service
    lazy var signin = SigninSv(apiManager: apiManager)
    
    /// ID 찾기 api service
    lazy var forgetId = ForgetIdSv(apiManager: apiManager)
    
    /// PW 재설정 api service
    lazy var forgetPw = ForgetPwSv(apiManager: apiManager)
    
    /// 지도 api service
    lazy var storageMap = StorageMapSv(apiManager: apiManager)
    
    /// 보관소 검색 api service
    lazy var relatedWords = RelatedWordsSv(apiManager: apiManager)
    
    /// 리뷰 상세정보 api service
    lazy var reviewDetail = ReviewDetailSv(apiManager: apiManager)
    
    /// 보관소 상세정보 api service
    lazy var storageDetail = StorageDetailSv(apiManager: apiManager)
    
    /// 여러화면에서 쓰이는 api service
    lazy var general = GeneralSv(apiManager: apiManager)
    
    /// 결제 관련 api service
    lazy var purchsing = PurchasingSv(apiManager: apiManager)
    
    /// 주문 내역 관련 api service
    lazy var bills = BillsSv(apiManager: apiManager)
    
    private init() {}
}
