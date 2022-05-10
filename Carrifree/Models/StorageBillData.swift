//
//  StorageBillData.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/09.
//
//
//  💬 StorageBillData
//  주문 내역 관련 데이터 모음
//

// MARK: - 보관 주문 기본 데이터
/// 사용내역 목록에서 보여지는 주문의 기본 정보
struct StorageBillData: StorageBillSimple {
    var orderSeq: String
    var orderCase: Int
    var orderStatus: String
    var orderNo: String
    var bizName: String
    var address: String
    var orderDate: String
}

// MARK: - 보관 주문 상세 데이터
/// 사용 내역 상세 화면에 보여지는 정보
struct StorageBillDocData: StorageBillSimple, StorageBillDoc {
    var storageSeq: String = ""
    var orderSeq: String = ""
    var orderCase: Int = OrderCase.none.rawValue
    var orderStatus: String = OrderStatus.none.rawValue
    var orderNo: String = ""
    var bizName: String = ""
    var address: String = ""
    var orderDate: String = ""
    var category: String = ""
    var lat: Double = 0
    var lng: Double = 0
    var worktime: String = ""
    var dayoff: [Int] = []
    var holiday: Bool = true
    var schedule: Schedule = (start: "", end: "")
    var luggages: Luggages = (s: 0, m: 0, l: 0, xl: 0)
    var imgUrls: [String] = []
    var comment: String = ""
    var cost: Int = 0
    var attachGrpSeq: String = ""
    
    init(storageSeq: String, orderSeq: String, orderCase: Int, orderStatus: String, orderNo: String, bizName: String, address: String, orderDate: String, category: String, lat: Double, lng: Double, worktime: String, dayoff: [Int], holiday: Bool, schedule: Schedule, luggages: Luggages, imgUrls: [String], comment: String, cost: Int, attachGrpSeq: String) {
        self.storageSeq = storageSeq
        self.orderSeq = orderSeq
        self.orderCase = orderCase
        self.orderStatus = orderStatus
        self.orderNo = orderNo
        self.bizName = bizName
        self.address = address
        self.orderDate = orderDate
        self.category = category
        self.lat = lat
        self.lng = lng
        self.worktime = worktime
        self.dayoff = dayoff
        self.holiday = holiday
        self.schedule = schedule
        self.luggages = luggages
        self.imgUrls = imgUrls
        self.comment = comment
        self.cost = cost
        self.attachGrpSeq = attachGrpSeq
    }
    
    init(orderNo: String) { self.orderNo = orderNo }
    
    mutating func setStorageSeq(storageSeq: String) { self.storageSeq = storageSeq }
    mutating func setOrderSeq(orderSeq: String) { self.orderSeq = orderSeq }
    mutating func setOrderCase(orderCase: Int) { self.orderCase = orderCase }
    mutating func setOrderStatus(orderStatus: String) { self.orderStatus = orderStatus }
    mutating func setOrderNo(orderNo: String) { self.orderNo = orderNo }
    mutating func setBizName(bizName: String) { self.bizName = bizName }
    mutating func setAddress(address: String) { self.address = address }
    mutating func setOrderDate(orderDate: String) { self.orderDate = orderDate }
    mutating func setCategory(category: String) { self.category = category }
    mutating func setLat(lat: Double) { self.lat = lat }
    mutating func setLng(lng: Double) { self.lng = lng }
    mutating func setWorktime(worktime: String) { self.worktime = worktime }
    mutating func setDayoff(dayoff: [Int]) { self.dayoff = dayoff }
    mutating func setHoliday(holiday: Bool) { self.holiday = holiday }
    mutating func setSchedule(schedule: Schedule) { self.schedule = schedule }
    mutating func setLuggages(luggages: Luggages) { self.luggages = luggages }
    mutating func setImgUrls(imgUrls: [String]) { self.imgUrls = imgUrls }
    mutating func setComment(comment: String) { self.comment = comment }
    mutating func setCost(cost: Int) { self.cost = cost }
    mutating func setAttachGrpSeq(attachGrpSeq: String) { self.attachGrpSeq = attachGrpSeq }
    
}

// MARK: - (PR)StorageBillSimple
/// 사용내역 목록에서 보여지는 보관 주문의 기본 정보
protocol StorageBillSimple {
    var orderSeq: String { get set }        // 주문 시퀀스
    var orderCase: Int { get set }          // 주문 종류 (OrderCase)
    var orderStatus: String { get set }     // 주문 진행 상태 (OrderStatus)
    var orderNo: String { get set }         // 주문 번호
    var bizName: String { get set }         // 매장(보관소) 이름
    var address: String { get set }         // 매장(보관소) 주소
    var orderDate: String { get set }       // 요청일
}

// MARK: - (PR)StorageBillDetail
/// 사용내역 상세 화면에서 보여질 보관 주문의 추가 정보
protocol StorageBillDoc {
    var storageSeq: String { get set }      // 보관소 시퀀스
    var category: String { get set }        // 업종
    var address: String { get set }         // 주소
    var lat: Double { get set }             // 위도
    var lng: Double { get set }             // 경도
    var worktime: String { get set }        // 운영 시간
    var dayoff: [Int] { get set }           // 쉬는날 (Weekday)
    var holiday: Bool { get set }           // 공휴일 휴무 여부
    var schedule: Schedule { get set }      // 주문 시작, 종료 시간
    var luggages: Luggages { get set }      // 짐 개수
    var imgUrls: [String] { get set }       // 짐 사진
    var comment: String { get set }         // 요청사항
    var cost: Int { get set }               // 결제금액
    var attachGrpSeq: String { get set }    // 첨부파일 그룹 시퀀스
}
