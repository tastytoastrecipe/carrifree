//
//  BackwardTextField.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/05.
//

import UIKit

class BackwardTextField: UITextField {
    var backspaceCalled: ((BackwardTextField)->())?
    
    override func deleteBackward() {
        super.deleteBackward()
        backspaceCalled?(self)
    }
}
