//
//  StorageCategory.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/17.
//
//
//  💬 StorageCategory
//  업종
//

import Foundation

/// 업종
enum StorageCategory: String  {
    case storage001 = "001"
    case storage002 = "002"
    case storage003 = "003"
    case storage004 = "004"
    case storage005 = "005"
    case storage006 = "006"
    case storage011 = "011"
    case storage999 = ""

    var name: String {
        switch self {
        case .storage001: return "음식점"
        case .storage002: return "상점"
        case .storage003: return "카페"
        case .storage004: return "문구/서점"
        case .storage005: return "숙소"
        case .storage006: return "보관소"
        case .storage011: return "기타"
        case .storage999: return "전체"
        }
    }
    
    /// 메인(홈) 화면에서 보여지는 리뷰의 업종 분류 번호
    var reviewMenuIndex: Int {
        switch self {
        case .storage006: return 1
        case .storage005: return 2
        case .storage003: return 3
        case .storage002, .storage004: return 4
        case .storage001: return 5
        case .storage999: return 0
        default: return 0
        }
    }
    
    /// 메인(홈) 화면에서 보여지는 리뷰의 업종
    static func getReviewCategory(reviewMenuIndex index: Int) -> StorageCategory {
        switch index {
        case storage006.reviewMenuIndex: return .storage006
        case storage005.reviewMenuIndex: return .storage005
        case storage003.reviewMenuIndex: return .storage003
        case storage002.reviewMenuIndex, storage004.reviewMenuIndex: return .storage002
        case storage001.reviewMenuIndex: return .storage001
        case storage999.reviewMenuIndex: return .storage999
        default: return .storage003
        }
    }
}
