//
//  CarryApis.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/01/05.
//

import Foundation

enum ApiType {
    case uploadPreSign
    case uploadData
    case uploadDataComplete
    case getAttachGrpSeq
    case requestPrivateDownload
    case signin
    case signout
    case withdraw
    case deviceInfo
    case getUpdateInfo
    case idDuplicationCheck
    case getTerms
    case phoneAuth
    case signUp
    case getIdCode
    case authorizeIdCode
    case getPwCode
    case authorizePwCode
    case changePw
    case nearStorages
    case nearReviews
    case registerProfilePicture
    case findId
    case resetPw
    case getBanners
    case lookupStorage
    case lookupStorageNearby
    case enterWord
    case getReviewContent
    case getStorageDetail
    case getStoragePictures
    case getHotWords
    case getCategories
    case getBanks
    case getWeeks
    case getMerits
    case getCosts
    case getStorageReviews
    case requestPurchasing
    case finishPurchasing
    case getBills
    case getBillDoc
    case cancelOrder
    case getMyInfo
    case setMyInfo
    case setPhone
    case getLuggagePictures
    case changeOrderStatus
    case none
    
    var isProcessing: Bool {
        return self != .none
    }
    
    var title: String {
        switch self {
        case .uploadPreSign: return "업로드 URL 요청"
        case .uploadData: return "데이터 업로드 요청"
        case .uploadDataComplete: return "데이터 업로드 완료 요청"
        case .getAttachGrpSeq: return "그룹 시퀀스 요청"
        case .requestPrivateDownload: return "비공개 파일 다운로드 요청"
        case .signin: return "로그인"
        case .signout: return "로그아웃"
        case .withdraw: return "탈퇴"
        case .deviceInfo: return "기기 정보 전송"
        case .getUpdateInfo: return "앱 업데이트 정보 요청"
        case .idDuplicationCheck: return "ID 중복 확인"
        case .getTerms: return "약관 조회"
        case .phoneAuth: return "휴대폰 인증"
        case .signUp: return "회원 가입"
        case .getIdCode: return "ID 찾기 코드 발급"
        case .authorizeIdCode: return "ID 찾기 코드 인증"
        case .getPwCode: return "PW 찾기 코드 발급"
        case .authorizePwCode: return "PW 찾기 코드 인증"
        case .changePw: return "PW 변경"
        case .nearStorages: return "주변 보관소"
        case .nearReviews: return "주변 보관소들의 리뷰"
        case .registerProfilePicture: return "프로필 사진 등록"
        case .findId: return "아이디 찾기"
        case .resetPw: return "비밀번호 재설정"
        case .getBanners: return "배너 요청"
        case .lookupStorage: return "보관소 검색(연관검색어)"
        case .lookupStorageNearby: return "주변의 보관소 검색(간단정보)"
        case .enterWord: return "검색어 입력"
        case .getReviewContent: return "리뷰 상세내용 보기"
        case .getStorageDetail: return "보관소 상세정보 조회"
        case .getStoragePictures: return "보관소 사진 조회"
        case .getHotWords: return "많이 검색한 단어 조회"
        case .getCategories: return "업종 조회"
        case .getBanks: return "은행 조회"
        case .getWeeks: return "요일 조회"
        case .getMerits: return "보관 장점 조회"
        case .getCosts: return "보관소 요금 조회"
        case .getStorageReviews: return "보관소의 리뷰 조회"
        case .requestPurchasing: return "결제 요청"
        case .finishPurchasing: return "결제 완료"
        case .getBills: return "주문 내역 조회"
        case .getBillDoc: return "주문 상세내역 조회"
        case .cancelOrder: return "주문 취소(환불)"
        case .getMyInfo: return "내 정보 조회(My Page)"
        case .setMyInfo: return "내 정보 저장(My Page)"
        case .setPhone: return "휴대폰 번호 변경"
        case .getLuggagePictures: return "짐 사진 조회"
        case .changeOrderStatus: return "주문 상태 변경"
        default: return ""
        }
    }
}
