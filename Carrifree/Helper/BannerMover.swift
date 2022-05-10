//
//  BannerMover.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2022/04/06.
//

import Foundation
import UIKit
import AlamofireImage

protocol BannerMoverDelegate {
    func moved()
}

class BannerMover {
    var scrollview: UIScrollView
    var itemCount: CGFloat
    var itemWidth: CGFloat
    var itemSpace: CGFloat
    var horizontal: Bool
    
    var circulator: Timer?              // 순환 타이머
    var circulateSpeed: Double = 2      // 순환 속도(초)
    var focusIndex: CGFloat = 0         // 현재 맨앞에 보여지는 아이템의 index
    var delegate: BannerMoverDelegate?
    var isCirculating: Bool = false
    
    init(scrollview: UIScrollView, itemCount: CGFloat, itemWidth: CGFloat, itemSpace: CGFloat, horizontal: Bool) {
        self.scrollview = scrollview
        self.itemCount = itemCount
        self.itemWidth = itemWidth
        self.itemSpace = itemSpace
        self.horizontal = horizontal
    }

    @objc func move() {
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        if horizontal {
            x = (itemWidth + itemSpace) * (focusIndex + 1)
            y = scrollview.contentOffset.y
        } else {
            x = scrollview.contentOffset.x
            y = (itemWidth + itemSpace) * (focusIndex + 1)
        }
        
        scrollview.setContentOffset(CGPoint(x: x, y: y), animated: true)
        focusIndex += 1
        delegate?.moved()
    }
    
    func circulate() {
        isCirculating = true
        circulator?.invalidate()
        circulator = Timer.scheduledTimer(timeInterval: circulateSpeed, target: self, selector: #selector(self.move), userInfo: nil, repeats: true)
    }
    
    func stop() {
        isCirculating = false
        circulator?.invalidate()
    }
}

extension BannerMover {
    
}
