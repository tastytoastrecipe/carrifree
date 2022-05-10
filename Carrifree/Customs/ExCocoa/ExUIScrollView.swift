//
//  ExUIScrollView.swift
//  Carrifree
//
//  Created by orca on 2022/03/03.
//  Copyright © 2022 plattics. All rights reserved.
//

import UIKit

public extension UIScrollView {
    
    enum ScrollDirection {
        case top
        case center
        case bottom
    }

    func scroll(to direction: ScrollDirection) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            switch direction {
            case .top:
                self.scrollToTop()
            case .center:
                self.scrollToCenter()
            case .bottom:
                self.scrollToBottom()
            }
        }
    }
    
    private func scrollToTop() {
        setContentOffset(.zero, animated: true)
    }
    
    private func scrollToCenter() {
        let centerOffset = CGPoint(x: 0, y: (contentSize.height - bounds.size.height) / 2)
        setContentOffset(centerOffset, animated: true)
    }
    
    private func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if(bottomOffset.y > 0) {
            setContentOffset(bottomOffset, animated: true)
        }
    }
  
    
    func scrollToNextItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x + self.bounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }

    func scrollToPreviousItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x - self.bounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }

    func moveToFrame(contentOffset : CGFloat) {
        self.setContentOffset(CGPoint(x: contentOffset, y: self.contentOffset.y), animated: true)
    }
}
