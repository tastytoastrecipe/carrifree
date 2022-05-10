//
//  RatingData.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/10.
//

import Foundation
import UIKit

enum Ratings {
    case rating00
    case rating01
    case rating02
    case rating03
    case rating04
    case rating05
    
    var imgName: String {
        switch self {
        case .rating00: return "icon-rating-0"
        case .rating01: return "icon-rating-1"
        case .rating02: return "icon-rating-2"
        case .rating03: return "icon-rating-3"
        case .rating04: return "icon-rating-4"
        case .rating05: return "icon-rating-5"
        }
    }
    
    var color: UIColor {
        switch self {
        case .rating00: return UIColor(red: 238/255, green: 124/255, blue: 124/255, alpha: 1)
        case .rating01: return UIColor(red: 243/255, green: 177/255, blue: 99/255, alpha: 1)
        case .rating02: return UIColor(red: 248/255, green: 212/255, blue: 91/255, alpha: 1)
        case .rating03: return UIColor(red: 159/255, green: 229/255, blue: 129/255, alpha: 1)
        case .rating04: return UIColor(red: 67/255, green: 149/255, blue: 201/255, alpha: 1)
        case .rating05: return UIColor(red: 166/266, green: 146/255, blue: 219/255, alpha: 1)
        }
    }
    
    static func getRatingByScore(score: Double) -> Ratings {
        if (4.6 ... 5.0).contains(score) {
            return rating00
        } else if (4.1 ... 4.5).contains(score) {
            return rating01
        } else if (3.6 ... 4.0).contains(score) {
            return rating02
        } else if (3.1 ... 3.5).contains(score) {
            return rating03
        } else if (2.6 ... 3.0).contains(score) {
            return rating04
        } else if (0.0 ... 2.5).contains(score) {
            return rating05
        }
        
        return rating00
    }
}
