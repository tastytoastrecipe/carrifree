//
//  MyLog.swift
//  Carrifree
//
//  Created by orca on 2020/10/08.
//  Copyright © 2020 plattics. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias _log = MyLog

class MyLog {
    
    private init() {}
    
    static func log(_ log: String) {
        if releaseMode { return }
        print("\n\t## MyLog - \(log)\n")
    }
    
    static func logWithArrow(_ title: String, _ detail: String) {
        if releaseMode { return }
        print("\n\t## MyLog:\n\t\(title) ---> \(detail)")
    }
}
