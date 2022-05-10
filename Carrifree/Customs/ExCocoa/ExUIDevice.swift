//
//  ExUIDevice.swift
//  Carrifree
//
//  Created by orca on 2020/10/27.
//  Copyright © 2020 plattics. All rights reserved.
//

import Foundation
import UIKit

//MARK:- UIDevice Notch
extension UIDevice {
    var hasNotch: Bool {

//        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let bottom = keyWindow?.safeAreaInsets.bottom ?? 0

        return bottom > 0
    }
    
    func getNotchHeight() -> CGFloat {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let bottom = keyWindow?.safeAreaInsets.bottom ?? 0
        
        return bottom
    }
}
