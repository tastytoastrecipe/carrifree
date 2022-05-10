//
//  Banner.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/07.
//
//
//  💬 BannerList
//  메인화면의 배너
//

import UIKit

class BannerList: UIView {
    var collectionview: UICollectionView!
    var banners: [BannerData] = []
    
    var moveWith: CGFloat = 325         // 두번째 부터 스크롤될 간격
    var targetX: CGFloat = 295          // 배너가 오른쪽으로 처음 스크롤되는 위치
    var circulator: Timer?              // 순환 타이머
    var circulateSpeed: Double = 5      // 순환 속도(초)
    var currentIndex: CGFloat = 0       // 현재 맨앞에 보여지는 아이템의 index
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(banners: [BannerData]) {
        super.init(frame: CGRect.zero)
        configure(banners: banners)
    }
    
    override func configure() {
        self.clipsToBounds = false
        self.backgroundColor = .clear
    }
    
    func configure(banners: [BannerData]) {
        configure()
        self.banners = banners

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            let screenWidth = self.bounds.width
            var screenHeight: CGFloat = 0
            let paddingX: CGFloat = 30
            let paddingY: CGFloat = 6
            let bannerSpacing: CGFloat = 12
            let bannerWidth: CGFloat = screenWidth - (paddingX * 2)
            
            // background
//            let bg = UIView()
//            bg.backgroundColor = .white
//            self.addSubview(bg)
//
//            bg.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                bg.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
//                bg.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
//                bg.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
//                bg.heightAnchor.constraint(equalToConstant: 120),
//            ])
//
            
            // collection
            for constraint in self.constraints {
                if constraint.firstAttribute == .height {
                    screenHeight = constraint.constant
                }
            }
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: bannerWidth, height: screenHeight - (paddingY * 2))
            layout.minimumInteritemSpacing = bannerSpacing
            layout.scrollDirection = .horizontal
            self.collectionview = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
            self.collectionview.showsHorizontalScrollIndicator = false
            self.collectionview.showsVerticalScrollIndicator = false
            self.collectionview.clipsToBounds = false
//            self.collectionview.isPagingEnabled = true
            self.collectionview.backgroundColor = .clear
            self.collectionview.contentInset = UIEdgeInsets(top: 0, left: paddingX, bottom: 0, right: paddingX)
            self.addSubview(self.collectionview)
            
            self.collectionview.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.collectionview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
                self.collectionview.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
                self.collectionview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
                self.collectionview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            ])
            
            let cellId = String(describing: BannerItem.self)
            let xib = UINib(nibName: cellId, bundle: nil)
            self.collectionview.register(xib, forCellWithReuseIdentifier: cellId)
            self.collectionview.delegate = self
            self.collectionview.dataSource = self
            self.collectionview.decelerationRate = .fast
            
            self.targetX = screenWidth - 80
            self.moveWith = self.targetX + paddingX
            self.circulate()
        }
    }
    
    func setBanners(banners: [BannerData]) {
        collectionview.isHidden = true
        
        if currentIndex > 0 {
            currentIndex = -1
            let x = targetX + (moveWith * currentIndex)
            collectionview.setContentOffset(CGPoint(x: x, y: 0), animated: false)
            currentIndex += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            if nil == self.collectionview { return }
            self.banners.removeAll()
            self.banners = banners
            self.collectionview.reloadData()
            self.collectionview.isHidden = false
        }
    }
    
    func circulate() {
        circulator?.invalidate()
        circulator = Timer.scheduledTimer(timeInterval: circulateSpeed, target: self, selector: #selector(self.move), userInfo: nil, repeats: true)
    }
    
    @objc func move() {
        let x = targetX + (moveWith * currentIndex)
        collectionview.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        
        currentIndex += 1
    }
    
}

// MARK: - UIScrollViewDelegate
extension BannerList: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        let count = banners.count
//        return count
        return 100000
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: BannerItem.self), for: indexPath) as! BannerItem
        
        if banners.count > 0 {
            let index = indexPath.row % banners.count
            let bannerData = banners[index]
            if let bannerImgData = bannerData.imgData {
                cell.configure(data: bannerImgData, pageUrl: bannerData.pageUrl)
                cell.backgroundColor = .clear
            } else {
                cell.configure(imgUrl: bannerData.imgUrl, pageUrl: bannerData.pageUrl) { (imgData) in
                    self.banners[index].imgData = imgData
                }
            }
            
        } else {
            cell.configure(imgUrl: "", pageUrl: "")
        }
        
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectioncViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 340, height: collectionview.frame.height - 20)
//    }
}

extension BannerList : UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        // 페이징
        if let cv = scrollView as? UICollectionView {
            
            let layout = cv.collectionViewLayout as! UICollectionViewFlowLayout
            let cellWidth = layout.itemSize.width + layout.minimumLineSpacing
            
            var offset = targetContentOffset.pointee
            let idx = (offset.x + cv.contentInset.left) / cellWidth
            
            var roundedIdx = round(idx)
            if scrollView.contentOffset.x > targetContentOffset.pointee.x {
                roundedIdx = floor(idx)
            } else if scrollView.contentOffset.x < targetContentOffset.pointee.x {
                roundedIdx = ceil(idx)
            } else {
                roundedIdx = round(idx)
            }
            
            if currentIndex > roundedIdx {
                currentIndex -= 1
                roundedIdx = currentIndex
            } else if currentIndex < roundedIdx {
                currentIndex += 1
                roundedIdx = currentIndex
            }
            
            offset = CGPoint(x: roundedIdx * cellWidth - cv.contentInset.left, y: 0)
            targetContentOffset.pointee = offset
            
        }
    }
}
