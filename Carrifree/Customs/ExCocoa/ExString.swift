//
//  ExString.swift
//  Carrifree
//
//  Created by orca on 2022/03/23.
//  Copyright © 2022 plattics. All rights reserved.
//

import Foundation

extension String {
    func toDate() -> Date? { //"yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let date = dateFormatter.date(from: self) { return date }
        else { return nil }
    }
}

