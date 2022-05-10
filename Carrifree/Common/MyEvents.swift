//
//  MyEvents.swift
//  Carrifree
//
//  Created by orca on 2022/03/27.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 MyEvents
//  전역 이벤트 모음
//

import Foundation

var _events: MyEvents = {
    return MyEvents.shared
}()

@objc protocol MyEventsDelegate {
    @objc optional func orderStatusChanged()                                                // 주문 상태 변경됨
    @objc optional func storageItemSelected(storageSeq: String, storageName: String)        // 메인화면의 (주변)보관소 선택
    @objc optional func storageSelectedInReview(storageSeq: String, storageName: String)    // 메인화면의 리뷰 상세정보에서 '보관 진행' 선택
    @objc optional func purchaseDone(seeBills: Bool)                                        // 결제 완료 - seeBills: 내역화면 이동 여부
    @objc optional func moveToMap()                                                         // StorageMap 화면으로 이동
}

class MyEvents {
    static let shared = MyEvents()
    
    var delegates: [MyEventsDelegate] = []
    
    func addDelegate(delegate: MyEventsDelegate) {
        guard delegates.filter({ $0 === delegate }).isEmpty else {
            MyLog.log("Delegate is alreay exist")
            return
        }
        delegates.append(delegate)
    }
    
    func removeDelegate(delegate: MyEventsDelegate) {
        delegates.removeAll(where: { $0 === delegate })
    }
    
    /// 주문 상태 변경됨
    func orderStatusChanged() {
        for delegate in delegates { delegate.orderStatusChanged?() }
    }
    
    /// 메인화면의 (주변)보관소 선택
    func storageItemSelected(storageSeq: String, storageName: String) {
        for delegate in delegates { delegate.storageItemSelected?(storageSeq: storageSeq, storageName: storageName) }
    }
    
    /// 메인화면의 리뷰 상세정보에서 '보관 진행' 선택
    func storageSelectedInReview(storageSeq: String, storageName: String) {
        for delegate in delegates { delegate.storageSelectedInReview?(storageSeq: storageSeq, storageName: storageName) }
    }
    
    /// 결제 완료
    /// seeBills: 내역화면 이동 여부
    func purchaseDone(seeBills: Bool) {
        for delegate in delegates { delegate.purchaseDone?(seeBills: seeBills) }
    }
    
    /// StorageMap 화면으로 이동
    func moveToMap() {
        for delegate in delegates { delegate.moveToMap?() }
    }
    
}
