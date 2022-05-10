//Aㅂ  ㅈㅂㅁㅋㅌㅊㄹㅎ쇽5ㅅㄷㄱㄴㅇㄹ튜푸ㅡㅏㅣ;ㅐㅔㅑㅓㅏㅡ, ."
//
//  Weekday.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/11/01.
//

import Foundation

// MARK:- Weekday
@objc enum Weekday: Int, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednsday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case none = 8
    
    var name: String {
        switch self {
        case .sunday: return _strings[.sunday]
        case .monday: return _strings[.monday]
        case .tuesday: return _strings[.tuesday]
        case .wednsday: return _strings[.wendsday]
        case .thursday: return _strings[.thursday]
        case .friday: return _strings[.friday]
        case .saturday: return _strings[.saturday]
        default: return ""
        }
    }
    
    var type: String {
        switch self {
        case .sunday: return "007"
        case .monday: return "001"
        case .tuesday: return "002"
        case .wednsday: return "003"
        case .thursday: return "004"
        case .friday: return "005"
        case .saturday: return "006"
        case .none: return ""
        }
    }
    
    static func getWeekday(type: String) -> Weekday {
        switch type {
        case Weekday.sunday.type: return .sunday
        case Weekday.monday.type: return .monday
        case Weekday.tuesday.type: return .tuesday
        case Weekday.wednsday.type: return .wednsday
        case Weekday.thursday.type: return .thursday
        case Weekday.friday.type: return .friday
        case Weekday.saturday.type: return .saturday
        default: return .none
        }
    }
}
