//
//  NotificationData.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/26.
//
//
//  💬 NotificationData
//  알림 목록에 표시될 각 알림의 데이터
//

import UIKit

struct NotificationData {
    var noticase: Int       // 알림 종류 (NotiCase)
    var date: String        // 날짜
    var title: String       // 제목
    var from: String        // 보낸곳
    var desc: String        // 알림 내용
}

// 알림 종류
enum NotiCase: Int {
    case all = 0    // 전체
    case event      // 이벤트
    case gift       // 선물
    case review     // 리뷰
    case etc        // 기타
    case none
    
    var title: String {
        switch self {
        case .all: return "전체"
        case .event: return "이벤트"
        case .gift: return "선물"
        case .review: return _strings[.review]
        case .etc: return "기타"
        default: return ""
        }
    }
    
    var height: CGFloat {
        switch self {
        case .all: return 76
        case .event: return 76
        case .gift: return 118
        case .review: return 118
        case .etc: return 76
        default: return 76
        }
    }
    
    var centerY: CGFloat {
        switch self {
        case .all: return 0
        case .event: return 0
        case .gift: return -10
        case .review: return -10
        case .etc: return 0
        default: return 0
        }
    }
}
