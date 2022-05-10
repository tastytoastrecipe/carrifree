//
//  ExUITextField.swift
//  Carrifree
//
//  Created by plattics-kwon on 2020/11/24.
//  Copyright © 2020 plattics. All rights reserved.
//

import Foundation
import UIKit

protocol UITextFieldAccessoryDelegate {
    func onCancelButton()
    func onDoneButton()
}

extension UITextField {
    
    @IBInspectable var displayAccessory: Bool {
        get {
            return self.displayAccessory
        }
        set (display) {
            if display {
                addButtonOnKeyboard()
            }
        }
    }

    func addButtonOnKeyboard()
    {
        let cancelToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        cancelToolbar.barStyle = .default

        let cancel: UIBarButtonItem = UIBarButtonItem(title: _strings[.cancel], style: .plain, target: self, action: #selector(self.cancelButtonAction))
        let flexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: _strings[.ok], style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [cancel, flexSpace, done]
        cancelToolbar.items = items
        cancelToolbar.sizeToFit()

        self.inputAccessoryView = cancelToolbar
    }

    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
    
    @objc func cancelButtonAction()
    {
        self.resignFirstResponder()
    }
    
    
}

/*
@IBDesignable
class TextField: UITextField {
    @IBInspectable var insetX: CGFloat = 0 {
       didSet {
         layoutIfNeeded()
       }
    }
    @IBInspectable var insetY: CGFloat = 0 {
       didSet {
         layoutIfNeeded()
       }
    }

    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX , dy: insetY)
    }

    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX , dy: insetY)
    }
}
*/
