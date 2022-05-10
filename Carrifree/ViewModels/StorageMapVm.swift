//
//  LookupVm.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/12.
//
//
//  💬 StorageMapVm
//  보관 검색 화면 View Model
//

import Foundation

class StorageMapVm {
    
    var hotWords: [String] = []                         // 많이 검색한 단어
    var storages: [StorageMapData] = []                 // 지도에 표시된 모든 보관소
    var currentStorage: StorageMapData!                 // 현재 선택된 보관소
    var matchingStoragesNearby: [MatchingStorage] = []  // 검색된 주변 보관소 (검색 후 지도에 표시되기 전 데이터)
    
    init() {
//        setDummyDatas()
    }
    
    /*
    func setDummyDatas() {
        hotKeywords.append(contentsOf: ["김포공항", "인천공항", "제주도", "서울역", "영등포역", "KTX", "카페", "서점", "식당", "모텔"])
        
        let storage01 = StorageMapData(category: StorageCategory.storage001.rawValue, address: "서울시 강서구 ....", status: StorageCapacity.enough.rawValue, available: true, name: "보관소 01", imgUrl: "img-test-storage-0", distance: Double(Int.random(in: 0 ... 5)), rating: Double(Int.random(in: 0 ... 5)), lat: 37.559106, lng: 126.811840)
        
        let storage02 = StorageMapData(category: StorageCategory.storage001.rawValue, address: "서울시 강서구 ....", status: StorageCapacity.enough.rawValue, available: true, name: "보관소 02", imgUrl: "img-test-storage-1", distance: Double(Int.random(in: 0 ... 5)), rating: Double(Int.random(in: 0 ... 5)), lat: 37.559139, lng: 126.810250)
        
        let storage03 = StorageMapData(category: StorageCategory.storage001.rawValue, address: "서울시 강서구 ....", status: StorageCapacity.enough.rawValue, available: true, name: "보관소 03", imgUrl: "img-test-storage-2", distance: Double(Int.random(in: 0 ... 5)), rating: Double(Int.random(in: 0 ... 5)), lat: 37.559973, lng: 126.808829)
        
        let storage04 = StorageMapData(category: StorageCategory.storage001.rawValue, address: "서울시 강서구 ....", status: StorageCapacity.enough.rawValue, available: true, name: "보관소 04", imgUrl: "img-test-storage-3", distance: Double(Int.random(in: 0 ... 5)), rating: Double(Int.random(in: 0 ... 5)), lat: 37.560849, lng: 126.808578)
        
        let storage05 = StorageMapData(category: StorageCategory.storage001.rawValue, address: "서울시 강서구 ....", status: StorageCapacity.enough.rawValue, available: true, name: "보관소 05", imgUrl: "img-test-storage-4", distance: Double(Int.random(in: 0 ... 5)), rating: Double(Int.random(in: 0 ... 5)), lat: 37.560900, lng: 126.809903)
        
        storages.append(contentsOf: [storage01, storage02, storage03, storage04, storage05])
    }
    
    func getStorages() {
        storages.removeAll()
        setDummyDatas()
    }
    */
    
    func reset() {
        currentStorage = nil
        storages.removeAll()
        matchingStoragesNearby.removeAll()
        hotWords.removeAll()
    }
    
    func setCurrentStorageByName(name: String?) {
        let name = name ?? ""
        if name.isEmpty { return }
        
        for storage in storages {
            if name == storage.name {
                currentStorage = storage
                break
            }
        }
    }
    
    // MARK: - 검색어 입력
    /// 검색어 입력
    func enterWord(word: String, lat: Double, lng: Double) {
        _cas.storageMap.enterWord(word: word, lat: lat, lng: lng)
    }
    
    // MARK: - 많이 검색한 단어 조회
    /// 많이 검색한 단어 조회
    func getHotWords(lat: Double, lng: Double, completion: ResponseString = nil) {
        //      [popularKeywordList]
        //      POPULAR_WORD            <String>        검색어
        //      WORDCNT                 <Number>        검색된 횟수
        //      resCd                   <String>        결과 코드
        
        _cas.storageMap.getHotWords(lat: lat, lng: lng) { (success, json) in
            guard let json = json, true == success else {
                _log.log(ApiManager.getFailedMsg(defaultMsg: "많이 검색된 단어 조회 실패", json: json))
                return
            }
            
            let arr = json["popularKeywordList"].arrayValue
            for val in arr {
                let word = val["POPULAR_WORD"].stringValue
                self.hotWords.append(word)
            }
            
            completion?(true, "")
        }
    }
    
    
    // MARK: - 주변의 보관소 검색
    /// 주변의 보관소 검색
    func lookupStoragesNearby(lat: Double, lng: Double, completion: ResponseString = nil) {
        matchingStoragesNearby.removeAll()
        _cas.storageMap.lookupStoragesNearby(lat: lat, lng: lng) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "검색중 오류가 발생했습니다.", json: json))
                return
            }
            
            let arr = json["searchNearWareHouseList"].arrayValue
            for val in arr {
                let bizName = val["USER_NAME"].stringValue
                let seq = val["BIZ_USER_SEQ"].stringValue
                let lat = val["BIZ_LAT"].doubleValue
                let lng = val["BIZ_LNG"].doubleValue
                let storage = MatchingStorage(name: bizName, address: "", seq: seq, lat: lat, lng: lng, distance: 0)
                self.matchingStoragesNearby.append(storage)
            }
            
            self.getAllStoragesNearby(lat: lat, lng: lng, storagesNearby: self.matchingStoragesNearby) {
                completion?(true, "")
            }
        }
    }
    
    // MARK: - 보관소 정보(맵에서 표시될) 요청
    /// 보관소 정보(맵에서 표시될) 요청
    func getStorage(currentLat: Double, currentLng: Double, storageSeq: String = "", word: String = "", reset: Bool = true, completion: ResponseString = nil) {
        
        // 보관소 시퀀스와 검색어가 모두 빈칸이면 검색하지않음
        if storageSeq.isEmpty && word.isEmpty { return }
        if false == word.isEmpty { enterWord(word: word, lat: currentLat, lng: currentLng)}
        
        if reset { storages.removeAll() }
        
        _cas.storageMap.getStorage(lat: currentLat, lng: currentLng, storageSeq: storageSeq, word: word) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "보관소 정보를 불러오지 못했습니다.", json: json))
                return
            }
            
            let val = json["searchWareHouse"]
            let category = val["CD_BIZ_TYPE"].stringValue
            let bizName = val["USER_NAME"].stringValue
            let address = val["BIZ_SIMPLE_ADDR"].stringValue
            let distance = val["DISTANCE"].doubleValue
            let rating = val["REVIEW_POINT_AVG"].doubleValue
            let available = val["AVAILABLE_YN"].boolValue
            let imgUrl = val["MAJOR_ATTACH_INFO"].stringValue
            let storageStatusText = val["WAREHOUSE_RATE_TEXT"].stringValue
            let lat = val["BIZ_LAT"].doubleValue
            let lng = val["BIZ_LNG"].doubleValue
            let seq = val["BIZ_USER_SEQ"].stringValue
//            let categoryName = val["BIZ_TYPE_TEXT"].stringValue
//            let storageStatus = val["WAREHOUSE_RATE"].stringValue
            
            if seq.isEmpty || (lat == 0 || lng == 0) {
                completion?(false, "")
                return
            }
            
            var storage = StorageMapData(name: bizName)
            storage.setCategory(category: category)
            storage.setAddress(address: address)
            storage.setRating(rating: rating)
            storage.setAvailable(available: available)
            storage.setDistance(distance: distance)
            storage.setImgUrl(imgUrl: imgUrl)
            storage.setStatus(status: storageStatusText)
            storage.setSeq(seq: storageSeq)
            storage.setLat(lat: lat)
            storage.setLng(lng: lng)
            storage.setSeq(seq: seq)
//            storage.setStatus(status: StorageCapacity.enough.rawValue)
            self.storages.append(storage)
            completion?(true, "")
        }
    }
    
    /// 주변 보관소 검색 후 받은 데이터들을 지도에 표시되는 데이터로 변환함
    func getAllStoragesNearby(lat: Double, lng: Double, storagesNearby: [MatchingStorage], completion: (() -> Void)? = nil) {
        let maxRequestCount: Int = storagesNearby.count
        guard maxRequestCount > 0 else { completion?(); return }
        var requestCount: Int = 0
        
        func getStorage(storage: MatchingStorage) {
//            self.getStorage(lat: lat, lng: lng, storageSeq: storage.seq) { (_, _) in
            self.getStorage(currentLat: lat, currentLng: lng, storageSeq: storage.seq, reset: false) { (_, _) in
                requestCount += 1
                
                if requestCount < storagesNearby.count {
                    getStorage(storage: storagesNearby[requestCount])
                } else {
                    completion?()
                }
            }
        }
        
        self.storages.removeAll()
        getStorage(storage: storagesNearby[requestCount])
    }
}

/*
 /// 여러개의 이미지를 순서대로 업로드함
 func uploadStoragePictures(imgDatas: [Data?], completion: ResponseString = nil) {
     let maxUploadCount: Int = imgDatas.count
     guard maxUploadCount > 0 else { completion?(true, ""); return }
     
     func upload(imgData: Data?, attachType: AttachType, completion: ResponseString = nil) {
         guard let imgData = imgData else {
             reUpload()
             return
         }
         
         uploadImage(imgData: imgData, attachType: attachType) { (success, msg) in
             _cas.storeinfo.registerStoragePicComplete(api: .registerStorePictureComplete, attachType: .storageInside, attachGrpSeq: self.attachGrpSeq) { (success, json) in
                 reUpload()
             }
             
             
         }
     }
     
     func reUpload() {
         if self.uploadedCount >= maxUploadCount - 1 {
             completion?(true, "")
             return
         }
         
         self.uploadedCount += 1
         upload(imgData: imgDatas[self.uploadedCount], attachType: .storageInside)
     }
     
     upload(imgData: imgDatas[uploadedCount], attachType: .storageInside)
 }
 */

