//
//  ExData.swift
//  Carrifree
//
//  Created by orca on 2022/02/21.
//  Copyright © 2022 plattics. All rights reserved.
//

import Foundation

extension Data {
    func toByteArray() -> [UInt8]? {
        var byteData = [UInt8](repeating:0, count: self.count)
        self.copyBytes(to: &byteData, count: self.count)
        return byteData
    }
}
