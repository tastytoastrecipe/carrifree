//
//  PictureData.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/11/01.
//

import Foundation

@objc class PictureData: NSObject {
    var url: String = ""
    var seq: String = ""
    var grpSeq: String = ""
    var isMain: Bool = false
    
    override init() { super.init() }
    init(seq: String, url: String, grpSeq: String = "") {
        self.seq = seq; self.url = url; self.grpSeq = grpSeq
    }
}

// MARK: - 첨부파일 저장 공간 코드
/// 첨부파일 저장 공간 코드
enum AttachModule: String {
    case user = "1"
    case driver = "2"
    case storage = "3"
    case profile = "4"
    case none = ""
}

// MARK: - 첨부 파일 타입
/// 첨부파일 타입
enum AttachType: String {
    case bizLicense = "001"         // 사업자등록증
    case idLicense = "002"          // 주민등록증
    case bikeLicense = "003"        // 2륜 운전면허
    case carLicense = "004"         // 4륜 운전면허
    case truckLicense = "005"       // 화물 운송 등록증
    case vehicleFrontBack = "006"   // 운반기기 전/후면 사진
    case vehicleInside = "007"      // 운반기기 내부(화물칸) 사진
    case vehicleMain = "008"        // 운반기기 대표 사진
    case luggage = "009"            // 사용자가 맡긴 짐 사진
    case deliveryStart = "010"      // 운반 사업자가 수령한 짐 사진 (운반 시작)
    case deliveryEnd = "011"        // 운반 사업자가 전달한 짐 사진 (운반 완료)
    case storageFrontBack = "012"   // 보관장소 전/후면 사진
    case storageInside = "013"      // 보관장소 사진
    case storageMain = "014"        // 보관장소 대표 사진
    case banner = "015"             // 배너 이미지
    case profile = "016"            // 프로필 사진
    case expressLogo = "017"        // 직영사업자 로고 사진
    case bank = "020"               // 통장 사본
    
    var isPrivate: Bool {
        switch self {
        case .bank, .bizLicense, .idLicense, .bikeLicense, .carLicense, .truckLicense: return true
        default: return false
        }
    }
    
}

