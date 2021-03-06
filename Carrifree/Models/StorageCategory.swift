//
//  StorageCategory.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/17.
//
//
//  π¬ StorageCategory
//  μμ’
//

import Foundation

/// μμ’
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
        case .storage001: return "μμμ "
        case .storage002: return "μμ "
        case .storage003: return "μΉ΄ν"
        case .storage004: return "λ¬Έκ΅¬/μμ "
        case .storage005: return "μμ"
        case .storage006: return "λ³΄κ΄μ"
        case .storage011: return "κΈ°ν"
        case .storage999: return "μ μ²΄"
        }
    }
    
    /// λ©μΈ(ν) νλ©΄μμ λ³΄μ¬μ§λ λ¦¬λ·°μ μμ’ λΆλ₯ λ²νΈ
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
    
    /// λ©μΈ(ν) νλ©΄μμ λ³΄μ¬μ§λ λ¦¬λ·°μ μμ’
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
