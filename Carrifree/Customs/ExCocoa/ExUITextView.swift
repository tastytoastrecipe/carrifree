//
//  ExUITextView.swift
//  Carrifree
//
//  Created by plattics-kwon on 2020/12/14.
//  Copyright © 2020 plattics. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    
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

//        let cancel: UIBarButtonItem = UIBarButtonItem(title: _strings[.cancel], style: .plain, target: self, action: #selector(self.cancelButtonAction))
        let flexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: _strings[.ok], style: .done, target: self, action: #selector(self.doneButtonAction))

//        let items = [cancel, flexSpace, done]
        let items = [flexSpace, done]
        cancelToolbar.items = items
        cancelToolbar.sizeToFit()

        self.inputAccessoryView = cancelToolbar
    }

    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
    
//    @objc func cancelButtonAction()
//    {
//        self.resignFirstResponder()
//    }
    
    // MARK: - Number of lines
    func sizeFit(width: CGFloat) -> CGSize {
        let fixedWidth = width
        let newSize = sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        return CGSize(width: fixedWidth, height: newSize.height)
    }
    
    func numberOfLines() -> Int {
        let size = self.sizeFit(width: self.bounds.width)
        let numLines = Int(size.height / (self.font?.lineHeight ?? 1.0))
        return numLines
    }
}

