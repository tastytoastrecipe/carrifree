//
//  LuggageType.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/11/01.
//

import Foundation

enum LuggageType: CaseIterable {
    case s
    case m
    case l
    case xl
    case none
    
    var name: String {
        switch self {
        case .s: return "S"
        case .m: return "M"
        case .l: return "L"
        case .xl: return "XL"
        default: return ""
        }
    }
    
    var longName: String {
        switch self {
        case .s: return "Small"
        case .m: return "Medium"
        case .l: return "Large"
        case .xl: return "Extra Large"
        default: return ""
        }
    }
    
    var luggageName: String {
        switch self {
        case .s: return _strings[.luggageS]
        case .m: return _strings[.luggageM]
        case .l: return _strings[.luggageL]
        case .xl: return _strings[.luggageXL]
        default: return ""
        }
    }
    
    var desc: String {
        switch self {
        case .s: return """
            작은짐(S)
            ・서류봉투크기
            ・3Kg 미만
            """
        case .m: return """
            보통짐(M)
            ・배낭(20L 미만)
            ・캐리어(20인치 미만)
            ・10Kg 미만
            """
        case .l: return """
            큰짐(L)
            ・배낭(20~40L 미만)
            ・캐리어(20~25인치 미만)
            ・10~20Kg 미만
            """
        case .xl: return """
            대형짐(XL)
            ・배낭(40~80L 미만)
            ・캐리어(25~29인치 미만)
            ・골프백 등 (20~25kg 미만)
            """
        default: return ""
        }
    }
    
    var type: String {
        switch self {
        case .s: return "001"
        case .m: return "002"
        case .l: return "003"
        case .xl: return "004"
        default: return ""
        }
    }
}
