//
//  StorageBillVm.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/11.
//
//
//  💬 StorageBillVm
//  사용 내역 '상세' 화면 View Model
//

/*
import Foundation

protocol StorageBillVmDelegate {
    func ready()
}

class StorageBillVm {
    
    var delegate: StorageBillVmDelegate?
    var data: StorageBillDocData!
    let maxPictureCount: Int = 10
    
    init(delegate: StorageBillVmDelegate?) {
        self.delegate = delegate
        setDummyDatas()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            self.delegate?.ready()
        }
    }
    
    func setDummyDatas() {
        data = StorageBillDocData(orderNo: "20000000001")
        data.setOrderCase(orderCase: OrderCase.storage.rawValue)
        data.setOrderStatus(orderStatus: OrderStatus.reserved.rawValue)
        data.setBizName(bizName: "짜파게티 요리사")
        data.setAddress(address: "서울 용산구 이촌로75길 10-3")
        data.setOrderDate(orderDate: "2022-02-16 17:30")
        data.setCategory(category: StorageCategory.storage001.rawValue)
        data.setLat(lat: 37.520388)
        data.setLng(lng: 126.974350)
        data.setWorktime(worktime: "10:00 ~ 20:00")
        data.setDayoff(dayoff: [Weekday.sunday.rawValue, Weekday.monday.rawValue])
        data.setHoliday(holiday: true)
        data.setSchedule(schedule: Schedule(start: "2022-02-14  11:00", end: "2022-02-14  13:00"))
        data.setLuggages(luggages: Luggages(s: 0, m: 1, l: 2, xl:0))
        data.setImgUrls(imgUrls: ["https://t1.daumcdn.net/cfile/tistory/9940AE3C5A765A881A",
             "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTsKYp1Kav7T3nYgcQomfbBWQd9FY5CGSgJeNj4Ydy3inBOMu-TMn9dFR5EqBdOnaqYp6k&usqp=CAU",
             "https://recipe1.ezmember.co.kr/cache/recipe/2021/10/28/0240f6da1381ee94cad48102c63787281.jpg",
             "https://blog.kakaocdn.net/dn/cvUGS6/btqRAktUP6E/kA3jVyqW0Bvi29srdPRkw1/img.jpg",
             "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcREiEDDzAt0yGk5xFrgz3ztt66HbCmyKfgAcvQucGiS7u4rwposQVm_QFN6arv7It2b53k&usqp=CAU",
                                  ])
        data.setComment(comment: "ㅎ2")
        data.setCost(cost: 13000)
        
    }
}
*/

