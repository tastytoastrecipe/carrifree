//
//  AppGuideVc.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/12/07.
//

import UIKit

class AppGuideVc: UIViewController {
    
    @IBOutlet weak var board: UIView!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var page: UIPageControl!
    
    var dataSource: [String] = [
                                "img-app-guide-0",
                                "img-app-guide-1",
                                "img-app-guide-2",
                                "img-app-guide-3",
                                "img-app-guide-4",
                                "img-app-guide-5"
                                ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollview.delegate = self
        
        page.numberOfPages = dataSource.count
        page.backgroundColor = .clear
        page.addTarget(self, action: #selector(onPageChanged(_:)), for: .valueChanged)

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            self.setScrollPage()
        }
    }
    
    func setScrollPage() {
        let contentSize = CGSize(width: board.bounds.width * CGFloat(dataSource.count), height: scrollview.bounds.height)
        scrollview.contentSize = contentSize
        scrollview.isPagingEnabled = true
        
        for (index, data) in dataSource.enumerated() {
            let imgview = UIImageView(frame: CGRect(x: board.bounds.width * CGFloat(index), y: 0, width: board.bounds.width, height: scrollview.bounds.height))
            imgview.image = UIImage(named: data)
            imgview.contentMode = .scaleAspectFit
            imgview.backgroundColor = .clear
            scrollview.addSubview(imgview)
        }
    }
    
    @objc func onPageChanged(_ sender: UIPageControl) {
        scrollview.setContentOffset(CGPoint(x: CGFloat(sender.currentPage) * board.bounds.width, y: 0), animated: true)
    }
}
    
// MARK:- Actions
extension AppGuideVc {
    @IBAction func onExit(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}


// MARK:- UIScrollViewDelegate
extension AppGuideVc: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        _log.log("scrollViewDidEndDecelerating")
        let currentPage = Int(floorf(Float(scrollView.contentOffset.x) / Float(scrollView.frame.width)))
        page.currentPage = currentPage
    }
}
