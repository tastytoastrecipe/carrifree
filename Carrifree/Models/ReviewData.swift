//
//  ReviewData.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/11.
//
//
//  π¬ ReviewData
//  λ¦¬λ·° λ°μ΄ν°
//

import Foundation

struct ReviewData {
    var seq: String
    var imgUrl: String
    var bizname: String
    var content: String
    var username: String
    var like: Int
    var rating: Double
    var attachGrpSeq: String
}

// MARK: - AlignNearReview
/// μ£Όλ³ λ³΄κ΄μμ λ¦¬λ·° μ λ ¬ λ°©μ
enum AlignNearReview: String {
    case recent = "001"      // μ΅μ μ
    case avg = "002"         // νμ μ
    
    var name: String {
        switch self {
        case .recent: return "μ΅μ μ"
        case .avg: return "νμ μ"
        }
    }
    
    var index: Int {
        switch self {
        case .recent: return 0
        case .avg: return 1
        }
    }
    
    static func getAlign(alignIndex index: Int) -> AlignNearReview {
        switch index {
        case recent.index: return .recent
        case avg.index: return .avg
        default: return .recent
        }
    }
}
