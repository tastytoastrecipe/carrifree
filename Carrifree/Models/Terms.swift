//
//  TermData.swift
//  Carrifree
//
//  Created by orca on 2022/02/28.
//  Copyright ยฉ 2022 plattics. All rights reserved.
//
//
//  ๐ฌ Terms
//  ์ฝ๊ด ๋ฐ์ดํฐ
//

import Foundation

struct TermData {
    let seq: String
    let title: String
    let content: String
    let required: Bool
}

enum TermCase: Int, CaseIterable {
    case appUse = 0             // ์ด์ฉ์ฝ๊ด
    case privateInfo            // ๊ฐ์ธ์ ๋ณด ์ฒ๋ฆฌ ๋ฐฉ์นจ
    case privateInfoCommision   // ๊ฐ์ธ์ ๋ณด์ฒ๋ฆฌ ์ํ ๋์
    case localeInfo             // ์์น๊ธฐ๋ฐ์๋น์ค ์ด์ฉ์ฝ๊ด
    case ad                     // ๊ด๊ณ ์ฑ ์ ๋ณด ์์  ๋์
    
    // ํ์/์ ํ ์ฌํญ
    var required: Bool {
        switch self {
        case .ad: return false
        default: return true
        }
    }
    
    // ํ์
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

