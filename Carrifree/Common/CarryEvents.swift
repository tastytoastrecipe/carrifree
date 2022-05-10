//
//  CarryEvents.swift
//  Carrifree
//
//  Created by orca on 2020/10/08.
//  Copyright © 2020 plattics. All rights reserved.
//

import Foundation
import UIKit

@objc protocol CarryDelegate {
    @objc optional func writeReviewCancel()
    @objc optional func writeReviewDone(orderSeq: String, review: String)
    @objc optional func userDataChanged()
    
    @objc optional func showRefundInfo(orderSeq: String)
    @objc optional func deliveryRefundComplete()
    @objc optional func storageRefundComplete()
    
    @objc optional func pickDate(date: Date)                                                                // 검색 조건에서 시간 입력했을때 호출됨
    @objc optional func pickLocale(lat: Double, lng: Double, address: String, addressDetail: String)        // 검색 조건에서 위치 입력했을때 호출됨
    @objc optional func pickLuggage(s: Int, m: Int, l: Int, xl: Int)                                        // 검색 조건에서 짐 정보 입력했을때 호출됨
    
    @objc optional func locationAccessAuthorized()
    @objc optional func locationAccessDenied()
}

@objc protocol SceneChangeDelegate {
//    @objc var identifier: Int { get set }
    
    @objc func changeToSearchViewController(prevSceneName: String)
}

// 비밀 번호 전송 이벤트 (맡긴 물건을 찾을때 신청 내역에서 비밀 번호 보내기)
@objc protocol LuggageAuthDelegate {
    @objc optional func show(pw: String, orderSeq: String)
    @objc optional func authComplete(status: String)
}

@objc protocol AppStatusDelegate {
    @objc optional func didEnterBackground()
    @objc optional func willEnterForeground()
}

protocol CarryCollectionViewCellDelegate {
    func removedCell(id: String, data: UICollectionViewCell?)
}

@objc protocol CarryAddressDelegate {
    @objc optional func selected(address: String)
    @objc optional func searchDone(list: [String])
    @objc optional func currentAddress(address: String)
}

@objc protocol CarrySignInDelegate {
    @objc optional func signInSuccess()
    @objc optional func signInFailed()
    @objc optional func signOutSuccess()
    @objc optional func socialSignInSuccess(name: String, id: String)
    @objc optional func socialSignOutSuccess()
}

class CarryEvents {
    static let shared = CarryEvents()

    var sceneChanges: [SceneChangeDelegate] = []
    var collectionViewCell: [CarryCollectionViewCellDelegate] = []
    var address: [CarryAddressDelegate] = []
    var sign: [CarrySignInDelegate] = []
    var delegates: [CarryDelegate] = []
    var luggageAuthDelegates: [LuggageAuthDelegate?] = []
    var appStatusDelegates: [AppStatusDelegate?] = []
    
    private init() {}
    
    func appendDelegate(delegate: CarryDelegate) {
        guard delegates.filter({ $0 === delegate }).isEmpty else {
            MyLog.log("Delegate is alreay exist..")
            return
        }
        delegates.append(delegate)
    }
    
    func appendAppStatusDelegate(delegate: AppStatusDelegate) {
        guard appStatusDelegates.filter({ $0 === delegate }).isEmpty else {
            MyLog.log("AppStatusDelegates is alreay exist..")
            return
        }
        appStatusDelegates.append(delegate)
    }
    
    func appendSignInDelegate(delegate: CarrySignInDelegate) {
        guard sign.filter({ $0 === delegate }).isEmpty else {
            MyLog.log("SignInDelegate is alreay exist..")
            return
        }
        sign.append(delegate)
    }
    
    func callDidDismiss(prevSceneName: String) {
        for delegate in CarryEvents.shared.sceneChanges
        {
            delegate.changeToSearchViewController(prevSceneName: prevSceneName)
        }
    }
    
    func callRemovedCell(id: String = "", data: UICollectionViewCell? = nil) {
        for delegate in CarryEvents.shared.collectionViewCell
        {
            delegate.removedCell(id: id, data: data)
        }
    }
    
    func callSelectAddress(address: String) {
        for delegate in CarryEvents.shared.address
        {
            delegate.selected?(address: address)
        }
    }
    
    func callSearchDone(list: [String]) {
        for delegate in CarryEvents.shared.address
        {
            delegate.searchDone?(list: list)
        }
    }
    
    func callCurrentLocation(address: String) {
        for delegate in CarryEvents.shared.address
        {
            delegate.currentAddress?(address: address)
        }
    }
    
    func callSignInSuccess() {
        for delegate in CarryEvents.shared.sign
        {
            delegate.signInSuccess?()
        }
    }
    
    func callSignInFailed() {
        for delegate in CarryEvents.shared.sign
        {
            delegate.signInFailed?()
        }
    }
    
    func callSignOutSuccess() {
        for delegate in CarryEvents.shared.sign
        {
            delegate.signOutSuccess?()
        }
    }
    
    func callSocialSignInSuccess(name: String = "", id: String = "") {
        for delegate in CarryEvents.shared.sign
        {
            delegate.socialSignInSuccess?(name: name, id: id)
        }
    }
    
    func callSocialSignOutSuccess() {
        for delegate in CarryEvents.shared.sign
        {
            delegate.socialSignOutSuccess?()
        }
    }
    
    func callWriteReviewDone(orderSeq: String, review: String) {
        for delegate in CarryEvents.shared.delegates {
            delegate.writeReviewDone?(orderSeq: orderSeq, review: review)
        }
    }
    
    func callUserDataChanged() {
        for delegate in CarryEvents.shared.delegates {
            delegate.userDataChanged?()
        }
    }
    
    func callShowLuggageAuth(pw: String, orderSeq: String) {
        for delegate in CarryEvents.shared.luggageAuthDelegates {
            delegate?.show?(pw: pw, orderSeq: orderSeq)
        }
    }
    
    func callLuggageAuthComplete(status: String) {
        for delegate in CarryEvents.shared.luggageAuthDelegates {
            delegate?.authComplete?(status: status)
        }
    }
    
    func callApplicationDidEnterBackground() {
        for delegate in CarryEvents.shared.appStatusDelegates {
            delegate?.didEnterBackground?()
        }
    }
    
    func callApplicationWillEnterForeground() {
        for delegate in CarryEvents.shared.appStatusDelegates {
            delegate?.willEnterForeground?()
        }
    }
    
    func callShowRefundInfo(orderSeq: String) {
        for delegate in CarryEvents.shared.delegates {
            delegate.showRefundInfo?(orderSeq: orderSeq)
        }
    }
    
    func callDeliveryRefundComplete() {
        for delegate in CarryEvents.shared.delegates {
            delegate.deliveryRefundComplete?()
        }
    }
    
    func callStorageRefundComplete() {
        for delegate in CarryEvents.shared.delegates {
            delegate.storageRefundComplete?()
        }
    }
    
    func callPickDate(date: Date) {
        for delegate in CarryEvents.shared.delegates {
            delegate.pickDate?(date: date)
        }
    }
    
    func callPickLocale(lat: Double, lng: Double, address: String, addressDetail: String) {
        for delegate in CarryEvents.shared.delegates {
            delegate.pickLocale?(lat: lat, lng: lng, address: address, addressDetail: addressDetail)
        }
    }
    
    func callPickLuggage(s: Int, m: Int, l: Int, xl: Int) {
        for delegate in CarryEvents.shared.delegates {
            delegate.pickLuggage?(s: s, m: m, l: l, xl: xl)
        }
    }
    
    func callLocationAccessDenied() {
        for delegate in CarryEvents.shared.delegates {
            delegate.locationAccessDenied?()
        }
    }
    
    func callLocationAccessAuthorized() {
        for delegate in CarryEvents.shared.delegates {
            delegate.locationAccessAuthorized?()
        }
    }
}
