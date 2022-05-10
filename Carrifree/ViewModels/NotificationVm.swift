//
//  NotificationVm.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/26.
//

import Foundation
import SwiftyJSON

@objc protocol NotificationVmDelegate {
    @objc optional func ready()
}

class NotificationVm {
    var delegate: NotificationVmDelegate?
    var notifications: [NotificationData] = []
    var category: [String] = []
    
    var dummyNotifications: [NotificationData] = []
    
    init(delegate: NotificationVmDelegate?) {
        self.delegate = delegate
        category = [
            NotiCase.all.title,
            NotiCase.event.title,
            NotiCase.gift.title,
            NotiCase.review.title,
            NotiCase.etc.title
        ]
        setDummyDatas()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            self.delegate?.ready?()
        }
    }
    
    func setDummyDatas() {
        dummyNotifications = [
            // etc
            NotificationData(noticase: NotiCase.etc.rawValue, date: "2022.01.26 17:12", title: "보관 서비스가 시작되었습니다.", from: "", desc: ""),
            NotificationData(noticase: NotiCase.etc.rawValue, date: "2022.01.21 11:00", title: "내가 남긴 후기에 댓글이 달렸습니다.", from: "", desc: ""),
            
            // gift
            NotificationData(noticase: NotiCase.gift.rawValue, date: "2022.01.25 10:30", title: "선물이 도착했습니다.", from: "탐앤탐스", desc: ""),
            NotificationData(noticase: NotiCase.gift.rawValue, date: "2022.01.10 11:30", title: "선물이 도착했습니다.", from: "스타벅스", desc: ""),
            NotificationData(noticase: NotiCase.gift.rawValue, date: "2022.01.11 12:00", title: "선물이 도착했습니다.", from: "CGV", desc: ""),
            NotificationData(noticase: NotiCase.gift.rawValue, date: "2022.01.26 13:30", title: "선물이 도착했습니다.", from: "나이키", desc: ""),
            NotificationData(noticase: NotiCase.gift.rawValue, date: "2022.01.18 17:30", title: "선물이 도착했습니다.", from: "CU 영등포점", desc: ""),
            
            // review
            NotificationData(noticase: NotiCase.review.rawValue, date: "2022.01.24 13:47", title: "리뷰를 작성해주세요.", from: "교보문고", desc: "서울 마포구 월드컵로3길 14 딜라이트스퀘어 1단지 지하2층"),
            NotificationData(noticase: NotiCase.review.rawValue, date: "2022.01.19 13:47", title: "리뷰를 작성해주세요.", from: "나주곰탕", desc: "서울 영등포구 버드나루로7길 16"),
            NotificationData(noticase: NotiCase.review.rawValue, date: "2022.01.13 13:47", title: "리뷰를 작성해주세요.", from: "항아리숯불갈비", desc: "경기 고양시 덕양구 중앙로468번길 16"),
            NotificationData(noticase: NotiCase.review.rawValue, date: "2022.01.22 13:47", title: "리뷰를 작성해주세요.", from: "다비치안경", desc: "서울 양천구 오목로 227"),
            
            // event
            NotificationData(noticase: NotiCase.event.rawValue, date: "2022.01.20 18:21", title: "보관 서비스 30% 할인행사!", from: "", desc: ""),
            NotificationData(noticase: NotiCase.event.rawValue, date: "2022.01.20 18:21", title: "가을맞이 여행짐 보관 서비스 이벤트 안내.", from: "", desc: ""),
            NotificationData(noticase: NotiCase.event.rawValue, date: "2022.01.20 18:21", title: "전국 스타벅스 1000원 할인권! (선착순 100명)", from: "", desc: ""),
        ]
    }
    
    func getNotifications(noticase: NotiCase, completeion: ResponseString = nil)
    {
        notifications.removeAll()
        
        // 서버에 알림 목록 요청
        // ...
        //
        
        switch noticase {
        case .all: notifications = dummyNotifications
        case .event,
             .gift,
             .review,
             .etc:
            notifications = dummyNotifications.filter({ $0.noticase == noticase.rawValue })
        default: break
        }
        
        completeion?(true, "")
    }
    
    
    func getFailedMsg(json: JSON?) -> String {
        guard let json = json else { return "" }
        var message = json["resMsg"].stringValue
        if message.isEmpty { message = _strings[.requestFailed] }
        return message
    }
}
