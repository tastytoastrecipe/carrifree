//
//  StorageDoneVm.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/08.
//

import Foundation

protocol StorageDoneVmDelegate {
    func ready()
}

class StorageDoneVm {
    var delegate: StorageDoneVmDelegate?
    var orderNo: String = ""
    var bizName: String = ""
    var schedule: (start: String, end: String) = ("", "")
    var luggages: (s: Int, m: Int, l: Int, xl: Int) = (0, 0, 0, 0)
    var cost: Int = 0               // 결제요금
    var careCost: Int = 0           // 지원요금
    
    init(delegate: StorageDoneVmDelegate?) {
        self.delegate = delegate
        setDummyData()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            self.delegate?.ready()
        }
    }
    
    func setDummyData() {
        orderNo = "20211231121"
        bizName = "장인! 수타 짜장면"
        schedule.start = "2022-02-10 / 10:30"
        schedule.end = "2022-02-10 / 13:00"
        luggages.s = 1
        luggages.m = 0
        luggages.l = 1
        luggages.xl = 0
        cost = 7000
        careCost = 1000
    }
}
