//
//  StorageCapacity.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/17.
//
//
//  💬 StorageCategory
//  여유공간 데이터
//

import Foundation

/// 여유공간
enum StorageCapacity: Int {
    case full = 0
    case enough
    
    var status: String {
        switch self {
        case .full: return "꽉참"
        case .enough: return "여유"
        }
    }
}
