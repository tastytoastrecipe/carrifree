//
//  ExUIViewController.swift
//  Carrifree
//
//  Created by orca on 2020/10/07.
//  Copyright © 2020 plattics. All rights reserved.
//

import UIKit

extension UIViewController {
    
    static var name: String {
        get {
            return String(describing: self)
        }
    }
    
    // 네비게이션바에 이미지 추가
    func setNaviTitleImage(imageName: String) {
        let titleView = UIView()
        let image = UIImageView()
        image.image = UIImage(named: imageName)

        let imageX = titleView.center.x
        let imageY = titleView.center.y

        let imageWidth: CGFloat = 100
        let imageHeight: CGFloat = 30

        image.frame = CGRect(x: imageX - imageWidth / 2, y: imageY - imageHeight / 2 - 5, width: imageWidth, height: imageHeight)
        image.contentMode = UIView.ContentMode.scaleAspectFit

        titleView.addSubview(image)
        titleView.sizeToFit()

        self.navigationItem.titleView = titleView
    }
    
    // 네비게이션바 옵션 셋팅
    func setNaviOption(title: String, tintColor: UIColor, backButtonTtile: String) {
        self.navigationItem.title = title
        self.navigationController?.navigationBar.tintColor = tintColor
        self.navigationController?.navigationBar.topItem?.title = backButtonTtile
    }
    
    // 네비게이션바 컬러 설정 (반투명, 하단라인 제거)
    func setNaviBarColor(color: UIColor?, isTranslucent: Bool) {
        self.navigationController?.navigationBar.barTintColor = color
        self.navigationController?.navigationBar.isTranslucent = isTranslucent
        
        if isTranslucent {
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.navigationBar.backgroundColor = .gray
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.backgroundColor = color
        }
    }
    
    func dismissModal(animated flag: Bool, completion: (() -> Void)? = nil) {
        self.dismiss(animated: flag, completion: completion)
    }
    
    func topMostViewController() -> UIViewController? {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }

}
