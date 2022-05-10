//
//  BillsVm.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/09.
//
//
//  💬 BillsVm
//  사용 내역 화면 View Model
//

import Foundation

typealias MonthlyBills = (title: String, bills: [StorageBillData])

class BillsVm {
    var datas: [MonthlyBills] = []          // 현재까지 서버에서 받은 모든 내역
    var currentDatas: [MonthlyBills] = []   // 화면에 표시될 내역
    var currentOrderStatus: String = ""     // 현재 선택된 주문 상태
    
    init() {
//        setDummyDatas()
    }
    
    func setDummyDatas() {
        let monthlyHistory01 = MonthlyBills("2022.02.10",
        [
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.reserved.rawValue, orderNo: "200000001", bizName: "한뚝배기", address: "서울 강남구 강남구청역 3번출구 도보 50m", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.entrust.rawValue, orderNo: "200000002", bizName: "두뚝배기", address: "서울 구로구 구로중앙로 152", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.take.rawValue, orderNo: "200000003", bizName: "세뚝배기", address: "서울 강서구 양천로75길 19", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.canceled.rawValue, orderNo: "200000004", bizName: "네뚝배기", address: "서울 마포구 용강동 45-15", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.reserved.rawValue, orderNo: "200000005", bizName: "다섯뚝배기", address: "서울 성동구 성수일로8길 47", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.entrust.rawValue, orderNo: "200000006", bizName: "여섯뚝배기", address: "서울 노원구 노해로75길 14-20", orderDate: Date().localDate.toOrderDateString())
        ])
        
        let monthlyHistory02 = MonthlyBills("2022.02.09",
        [
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.reserved.rawValue, orderNo: "200000001", bizName: "일곱뚝배기", address: "서울 강남구 강남구청역 3번출구 도보 50m", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.entrust.rawValue, orderNo: "200000002", bizName: "여덟뚝배기", address: "서울 구로구 구로중앙로 152", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.take.rawValue, orderNo: "200000003", bizName: "아홉뚝배기", address: "서울 강서구 양천로75길 19", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.canceled.rawValue, orderNo: "200000004", bizName: "열뚝배기", address: "서울 마포구 용강동 45-15", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.reserved.rawValue, orderNo: "200000005", bizName: "열한뚝배기", address: "서울 성동구 성수일로8길 47", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.entrust.rawValue, orderNo: "200000006", bizName: "열두뚝배기", address: "서울 노원구 노해로75길 14-20", orderDate: Date().localDate.toOrderDateString())
        ])
        
        let monthlyHistory03 = MonthlyBills("2022.02.07",
        [
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.reserved.rawValue, orderNo: "200000001", bizName: "열세뚝배기", address: "서울 강남구 강남구청역 3번출구 도보 50m", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.entrust.rawValue, orderNo: "200000002", bizName: "열네뚝배기", address: "서울 구로구 구로중앙로 152", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.take.rawValue, orderNo: "200000003", bizName: "열다섯뚝배기", address: "서울 강서구 양천로75길 19", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.canceled.rawValue, orderNo: "200000004", bizName: "열여섯뚝배기", address: "서울 마포구 용강동 45-15", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.reserved.rawValue, orderNo: "200000005", bizName: "열일곱섯뚝배기", address: "서울 성동구 성수일로8길 47", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.entrust.rawValue, orderNo: "200000006", bizName: "열여덟뚝배기", address: "서울 노원구 노해로75길 14-20", orderDate: Date().localDate.toOrderDateString())
        ])
        
        let monthlyHistory04 = MonthlyBills("2022.02.06",
        [
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.reserved.rawValue, orderNo: "200000001", bizName: "열아홉뚝배기", address: "서울 강남구 강남구청역 3번출구 도보 50m", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.entrust.rawValue, orderNo: "200000002", bizName: "스무뚝배기", address: "서울 구로구 구로중앙로 152", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.take.rawValue, orderNo: "200000003", bizName: "스물하나뚝배기", address: "서울 강서구 양천로75길 19", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.canceled.rawValue, orderNo: "200000004", bizName: "스물두뚝배기", address: "서울 마포구 용강동 45-15", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.reserved.rawValue, orderNo: "200000005", bizName: "스물세뚝배기", address: "서울 성동구 성수일로8길 47", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.entrust.rawValue, orderNo: "200000006", bizName: "스물네뚝배기", address: "서울 노원구 노해로75길 14-20", orderDate: Date().localDate.toOrderDateString())
        ])
        
        let monthlyHistory05 = MonthlyBills("2022.02.03",
        [
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.reserved.rawValue, orderNo: "200000001", bizName: "스물다섯뚝배기", address: "서울 강남구 강남구청역 3번출구 도보 50m", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.entrust.rawValue, orderNo: "200000002", bizName: "스물여섯뚝배기", address: "서울 구로구 구로중앙로 152", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.take.rawValue, orderNo: "200000003", bizName: "스물일곱뚝배기", address: "서울 강서구 양천로75길 19", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.canceled.rawValue, orderNo: "200000004", bizName: "스물여덟뚝배기", address: "서울 마포구 용강동 45-15", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.reserved.rawValue, orderNo: "200000005", bizName: "스물아홉뚝배기", address: "서울 성동구 성수일로8길 47", orderDate: Date().localDate.toOrderDateString()),
            StorageBillData(orderSeq: "", orderCase: OrderCase.storage.rawValue, orderStatus: OrderStatus.entrust.rawValue, orderNo: "200000006", bizName: "서른뚝배기", address: "서울 노원구 노해로75길 14-20", orderDate: Date().localDate.toOrderDateString())
        ])
        
        datas.append(monthlyHistory01)
        datas.append(monthlyHistory02)
        datas.append(monthlyHistory03)
        datas.append(monthlyHistory04)
        datas.append(monthlyHistory05)
    }
    
    func reset() {
        datas.removeAll()
        currentDatas.removeAll()
    }
    
    /// 전체 주문에서 사용자가 선택한 상태의 주문을 목록으로 반환함
    func setCurrentDatas(orderStatus: String) {
        currentDatas.removeAll()
        currentOrderStatus = orderStatus
        guard let orderStatus = OrderStatus(rawValue: orderStatus), orderStatus != .none else { currentDatas = datas; return }
        
        for data in datas {
            var matches: [StorageBillData] = []
            
            // '완료'일 경우 '완료'와 '취소' 상태의 주문을 모두 넣는다
            if orderStatus == .take {
                matches = data.bills.filter({ ($0.orderStatus == OrderStatus.take.rawValue || $0.orderStatus == OrderStatus.canceled.rawValue) })
            }
            // 완료 이외의 상태는 해당 상태의 주문을 넣는다
            else {
                matches = data.bills.filter({ $0.orderStatus == orderStatus.rawValue })
            }
            
            if matches.isEmpty { continue }
            let monthlyBills = MonthlyBills(data.title, matches)
            currentDatas.append(monthlyBills)
        }
    }
    
    /// 데이터 추가
    func insertData(newData: MonthlyBills) {
        if newData.title.isEmpty || newData.bills.isEmpty { return }
        
        guard let _ = datas.filter({ $0.title == newData.title }).first else {
            datas.append(newData)
            return
        }
        
        for i in 0 ..< datas.count {
            if datas[i].title == newData.title { datas[i].bills = newData.bills }
        }
    }
    
    /// 특정 월의 데이터 반환
    func getMonthBills(month: String, orderStatus: String) -> [StorageBillData] {
        guard let allBills = datas.filter({ $0.title == month }).first?.bills else {
            return []
        }
        
        if orderStatus.isEmpty { return allBills }
        
        let matchingBills = allBills.filter({ $0.orderStatus == orderStatus })
        return matchingBills
    }
    
    // MARK: - 주문 내역이 있는 년/월 조회
    /// 주문 내역이 있는 년/월 조회
    func getMonths(orderStatus: String, completion: ResponseString = nil) {
        self.datas.removeAll()
        _cas.bills.getMonths(orderStatus: orderStatus) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "주문 내역을 불러오지 못했습니다.", json: json))
                return
            }
            
            let arr = json["orderYearMonthList"].arrayValue.reversed()
            for val in arr {
                let month = val["ORDER_YEAR_MONTH"].stringValue
                let monthlyBills = MonthlyBills(title: month, bills: [])
                self.datas.append(monthlyBills)
            }
            
            completion?(true, "")
        }
    }
    
    // MARK: - 주문 내역 조회
    /// 주문 내역 조회
    func getBills(month: String, orderStatus: String, completion: ResponseString = nil) {
        _cas.bills.getBills(month: month, orderStatus: orderStatus) { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "주문 내역을 불러오지 못했습니다.", json: json))
                return
            }
            
            var bills: [StorageBillData] = []
            var billTitle: String = ""
            let arr = json["orderInfoList"].arrayValue
            for val in arr {
                let orderStatus = val["ORDER_STATUS"].stringValue
                guard let status = OrderStatus(rawValue: orderStatus), status != .none else { continue }
                
                billTitle = val["ORDER_YEAR_MONTH"].stringValue
                let orderSeq = val["ORDER_SEQ"].stringValue
                let orderCaseStr = val["ORDER_KIND"].stringValue
                let orderCase = OrderCase.getCase(type: orderCaseStr)
                let orderNo = val["DELIVERY_NO"].stringValue
                let bizName = val["BIZ_NAME"].stringValue
                let address = val["BIZ_SIMPLE_ADDR"].stringValue
                
                let orderDateDouble = val["ORDER_DATE"].doubleValue / 1000
                let orderDate = Date(timeIntervalSince1970: orderDateDouble)
                let orderDateStr = orderDate.toString()
                
                let billData = StorageBillData(orderSeq: orderSeq, orderCase: orderCase.rawValue, orderStatus: orderStatus, orderNo: orderNo, bizName: bizName, address: address, orderDate: orderDateStr)
                
                bills.append(billData)
            }
            
            self.insertData(newData: MonthlyBills(title: billTitle, bills: bills))
            completion?(true, "")
        }
    }
}
