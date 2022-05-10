//
//  FontType.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/11/01.
//

import UIKit

enum BoldCase {
    case regular
    case bold
    case extraBold
    
    var name: String {
        switch self {
        case .regular: return "NanumSquareR"
        case .bold: return "NanumSquareB"
        case .extraBold: return "NanumSquareEB"
        }
    }
}
