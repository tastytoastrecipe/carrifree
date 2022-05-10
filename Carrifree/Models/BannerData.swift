//
//  BannerData.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/07.
//
//
//  💬 BannerData
//  배너 목록의 각 아이템 데이터
//

import Foundation

struct BannerData {
    var seq: String
    var pageUrl: String
    var imgUrl: String
    var imgData: Data?
}

enum BannerCase: String {
    case user = "USR"           // 사용자앱 배너
    case storage = "STR"        // 보관앱 배너
}

enum BannerGroup: String {
    case user01 = "U01"         // 사용자앱 배너 1
    case storage01 = "S01"      // 사용자앱 배너 1
}
