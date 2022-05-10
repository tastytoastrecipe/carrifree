//
//  TermData.swift
//  Carrifree
//
//  Created by orca on 2022/02/28.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 Terms
//  약관 데이터
//

import Foundation

struct TermData {
    let seq: String
    let title: String
    let content: String
    let required: Bool
}

enum TermCase: Int, CaseIterable {
    case appUse = 0             // 이용약관
    case privateInfo            // 개인정보 처리 방침
    case privateInfoCommision   // 개인정보처리 위탁 동의
    case localeInfo             // 위치기반서비스 이용약관
    case ad                     // 광고성 정보 수신 동의
    
    // 필수/선택 사항
    var required: Bool {
        switch self {
        case .ad: return false
        default: return true
        }
    }
    
    // 타입
    var type: String {
        switch self {
        case .appUse: return "001"
        case .privateInfo: return "002"
        case .privateInfoCommision: return "003"
        case .localeInfo: return "004"
        case .ad: return "005"
        }
    }
}

