//
//  RelatedWordsVm.swift
//  Carrifree
//
//  Created by orca on 2022/03/16.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 RelatedWordsVm
//  보관 검색 화면 View Model
//

import Foundation

protocol RelatedWordsVmDelegate {
    func lookupDelayed()
}

class RelatedWordsVm {
    var delegate: RelatedWordsVmDelegate?
    
    var lookupTimer: Timer? = nil
    var lookupDelay: Double = 0.0
    
    var matchingStorages: [MatchingStorage] = []
    var currentStorage: MatchingStorage!
    
    init() {
        lookupDelay = 1.0
    }
    
    /// 검색어 입력 후 검색 타이머 시작
    func startLookupDelay() {
        lookupTimer?.invalidate()
        lookupTimer = Timer.scheduledTimer(timeInterval: lookupDelay, target: self, selector: #selector(self.endLookupDelay), userInfo: nil, repeats: false)
    }
    
    @objc func endLookupDelay() {
        delegate?.lookupDelayed()
    }
    
    // MARK: - 보관소 검색 (연관 검색어 요청)
    /// 보관소 검색 (연관 검색어 요청)
    func lookup(lat: Double, lng: Double, word: String, completion: ResponseString = nil) {
        matchingStorages.removeAll()
        
        _cas.relatedWords.lookup(lat: lat, lng: lng, word: word) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "검색중 오류가 발생했습니다.", json: json))
                return
            }
            
            let arr = json["keywordWareHouseList"].arrayValue
            for val in arr {
                let bizName = val["USER_NAME"].stringValue
                let seq = val["BIZ_USER_SEQ"].stringValue
                let address = val["BIZ_SIMPLE_ADDR"].stringValue
                let lat = val["BIZ_LAT"].doubleValue
                let lng = val["BIZ_LNG"].doubleValue
                let distance = val["DISTANCE"].doubleValue
                let storage = MatchingStorage(name: bizName, address: address, seq: seq, lat: lat, lng: lng, distance: distance)
                self.matchingStorages.append(storage)
            }
            
            completion?(true, "")
        }
    }
}
