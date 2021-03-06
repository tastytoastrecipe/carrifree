//
//  LookupVm.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/12.
//
//
//  π¬ StorageMapVm
//  λ³΄κ΄ κ²μ νλ©΄ View Model
//

import Foundation

class StorageMapVm {
    
    var hotWords: [String] = []                         // λ§μ΄ κ²μν λ¨μ΄
    var storages: [StorageMapData] = []                 // μ§λμ νμλ λͺ¨λ  λ³΄κ΄μ
    var currentStorage: StorageMapData!                 // νμ¬ μ νλ λ³΄κ΄μ
    var matchingStoragesNearby: [MatchingStorage] = []  // κ²μλ μ£Όλ³ λ³΄κ΄μ (κ²μ ν μ§λμ νμλκΈ° μ  λ°μ΄ν°)
    
    init() {
//        setDummyDatas()
    }
    
    /*
    func setDummyDatas() {
        hotKeywords.append(contentsOf: ["κΉν¬κ³΅ν­", "μΈμ²κ³΅ν­", "μ μ£Όλ", "μμΈμ­", "μλ±ν¬μ­", "KTX", "μΉ΄ν", "μμ ", "μλΉ", "λͺ¨ν"])
        
        let storage01 = StorageMapData(category: StorageCategory.storage001.rawValue, address: "μμΈμ κ°μκ΅¬ ....", status: StorageCapacity.enough.rawValue, available: true, name: "λ³΄κ΄μ 01", imgUrl: "img-test-storage-0", distance: Double(Int.random(in: 0 ... 5)), rating: Double(Int.random(in: 0 ... 5)), lat: 37.559106, lng: 126.811840)
        
        let storage02 = StorageMapData(category: StorageCategory.storage001.rawValue, address: "μμΈμ κ°μκ΅¬ ....", status: StorageCapacity.enough.rawValue, available: true, name: "λ³΄κ΄μ 02", imgUrl: "img-test-storage-1", distance: Double(Int.random(in: 0 ... 5)), rating: Double(Int.random(in: 0 ... 5)), lat: 37.559139, lng: 126.810250)
        
        let storage03 = StorageMapData(category: StorageCategory.storage001.rawValue, address: "μμΈμ κ°μκ΅¬ ....", status: StorageCapacity.enough.rawValue, available: true, name: "λ³΄κ΄μ 03", imgUrl: "img-test-storage-2", distance: Double(Int.random(in: 0 ... 5)), rating: Double(Int.random(in: 0 ... 5)), lat: 37.559973, lng: 126.808829)
        
        let storage04 = StorageMapData(category: StorageCategory.storage001.rawValue, address: "μμΈμ κ°μκ΅¬ ....", status: StorageCapacity.enough.rawValue, available: true, name: "λ³΄κ΄μ 04", imgUrl: "img-test-storage-3", distance: Double(Int.random(in: 0 ... 5)), rating: Double(Int.random(in: 0 ... 5)), lat: 37.560849, lng: 126.808578)
        
        let storage05 = StorageMapData(category: StorageCategory.storage001.rawValue, address: "μμΈμ κ°μκ΅¬ ....", status: StorageCapacity.enough.rawValue, available: true, name: "λ³΄κ΄μ 05", imgUrl: "img-test-storage-4", distance: Double(Int.random(in: 0 ... 5)), rating: Double(Int.random(in: 0 ... 5)), lat: 37.560900, lng: 126.809903)
        
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
    
    // MARK: - κ²μμ΄ μλ ₯
    /// κ²μμ΄ μλ ₯
    func enterWord(word: String, lat: Double, lng: Double) {
        _cas.storageMap.enterWord(word: word, lat: lat, lng: lng)
    }
    
    // MARK: - λ§μ΄ κ²μν λ¨μ΄ μ‘°ν
    /// λ§μ΄ κ²μν λ¨μ΄ μ‘°ν
    func getHotWords(lat: Double, lng: Double, completion: ResponseString = nil) {
        //      [popularKeywordList]
        //      POPULAR_WORD            <String>        κ²μμ΄
        //      WORDCNT                 <Number>        κ²μλ νμ
        //      resCd                   <String>        κ²°κ³Ό μ½λ
        
        _cas.storageMap.getHotWords(lat: lat, lng: lng) { (success, json) in
            guard let json = json, true == success else {
                _log.log(ApiManager.getFailedMsg(defaultMsg: "λ§μ΄ κ²μλ λ¨μ΄ μ‘°ν μ€ν¨", json: json))
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
    
    
    // MARK: - μ£Όλ³μ λ³΄κ΄μ κ²μ
    /// μ£Όλ³μ λ³΄κ΄μ κ²μ
    func lookupStoragesNearby(lat: Double, lng: Double, completion: ResponseString = nil) {
        matchingStoragesNearby.removeAll()
        _cas.storageMap.lookupStoragesNearby(lat: lat, lng: lng) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "κ²μμ€ μ€λ₯κ° λ°μνμ΅λλ€.", json: json))
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
    
    // MARK: - λ³΄κ΄μ μ λ³΄(λ§΅μμ νμλ ) μμ²­
    /// λ³΄κ΄μ μ λ³΄(λ§΅μμ νμλ ) μμ²­
    func getStorage(currentLat: Double, currentLng: Double, storageSeq: String = "", word: String = "", reset: Bool = true, completion: ResponseString = nil) {
        
        // λ³΄κ΄μ μνμ€μ κ²μμ΄κ° λͺ¨λ λΉμΉΈμ΄λ©΄ κ²μνμ§μμ
        if storageSeq.isEmpty && word.isEmpty { return }
        if false == word.isEmpty { enterWord(word: word, lat: currentLat, lng: currentLng)}
        
        if reset { storages.removeAll() }
        
        _cas.storageMap.getStorage(lat: currentLat, lng: currentLng, storageSeq: storageSeq, word: word) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "λ³΄κ΄μ μ λ³΄λ₯Ό λΆλ¬μ€μ§ λͺ»νμ΅λλ€.", json: json))
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
    
    /// μ£Όλ³ λ³΄κ΄μ κ²μ ν λ°μ λ°μ΄ν°λ€μ μ§λμ νμλλ λ°μ΄ν°λ‘ λ³νν¨
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
 /// μ¬λ¬κ°μ μ΄λ―Έμ§λ₯Ό μμλλ‘ μλ‘λν¨
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

