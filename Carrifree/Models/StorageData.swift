//
//  StorageData.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/10.
//
//
//  π¬ StorageData
//  μ μ₯μ λ°μ΄ν°
//

import Foundation

typealias Schedule = (start: String, end: String)       // μ£Όλ¬Έ μμ, μ’λ£ μκ°
typealias Luggages = (s: Int, m: Int, l: Int, xl: Int)  // μ§ κ°μ
typealias Coordinate = (lat: Double, lng: Double)       // μμΉ

// MARK: - StorageData
/// λ©μΈνλ©΄μ λ³΄μ¬μ§ λ³΄κ΄μ λ°μ΄ν°
struct StorageData: StorageSimple {
    var name: String
    var imgUrl: String
    var distance: Double
    var rating: Double
    var seq: String
}

// MARK: - StorageMapData
/// λ§΅μμ λ³΄μ¬μ§ λ³΄κ΄μ λ°μ΄ν°
struct StorageMapData: StorageSimple, StorageMap, Equatable {
    var category: String = ""
    var address: String = ""
    var status: String = ""
    var available: Bool = false
    var name: String = ""
    var imgUrl: String = ""
    var distance: Double = 0
    var rating: Double = 0
    var lat: Double = 0
    var lng: Double = 0
    var seq: String = ""
    
    init(category: String, address: String, status: String, available: Bool, name: String, imgUrl: String, distance: Double, rating: Double, lat: Double, lng: Double, seq: String = "") {
        self.category = category; self.address = address; self.status = status; self.available = available; self.name = name; self.imgUrl = imgUrl; self.distance = distance; self.rating = rating; self.lat = lat; self.lng = lng
    }
    
    init(name: String) {
        setName(name: name)
    }
    
    mutating func setName(name: String) { self.name = name }
    mutating func setAddress(address: String) { self.address = address }
    mutating func setStatus(status: String) { self.status = status }
    mutating func setAvailable(available: Bool) { self.available = available }
    mutating func setCategory(category: String) { self.category = category }
    mutating func setImgUrl(imgUrl: String) { self.imgUrl = imgUrl }
    mutating func setDistance(distance: Double) { self.distance = distance }
    mutating func setRating(rating: Double) { self.rating = rating }
    mutating func setLat(lat: Double) { self.lat = lat }
    mutating func setLng(lng: Double) { self.lng = lng }
    mutating func setSeq(seq: String) { self.seq = seq }
    
}

extension StorageMapData {
    static func ==(lhs: StorageMapData, rhs: StorageMapData) -> Bool {
        if lhs.name == rhs.name && lhs.lat == rhs.lat && lhs.lng == rhs.lng {
            return true
        }
        return false
    }
}

// MARK: - StorageDetail
// λ³΄κ΄μ μμΈ λ°μ΄ν°
struct StorageDetailData: StorageBase, StorageCard {
    var name: String = ""
    var category: String = ""
    var address: String = ""
    var imgUrls: [String] = []
    var rating: Double = 0
    var worktime: String = ""
    var dayoff: [Int] = []              // μ¬λ μμΌ
    var holiday: Bool = true            // κ³΅ν΄μΌμ ν΄λ¬΄ μ¬λΆ (νμ¬ μμ°μ)
    var merits: [String] = []
    var pr: String = ""
    var status: String = ""             // λ³΄κ΄μν (StorageCapacityμ¬μ©νμ§μκ³  μμλ‘ νμ¬ μν textλ‘ μ§μ  λ°μ)
    var available: Bool = true          // λ³΄κ΄μ μ΄μ©κ°λ₯ μ¬λΆ
    var defaultCosts: [CostData] = []   // 1μΌ μ΄λ΄μ κ°κ²©
    var extraCosts: [CostData] = []     // 1μΌ μ΄λ΄μ κ°κ²©
    var dayCosts: [CostData] = []       // 1μΌ μ΄νμ κ°κ²©
    var reviews: [ReviewData] = []      // λ¦¬λ·°
    var seq: String = ""
    var lat: Double = 0
    var lng: Double = 0
    var masterSeq: String = ""
    
    init(name: String,
         category: String,
         address: String,
         imgUrls: [String],
         rating: Double,
         worktime: String,
         dayoff: [Int],
         holiday: Bool,
         merits: [String],
         pr: String,
         status: String,
         available: Bool,
         defaultCosts: [CostData],
         extraCosts: [CostData],
         dayCosts: [CostData],
         reviews: [ReviewData],
         masterSeq: String = "",
         seq: String = "",
         lat: Double = 0,
         lng: Double = 0) {
        self.name = name; self.category = category; self.address = address; self.imgUrls = imgUrls; self.rating = rating; self.worktime = worktime; self.dayoff = dayoff; self.holiday = holiday; self.merits = merits; self.pr = pr; self.status = status; self.available = available; self.defaultCosts = defaultCosts; self.extraCosts = extraCosts; self.dayCosts = dayCosts; self.reviews = reviews; self.masterSeq = masterSeq; self.seq = seq; self.lat = lat; self.lng = lng
    }
    
    init(name: String) {
        self.name = name
    }
    
    mutating func setName(name: String)                     { self.name = name }
    mutating func setCategory(category: String)             { self.category = category }
    mutating func setAddress(address: String)               { self.address = address }
    mutating func setImgUrls(imgUrls: [String])             { self.imgUrls = imgUrls }
    mutating func setRating(rating: Double)                 { self.rating = rating }
    mutating func setWorktime(worktime: String)             { self.worktime = worktime }
    mutating func setDayoff(dayoff: [Int])                  { self.dayoff = dayoff }
    mutating func setHoliday(holiday: Bool)                 { self.holiday = holiday }
    mutating func setMerits(merits: [String])               { self.merits = merits }
    mutating func setPr(pr: String)                         { self.pr = pr }
    mutating func setStatus(status: String)                 { self.status = status }
    mutating func setAvailable(available: Bool)             { self.available = available }
    mutating func setDefaultCosts(defaultCosts: [CostData]) { self.defaultCosts = defaultCosts }
    mutating func setExtraCosts(extraCosts: [CostData])     { self.extraCosts = extraCosts }
    mutating func setDayCosts(dayCosts: [CostData])         { self.dayCosts = dayCosts }
    mutating func setReviews(reviews: [ReviewData])         { self.reviews = reviews }
    mutating func setMasterSeq(masterSeq: String)           { self.masterSeq = masterSeq }
    mutating func setSeq(seq: String)                       { self.seq = seq }
    mutating func setLat(lat: Double)                       { self.lat = lat }
    mutating func setLng(lng: Double)                       { self.lng = lng }
}

// MARK: - MatchingStorage
/// μ°κ΄ κ²μμ΄μ νμλ  κ²μλ λ³΄κ΄μ
@objc class MatchingStorage: NSObject, StorageBase {
    var seq: String
    var lat: Double
    var lng: Double
    var name: String
    var address: String
    var distance: Double
    
    init(name: String, address: String, seq: String, lat: Double, lng: Double, distance: Double) {
        self.name = name; self.seq = seq; self.lat = lat; self.lng = lng; self.address = address; self.distance = distance
    }
}


// MARK: - (PR)StorageBase
/// λ³΄κ΄μ κΈ°λ³Έ λ°μ΄ν°
protocol StorageBase {
    var seq: String { get set }             // λ³΄κ΄μ μνμ€
    var lat: Double { get set }             // μλ
    var lng: Double { get set }             // κ²½λ
}

// MARK: - (PR)StorageSimple
/// κ°λ¨ν λ³΄κ΄μ λ°μ΄ν°
protocol StorageSimple {
    var name: String { get set }
    var imgUrl: String { get set }
    var distance: Double { get set }
    var rating: Double { get set }
}

// MARK: - (PR)StorageMap
/// λ³΄κ΄μ λ§΅ λ°μ΄ν° (κ²μνλ©΄μ λ§΅)
protocol StorageMap: StorageBase {
    var category: String { get set }        // μμ’
    var address: String { get set }         // μ£Όμ
    var status: String { get set }          // λ³΄κ΄μν (StorageCapacityμ¬μ©νμ§μκ³  μμλ‘ νμ¬ μν textλ‘ μ§μ  λ°μ)
    var available: Bool { get set }         // λ³΄κ΄μ μ΄μ©κ°λ₯ μ¬λΆ
}

// MARK: - (PR)StorageCard
/// λ³΄κ΄μ μμΈ νλ©΄μ λ³΄κ΄μ μ λ³΄
protocol StorageCard {
    var name: String { get set }
    var category: String { get set }
    var address: String  { get set }
    var imgUrls: [String] { get set }
    var rating: Double { get set }          // λ¦¬λ·° μ μ (Ratings)
    var worktime: String { get set }        // μ΄μ μκ°
    var dayoff: [Int] { get set }           // μ¬λλ  (Weekday)
    var holiday: Bool { get set }           // κ³΅ν΄μΌ ν΄λ¬΄ μ¬λΆ
    var merits: [String] { get set }        // λ³΄κ΄ μ₯μ  (StorageMerit)
    var pr: String { get set }              // μκ°κΈ
}

// MARK: - AlignNearStorage
/// μ£Όλ³ λ³΄κ΄μ μ λ ¬ λ°©μ
enum AlignNearStorage: String {
    case dist = "001"       // κ±°λ¦¬μ
    case avg = "002"        // νμ μ
    
    var index: Int {
        switch self {
        case .dist: return 0
        case .avg: return 1
        }
    }
    
    static func getAlign(index: Int) -> AlignNearStorage {
        switch index {
        case AlignNearStorage.dist.index: return .dist
        case AlignNearStorage.avg.index: return .avg
        default: return .dist
        }
    }
}

// MARK: - λ§€μ₯μ λ³΄μ κ° μ½λ κ·Έλ£Ή
/// λ§€μ₯μ λ³΄μ κ° μ½λ κ·Έλ£Ή
/// μν, μμ’, λ³΄κ΄μ₯μ , μμΌ λ±
enum StorageCodeGroup: String {
    case bank = "001"           // μν μ½λ
    case category = "002"       // μμ’ μ½λ
    case merit = "003"          // λ³΄κ΄μ₯μ  μ½λ
    case weeks = "004"          // μμΌ μ½λ
}


// MARK: - λ§€μ₯μ λ³΄ μ½λ λ°μ΄ν°
struct StorageCode {
    var grp: String             // μ½λ κ·Έλ£Ή (StorageCodeGroup)
    var code: String            // μ½λ
    var name: String            // μ΄λ¦
}

// MARK: - λ³΄κ΄ μκ° νμ
/// λ³΄κ΄ μκ° νμ (κ²°μ μ§ μ¬μ©λ¨)
/// 24μκ°μ΄ μ§λλ©΄ 001, 24μκ°μ΄ μ§λμ§ μμΌλ©΄ 002
enum StorageDayType: String {
    case dayOver = "001"        // 24μκ°μ΄ μ΄μ
    case dayIn = "002"          // 24μκ° λ―Έλ§
    case none = ""
}
