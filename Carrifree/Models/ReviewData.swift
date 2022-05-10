//
//  ReviewData.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/11.
//
//
//  💬 ReviewData
//  리뷰 데이터
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
/// 주변 보관소의 리뷰 정렬 방식
enum AlignNearReview: String {
    case recent = "001"      // 최신순
    case avg = "002"         // 평점순
    
    var name: String {
        switch self {
        case .recent: return "최신순"
        case .avg: return "평점순"
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
