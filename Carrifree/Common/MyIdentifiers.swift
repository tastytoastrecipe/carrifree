//
//  MyIdentifiers.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2020/12/28.
//

import Foundation

typealias _identifiers = MyIdentifiers

enum MyIdentifiers: String {
    
    static subscript(_ identifier: MyIdentifiers) -> String {
        return identifier.rawValue
    }
    
    case scheme = "Carrifree"
    case appstoreUrl = "itms-apps://itunes.apple.com/app/apple-store/1562628368"   // 스토어 url (1562628368는 Apple ID)
    case devServer = "https://test-app.carrifree.com"   // 테스트 서버
    case liveServer = "https://app.carrifree.com"       // 라이브 서버
    
    case businessNumber = "269-86-01878"                // 사업자등록번호
    case mainOrderNumber = "2021-서울강서-0689"           // 통신판매번호
    case enquiryMail = "carrifree@carrifree.com"
    case platticsTel = "02-3459-3127"
    
    case iamportCompanyId = "imp08787062"
    case iamportKey = "5144373268051974"                                                                            // rest api key
    case iamportSecret = "JLLdLvUiElKY49eK0hj7f6BiXo6GqKX9vJmhehzTCkRGt5runLBCRcUPB0v1LtahdxysO8lrsd8WizrG"         // rest api secret
    
    case keyKakaoAapp = "a85aa5f35419561c2298e6fabfd3ca0f"
    case keyKakaoRestApi = "e4bafdf34d073d566331e573237a056f"
    
    case imgNaviLogo = "img-navi-logo"
    
    case keyUserId = "userId"
    case keyUserPw = "userPw"
    case keyUserName = "userName"
    case keyShaToken = "shaToken"
    case keyUserSeq = "userSeq"
    case keyUserEmail = "userEmail"
    case keyUserJoinType = "userJoinType"
    case keyMasterSeq = "userMasterSeq"
    case keyUserContact = "userContact-storage"
    case keyAppleUserName = "appleUserName"         // 애플 로그인은 최초 로그인에서만 이름을 받을 수 있기 때문에 최초 로그인시 이름을 캐싱한다
    
    case sceneMain = "scene-main"
    case sceneRegister = "scene-register"
    case sceneSideMenu = "scene-sidemenu"
    case sceneFullScreenImg = "scene-full-screen-img"
    case sceneNaviRegister = "scene-navi-register"
    case sceneSearchAddress = "scene-search-address"
    case sceneNaviRegisterCost = "scene-navi-register-cost"
    case sceneRequestList = "scene-request-list"
    case sceneRequestDetail = "scene-request-detail"
    case sceneNaviSales = "scene-navi-sales"
    case sceneSales = "scene-sales"
    case sceneNaviReview = "scene-navi-review"
    case sceneSettings = "scene-settings"
    case sceneShowTerms = "scene-show-terms"
    case sceneVerification = "scene-verification"
    case sceneGuide = "scene-guide"
    case sceneNotice = "scene-notice"
    
    case segueSignIn = "segue-sign-in"
    case segueSignUp = "segue-sign-up"
    case segueSignUpDetail = "segue-sign-up-detail"
    case segueFindId = "segue-find-id"
    case segueFindPw = "segue-find-pw"
    case seguePublic = "segue-public"
    case segueSetPush = "segue-set-push"
    case segueTerms = "segue-terms"
    case segueThanksTo = "segue-thanks-to"
    case segueMyPage = "segue-my-page"
    
    case constraintTargetHeight = "targetHeight"
    
    case thumbnailSideMenu01 = "icon-sidemenu-"
    
    case sideMenuCellIdentifier = "sideMenuCell"
    
    case pictureType012 = "012"     // 012 = [전/후면 사진]
    case pictureType013 = "013"     // 013 = [일반 사진]
    case pictureType014 = "014"     // 014 = [메인 사진]
    
    case csEmail = "plattics.cs@gmail.com"
    case platticsHomepage = "http://plattics.com/"
}

enum CarryTags: Int {
    case timePicker = 1500
    case inputDisplay = 1501
    case blurView = 2000
}
