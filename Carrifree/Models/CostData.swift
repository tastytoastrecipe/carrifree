//
//  CostData.swift
//  CarrifreeUser
//
//  Created by plattics-kwon on 2022/01/17.
//
//
//  π¬ CostData
//  κ°κ²©
//

import Foundation

class CostData {
    var seq: String = ""
    var type: String = ""           // μ§ μ’λ₯ (μμ/λ³΄ν΅/ν°/λν μ§)
    var section: String = ""
    var price: String = ""
    var defaultPrice: String = ""
    var limitPercent: Float = 0.5   // 50% - κΈ°λ³Έκ°(defaultPrice)μ κΈ°μ€μΌλ‘ μ€μ ν  μ μλ κ°κ²©μ λ²μ %
}
