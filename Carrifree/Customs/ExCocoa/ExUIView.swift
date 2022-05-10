//
//  ExUIView.swift
//  CarrifreeStorage
//
//  Created by orca on 2020/10/05.
//  Copyright © 2020 plattics. All rights reserved.
//

import UIKit

extension UIView {
    
    @objc func configure() {}
    @objc func selectedByMenu() {}
    @objc func parentVcWillAappear() {}
    @objc func parentVcWillDisappear() {}
    
    func loadNib(name: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: name, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    // 늘어난 스크린 넓이 만큼의 비율로 targetView의 높이를 변경한다
    static func setResolution(targetView: UIView) {
        
        guard let targetHeight = targetView.constraints.filter({ $0.identifier == _identifiers[.constraintTargetHeight] }).first
        else { return }
        
        let newViewWidth = UIScreen.main.bounds.width       // 현재 스크린의 width
        let originViewWidth = targetView.frame.width        // 원래 뷰의 width
        let originViewHeight = targetView.frame.height      // 원래 뷰의 height
        
        
        /* 비율 공식으로 height를 계산한다
         
              414       :        234       =     1000     :   ?
        originViewWidth : originViewHeight = newViewWidth :   ?
        
        ? = originViewHeight * newViewWidth / originViewWidth
        
        */
        var newViewHeight = originViewHeight * newViewWidth / originViewWidth
        
        if UIDevice.current.userInterfaceIdiom != .phone {
            newViewHeight = newViewHeight * 0.55
        }
        
        targetHeight.constant = newViewHeight
    }
    
    // MARK: Round corners (부분 라운딩)
    func roundCorners(cornerRadius: CGFloat, maskedCorners: CACornerMask) {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = CACornerMask(arrayLiteral: maskedCorners)
    }
    
    // MARK: Blur effect
    func blur(blurRadius: Double = 2.5, cornerRadius: CGFloat = 0) {
        if isBlurred { return }
        
        let blurredImage = getBlurryImage(blurRadius)
        let blurredImageView = UIImageView(image: blurredImage)
        blurredImageView.layer.cornerRadius = cornerRadius
        blurredImageView.translatesAutoresizingMaskIntoConstraints = false
        blurredImageView.tag = CarryTags.blurView.rawValue
        blurredImageView.contentMode = .center
        blurredImageView.backgroundColor = .clear
        addSubview(blurredImageView)
        NSLayoutConstraint.activate([
            blurredImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            blurredImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
        
    func unblur() {
        subviews.forEach { subview in
            if subview.tag == CarryTags.blurView.rawValue {
                subview.removeFromSuperview()
            }
        }
    }
    
    var isBlurred: Bool {
        return (nil != self.viewWithTag(CarryTags.blurView.rawValue))
    }
    
    private func getBlurryImage(_ blurRadius: Double = 2.5) -> UIImage? {
        UIGraphicsBeginImageContext(bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        guard let image = UIGraphicsGetImageFromCurrentImageContext(),
              let blurFilter = CIFilter(name: "CIGaussianBlur") else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        blurFilter.setDefaults()
        
        blurFilter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        blurFilter.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        var convertedImage: UIImage?
        let context = CIContext(options: nil)
        if let blurOutputImage = blurFilter.outputImage,
           let cgImage = context.createCGImage(blurOutputImage, from: blurOutputImage.extent) {
            convertedImage = UIImage(cgImage: cgImage)
        }
        
        return convertedImage
    }
}
