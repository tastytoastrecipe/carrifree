//
//  FullScreenImgVc.swift
//  Carrifree
//
//  Created by plattics-kwon on 2020/12/21.
//  Copyright © 2020 plattics. All rights reserved.
//

import UIKit

class FullScreenImgVc: UIViewController {
    
    let imgTag: Int = 11
    var scrollview: UIScrollView!
    var imgUrls: [String] = []
    var imgDatas: [Data?] = []
    var currentPage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createScrollview()
        setPage(page: currentPage)
        setExitButton()
    }
    
    private func createScrollview() {
        scrollview = UIScrollView()
        scrollview.delegate = self
        scrollview.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollview.backgroundColor = .black
        scrollview.isPagingEnabled = true
        scrollview.alwaysBounceHorizontal = false
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.showsVerticalScrollIndicator = false
        scrollview.contentInsetAdjustmentBehavior = .never
        self.view.addSubview(scrollview)
        
        var numberOfPage: Int = imgDatas.count
        if numberOfPage == 0 { numberOfPage = imgUrls.count }
        let contentHeight = scrollview.frame.height * CGFloat(numberOfPage)
        scrollview.contentSize = CGSize(width: scrollview.frame.width, height: contentHeight)
        
        for i in 0 ..< numberOfPage {
            let page = createPage(index: i)
            scrollview.addSubview(page)
        }
    }
    
    func createPage(index: Int) -> UIView {
        let scrollViewFrame = scrollview.frame
        let page = UIView(frame: CGRect(x: 0, y: scrollViewFrame.height * CGFloat(index), width: scrollViewFrame.width, height: scrollViewFrame.height))
        page.backgroundColor = .clear
//        UIColor(red: CGFloat.random(in: 0 ... 255)/255, green: CGFloat.random(in: 0 ... 255)/255, blue: CGFloat.random(in: 0 ... 255)/255, alpha: 1)
        page.tag = index
        return page
    }
    
    // exit button
    private func setExitButton() {
        let buttonWidth: CGFloat = 40
        let spaceX: CGFloat = 6
        let spacey: CGFloat = 20
        let exitBtn = UIButton(frame: CGRect(x: self.view.frame.width - buttonWidth - spaceX, y: self.view.frame.height - buttonWidth - spacey, width: buttonWidth, height: buttonWidth))
        exitBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        exitBtn.tintColor = UIColor.white
        exitBtn.addTarget(self, action: #selector(self.exit(_:)), for: .touchUpInside)
        self.view.addSubview(exitBtn)
    }

    func setPage(page: Int) {
        guard let pageview = scrollview.viewWithTag(page) else { return }
        if nil == pageview.viewWithTag(imgTag) {
            let imageview = UIImageView()
            imageview.tag = imgTag
            var tr = CGAffineTransform()
            let angle = CGFloat(Double.pi / 2.0)
            tr = CGAffineTransform.identity.rotated(by: angle)
            imageview.transform = tr
            imageview.frame = CGRect(x: 0, y: 0, width: pageview.frame.width, height: pageview.frame.height)
            imageview.contentMode = .scaleAspectFit
            
            if imgUrls.isEmpty {
                guard let imgData = imgDatas[page] else { return }
                imageview.image = UIImage(data: imgData)
            } else {
                imageview.loadImage(url: imgUrls[page])
            }
            
            pageview.addSubview(imageview)
        }
    }
}

// MARK: - Actions
extension FullScreenImgVc {
    @objc func exit(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension FullScreenImgVc: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = Int(floorf(Float(scrollView.contentOffset.y) / Float(scrollView.frame.height)))
        setPage(page: currentPage)
    }
}
