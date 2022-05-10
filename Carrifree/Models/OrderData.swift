//
//  Order.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/09.
//
//
//  💬 Order
//  주문과 관련된 데이터 모음
//



// MARK: - 의뢰 종류
/// 보관, 운반 의뢰 구분
/*
enum OrderCase: Int {
    case none = 0
    case storage     // 보관 의뢰
    case carry       // 운반 의뢰
    
    var name: String {
        switch self {
        case .storage: return "보관"
        case .carry: return "운반"
        default: return ""
        }
    }
}
*/

@objc enum OrderCase: Int {
    case none = 0
    case storage            // 보관
    case carry              // 운반
    
    case reservation        // 예약
    case realtime           // 실시간
    case estimate           // 가격 요청
    case waitingRealtime    // 대기중인 실시간 요청
    case waitingEstimate    // 대기중인 견적 요청
    case direct             // 직영 운반사업자
    
    var name: String {
        switch self {
        case .storage: return "보관"
        case .carry: return "운반"
        default: return ""
        }
    }
    
    var type: String {
        switch self {
        case .realtime, .waitingRealtime: return "001"
        case .reservation:                return "002"
        case .estimate, .waitingEstimate: return "003"
        case .storage:                    return "004"
        case .direct:                     return "005"
        default:                          return ""
        }
    }
    
    static func getCase(type: String) -> OrderCase {
        switch type {
        case OrderCase.storage.type: return OrderCase.storage
        case OrderCase.carry.type: return OrderCase.carry
        default: return OrderCase.none
        }
    }
    
    static func getType(orderCase: Int) -> String {
        switch orderCase {
        case OrderCase.storage.rawValue: return OrderCase.storage.type
        case OrderCase.carry.rawValue: return OrderCase.carry.type
        default: return OrderCase.none.type
        }
    }
}

// MARK: - 보관소 사용 유형
enum UsingStorageCase: String {
    case no     = "001"      // 출발지점, 도착지점 모두 보관소 아님
    case all    = "002"      // 출발지점, 도착지점 모두 보관소
    case start  = "003"      // 출발지점만 보관소
    case end    = "004"      // 도착지점만 보관소
}


// MARK: - 의뢰 진행 상황
/// 의뢰 진행 상황
enum OrderStatus: String {
                            // (맡길때 006, 찾을때 008 보내면됨)
    case reserved = "002"   // 002: 결제 완료(최초상태)
    case entrust  = "006"   // 006: 사용자가 짐을 맡기고 난후 처리 상태
    case delivery = "004"   // 004: 운송사업자가 짐을 받아 배송중인 상태
    case arrive   = "005"   // 005: 운송사업자가 짐을 배송 완료한 상태
    case take     = "008"   // 008: 사용자가 짐을 찾아 업무가 종료된 상태
    case auth     = "007"   // 007: 운송사업자든 일반사용자든 짐을 찾기 위해 인증하는 상태 (비밀번호를 넣어 물건 찾을 사람을 인증 한 상태)
    case canceled = "003"   // 003: 주문이 취소된 상태
    case none     = ""
    
    var storageStatusText: String {
        switch self {
        case .delivery: return "배송중"
        case .reserved: return "예약"
        case .entrust: return "진행"
        case .take: return "완료"
        case .canceled: return "취소"
        default: return ""
        }
    }
    
    var storageBillTitle: String {
        switch self {
        case .delivery: return "짐이 배송중입니다."
        case .reserved: return "예약 상태입니다."
        case .entrust: return "보관이 진행중 입니다."
        case .take: return "완료 상태 입니다."
        case .canceled: return "취소된 주문입니다."
        default: return ""
        }
    }
    
    var storageBillDesc: String {
        switch self {
        case .reserved: return "보관파트너가 확인을 하면, 진행 상태로 변경 됩니다."
        case .entrust: return "보관파트너가 짐을 반출하면 금액이 자동으로 정산됩니다."
        case .take: return "결제정보가 다른경우, 기존 요금이 취소되고 재결제 됩니다."
        case .canceled: return "짐 보관 취소에 대한 자세한 내역은 아래에서 확인 가능합니다."
        default: return ""
        }
    }
    
    var storageScheduleDesc: String {
        switch self {
        case .reserved: return "해당 스케쥴은 반드시 지킬 필요는 없습니다. 종료 예정 시간내 보관이 진행되지 않으면 자동 으로 취소 됩니다."
        case .entrust: return "종료 예정 시간 이후 반출될 시 추가 요금이 발생 됩니다."
        case .take: return "보관이 완료되면 실제 ‘보관시간’ 시간과 ’보관종료’ 시간으로 변경됩니다."
        case .canceled: return "보관이 완료되면 실제 ‘보관시간’ 시간과 ’보관종료’ 시간으로 변경됩니다."
        default: return ""
        }
    }

    
    
}
