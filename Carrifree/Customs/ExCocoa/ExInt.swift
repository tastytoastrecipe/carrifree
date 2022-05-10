//
//  ExInt.swift
//  Carrifree
//
//  Created by orca on 2020/10/20.
//  Copyright © 2020 plattics. All rights reserved.
//

import Foundation

extension Int {
    // MARK:- Add commas to Int cost
    //
    private static var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        return numberFormatter
    }()

    var delimiter: String {
        return Int.numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}
