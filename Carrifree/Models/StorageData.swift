//
//  StorageData.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/10.
//
//
//  💬 StorageData
//  저장소 데이터
//

import Foundation

typealias Schedule = (start: String, end: String)       // 주문 시작, 종료 시간
typealias Luggages = (s: Int, m: Int, l: Int, xl: Int)  // 짐 개수
typealias Coordinate = (lat: Double, lng: Double)       // 위치

// MARK: - StorageData
/// 메인화면에 보여질 보관소 데이터
struct StorageData: StorageSimple {
    var name: String
    var imgUrl: String
    var distance: Double
    var rating: Double
    var seq: String
}

// MARK: - StorageMapData
/// 맵에서 보여질 보관소 데이터
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
// 보관소 상세 데이터
struct StorageDetailData: StorageBase, StorageCard {
    var name: String = ""
    var category: String = ""
    var address: String = ""
    var imgUrls: [String] = []
    var rating: Double = 0
    var worktime: String = ""
    var dayoff: [Int] = []              // 쉬는 요일
    var holiday: Bool = true            // 공휴일에 휴무 여부 (현재 안쓰임)
    var merits: [String] = []
    var pr: String = ""
    var status: String = ""             // 보관상태 (StorageCapacity사용하지않고 임시로 현재 상태 text로 직접 받음)
    var available: Bool = true          // 보관소 이용가능 여부
    var defaultCosts: [CostData] = []   // 1일 이내의 가격
    var extraCosts: [CostData] = []     // 1일 이내의 가격
    var dayCosts: [CostData] = []       // 1일 이후의 가격
    var reviews: [ReviewData] = []      // 리뷰
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
/// 연관 검색어에 표시될 검색된 보관소
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
/// 보관소 기본 데이터
protocol StorageBase {
    var seq: String { get set }             // 보관소 시퀀스
    var lat: Double { get set }             // 위도
    var lng: Double { get set }             // 경도
}

// MARK: - (PR)StorageSimple
/// 간단한 보관소 데이터
protocol StorageSimple {
    var name: String { get set }
    var imgUrl: String { get set }
    var distance: Double { get set }
    var rating: Double { get set }
}

// MARK: - (PR)StorageMap
/// 보관소 맵 데이터 (검색화면의 맵)
protocol StorageMap: StorageBase {
    var category: String { get set }        // 업종
    var address: String { get set }         // 주소
    var status: String { get set }          // 보관상태 (StorageCapacity사용하지않고 임시로 현재 상태 text로 직접 받음)
    var available: Bool { get set }         // 보관소 이용가능 여부
}

// MARK: - (PR)StorageCard
/// 보관소 상세 화면의 보관소 정보
protocol StorageCard {
    var name: String { get set }
    var category: String { get set }
    var address: String  { get set }
    var imgUrls: [String] { get set }
    var rating: Double { get set }          // 리뷰 점수 (Ratings)
    var worktime: String { get set }        // 운영 시간
    var dayoff: [Int] { get set }           // 쉬는날 (Weekday)
    var holiday: Bool { get set }           // 공휴일 휴무 여부
    var merits: [String] { get set }        // 보관 장점 (StorageMerit)
    var pr: String { get set }              // 소개글
}

// MARK: - AlignNearStorage
/// 주변 보관소 정렬 방식
enum AlignNearStorage: String {
    case dist = "001"       // 거리순
    case avg = "002"        // 평점순
    
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

// MARK: - 매장정보의 각 코드 그룹
/// 매장정보의 각 코드 그룹
/// 은행, 업종, 보관장점, 요일 등
enum StorageCodeGroup: String {
    case bank = "001"           // 은행 코드
    case category = "002"       // 업종 코드
    case merit = "003"          // 보관장점 코드
    case weeks = "004"          // 요일 코드
}


// MARK: - 매장정보 코드 데이터
struct StorageCode {
    var grp: String             // 코드 그룹 (StorageCodeGroup)
    var code: String            // 코드
    var name: String            // 이름
}

// MARK: - 보관 시간 타입
/// 보관 시간 타입 (결제지 사용됨)
/// 24시간이 지나면 001, 24시간이 지나지 않으면 002
enum StorageDayType: String {
    case dayOver = "001"        // 24시간이 이상
    case dayIn = "002"          // 24시간 미만
    case none = ""
}
