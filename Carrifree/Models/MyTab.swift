//
//  MyTabs.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/11/09.
//

import Foundation

enum MyTab: Int, CaseIterable {
    case home = 0
    case storage
    case carry
    case bills
    case mypage
    
    var title: String {
        switch self {
        case .home: return "홈"
        case .storage: return _strings[.storage]
        case .carry: return "운반"
        case .bills: return "내역"
        case .mypage: return "내정보"
        }
    }
    
    var imgname: String {
        switch self {
        case .home: return "icon-tabbar-0"
        case .storage: return "icon-tabbar-1"
        case .carry: return "icon-tabbar-2"
        case .bills: return "icon-tabbar-3"
        case .mypage: return "icon-tabbar-4"
        }
    }
    
    var selectedImgname: String {
        switch self {
        case .home: return "icon-tabbar-selected-0"
        case .storage: return "icon-tabbar-selected-1"
        case .carry: return "icon-tabbar-selected-2"
        case .bills: return "icon-tabbar-selected-3"
        case .mypage: return "icon-tabbar-selected-4"
        }
    }
}
