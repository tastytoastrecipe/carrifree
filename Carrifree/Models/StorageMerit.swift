//
//  StorageMerit.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/17.
//
//
//  💬 StorageMerit
//  보관 장점
//

import Foundation

/// 보관 장점
enum StorageMerit: String {
    case merit001 = "001"
    case merit002 = "002"
    case merit003 = "003"
    case merit004 = "004"
    case merit005 = "005"
    case merit006 = "006"
    case merit007 = "007"
    case merit008 = "008"
    case merit009 = "009"
    
    var name: String {
        switch self {
        case .merit001: return "역/정류장 근접(100m)"
        case .merit002: return "1층에 위치"
        case .merit003: return "엘리베이터"
        case .merit004: return "전용 보관장소"
        case .merit005: return "직원 상주"
        case .merit006: return "CCTV"
        case .merit007: return "화장실"
        case .merit008: return "휴대폰 충전"
        case .merit009: return "여행정보제공"
        }
    }
}
