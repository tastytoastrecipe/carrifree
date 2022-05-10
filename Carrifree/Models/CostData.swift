//
//  CostData.swift
//  CarrifreeUser
//
//  Created by plattics-kwon on 2022/01/17.
//
//
//  💬 CostData
//  가격
//

import Foundation

class CostData {
    var seq: String = ""
    var type: String = ""           // 짐 종류 (작은/보통/큰/대형 짐)
    var section: String = ""
    var price: String = ""
    var defaultPrice: String = ""
    var limitPercent: Float = 0.5   // 50% - 기본값(defaultPrice)을 기준으로 설정할 수 있는 가격의 범위 %
}
