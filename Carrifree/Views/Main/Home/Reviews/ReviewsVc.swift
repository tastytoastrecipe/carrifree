//
//  ReviewsVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/12.
//
//
//  ๐ฌ ReviewsVc
//  ์ฌ์ฉ์ ํ๊ธฐ ์ ์ฒด๋ณด๊ธฐ ํ๋ฉด
//

import UIKit
import DropDown
import CoreLocation

protocol ReviewsVcDelegate {
    func reviewsVcDismissed()
}

class ReviewsVc: NaviVc {

    @IBOutlet weak var board: UIView!
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var align: UIButton!
    @IBOutlet weak var menu: PointMenu!
    @IBOutlet weak var reviewStack: UIStackView!
    @IBOutlet weak var noReviews: UILabel!
    @IBOutlet weak var reviewBoard: UIView!
    
    let reviewItemHeight: CGFloat = 110             // ReviewItem์ ๋์ด
    
    var delegate: ReviewsVcDelegate?
    var alignDropdown: DropDown! = nil
    var dropdownMenu: [String] = []             // ์ ๋ ฌ ๋ฉ๋ด Titles
    var categories: [String] = []               // ๋ฆฌ๋ทฐ์ ์นดํ๊ณ ๋ฆฌ Titles
    var datas: [ReviewData] = []
    var homeVm: HomeVm!                         // ๋ฉ์ธ(ํ) ํ๋ฉด์์ ํ์๋  ๋ฆฌ๋ทฐ
    var storageVm: StorageDetailVm!             // ๋ณด๊ด ์ฌ์์ ํ๋ฉด์์ ํ์๋  ๋ฆฌ๋ทฐ
    var selectedMenuIndex: Int = 0              // ์ด์ ํ๋ฉด์์ ์ ํ๋ ๋ฉ๋ด์ ์ธ๋ฑ์ค๋ฅผ ๊ทธ๋๋ก ๋ฐ์์ด
    var locationManager: CLLocationManager!
    
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    var reviewsInPage: Int = 5                  // ํ ํ์ด์ง์ ํ์๋  ๋ฆฌ๋ทฐ ๊ฐ์
    var scrollViewHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaults()
        
        // ์ ํ๋ ViewModel์ ๋ฐ๋ผ ๋ณด์ฌ์ง ๋ฐ์ดํฐ๋ฅผ ๊ตฌ๋ถํจ
        if nil != homeVm {
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            
            getHomeReviews(selectedMenuItemIndex: selectedMenuIndex, alignIndex: 0) {
                self.datas = self.homeVm.reviews
                self.configure()
            }
            
        } else if nil != storageVm {
            datas = storageVm.data.reviews
            configure()
        }
        
        
        
    }
    
    // ui default
    func setDefaults() {
        createMyNavi(title: "๊ณ ๋ง์์ ์บ๋ฆฌํ๋ฆฌ", naviCase: .normal, btns: [], backHidden: false)
        myNavi.delegate = self
        setBoard()
        
        _utils.setText(bold: .extraBold, size: 30, text: "์ฌ์ฉ์ ํ๊ธฐ", label: vcTitle)
        _utils.setText(bold: .regular, size: 14, text: "", button: align)
        _utils.setText(bold: .regular, size: 20, text: "์ฌ์ฉ์ ํ๊ธฐ๊ฐ ์์ต๋๋ค.", alignment: .center, label: noReviews)
    }

    func configure() {
        // ์นดํ๊ณ ๋ฆฌ ํ์
        if categories.isEmpty {
            menu.isHidden = true
        } else {
            menu.configure(itemTitles: categories, selectedIndex: selectedMenuIndex)
            menu.delegate = self
        }
        
        // Dropdown(์ ๋ ฌ) ๋ฉ๋ด ํ์
        if dropdownMenu.isEmpty {
            if nil != alignDropdown { alignDropdown.isHidden = true }
            align.isHidden = true
        } else {
            align.addTarget(self, action: #selector(self.onAlign(_:)), for: .touchUpInside)
            if nil == alignDropdown {
                alignDropdown = DropDown()
                alignDropdown.dataSource = dropdownMenu
                alignDropdown.anchorView = align
                alignDropdown.bottomOffset = CGPoint(x: 0, y: align.frame.height)
                alignDropdown.selectionAction = self.onAlignSelected(index:item:)
                if dropdownMenu.count > 0 { align.setTitle(dropdownMenu[0], for: .normal) }
            }
        }
        
//        if datas.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                self.setScrollView(datas: self.datas)
                self.setScrollPage()
            }
//        }
        
        let hideNoReview = datas.count > 0
        noReviews.isHidden = hideNoReview
        reviewBoard.isHidden = !hideNoReview
    }
    
    func setScrollView(datas: [ReviewData]) {
        let pageControlHeight: CGFloat = 40
        let pageHeight: CGFloat = reviewBoard.frame.height
        scrollViewHeight = pageHeight - pageControlHeight
        let scrollViewFrame = CGRect(x: 0, y: 0, width: reviewBoard.frame.width, height: scrollViewHeight)
        
        scrollView = UIScrollView(frame: scrollViewFrame)
        scrollView.backgroundColor = .clear
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.clipsToBounds = false
        reviewBoard.addSubview(scrollView)
        
        let pageControllY: CGFloat = scrollView.frame.maxY
        let numberOfPage = Int(ceil(Double(datas.count) / Double(reviewsInPage)))
        pageControl = UIPageControl(frame: CGRect(x: 0, y: pageControllY, width: scrollViewFrame.width, height: pageControlHeight))
        pageControl.numberOfPages = numberOfPage
        pageControl.backgroundColor = .clear//MyUtils.shared.symbolColorSoft
        pageControl.layer.cornerRadius = 4
        pageControl.addTarget(self, action: #selector(onPageChanged(_:)), for: .valueChanged)
        pageControl.pageIndicatorTintColor = UIColor(red: 254/255, green: 203/255, blue: 165/255, alpha: 1)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 254/255, green: 148/255, blue: 1/255, alpha: 1)
        reviewBoard.addSubview(pageControl)
    }
    
    func setScrollPage() {
        let numberOfPage = Int(ceil(Double(datas.count) / Double(reviewsInPage)))
        let contentWidth = scrollView.frame.width * CGFloat(numberOfPage)
        scrollView.contentSize = CGSize(width: contentWidth, height: scrollViewHeight)
        scrollView.isPagingEnabled = true
        scrollView.alwaysBounceVertical = false
        
        var tempDatas: [ReviewData] = []
        for (index, data) in datas.enumerated() {
            tempDatas.append(data)
            let pageIndex = (index / reviewsInPage)
            
            // 5๊ฐ์ฉ ๋ฌถ์ด์ ํ์ด์ง๋ฅผ ๋ง๋ ๋ค
            let full: Bool = (index + 1) % reviewsInPage == 0
            if full {
                let page = createPage(pageIndex: pageIndex, dataIndex: index, datas: tempDatas)
                scrollView.addSubview(page)
                tempDatas.removeAll()
            }
            
            // ๋ง์ง๋ง ํ์ด์ง ์์ฑ (5๊ฐ๊ฐ ์๋์ง ํ์ธ)
            if (index == datas.count - 1) && (false == full) {
                let page = createPage(pageIndex: pageIndex, dataIndex: index, datas: tempDatas)
                scrollView.addSubview(page)
                tempDatas.removeAll()
            }
        }
        
        let hideNoReview = datas.count > 0
        noReviews.isHidden = hideNoReview
        reviewBoard.isHidden = !hideNoReview
    }
    
    // ํ์ด์ง์ ๊ทธ์์ ์์ ๋ง๋ ๋ค
    func createPage(pageIndex: Int, dataIndex: Int, datas: [ReviewData]) -> UIView {
        // ํ์ด์ง ์์ฑ
        let scrollViewFrame = scrollView.frame
        let page = UIView(frame: CGRect(x: scrollViewFrame.width * CGFloat(pageIndex), y: 0, width: scrollViewFrame.width, height: scrollViewFrame.height))
        
        // ํ์ด์ง ์์ ์ ์์ฑ
        let cellSpace: CGFloat = 10
        let cellLeadingSpace: CGFloat = 12
        let cellHeight = (scrollView.frame.height - (CGFloat(reviewsInPage - 1) * cellSpace)) / CGFloat(reviewsInPage)
        let cellWidth = page.frame.width - (cellLeadingSpace * 2)
        for (i, data) in datas.enumerated() {
            let cellY: CGFloat = (CGFloat(i) * (cellHeight + cellSpace))
            let cellFrame = CGRect(x: cellLeadingSpace, y: cellY, width: cellWidth, height: cellHeight)
            //            var tempDataIndex = dataIndex
            //            if datas.count > 1 { tempDataIndex = dataIndex + (i - 1) }
            let cell = ReviewItem(frame: cellFrame, data: data)
            //            cell.setShadow(offset: CGSize(width: 3, height: 3), radius: 2.0, opacity: 0.1)
            //            cell.delegate = self
            page.addSubview(cell)
        }
        
        return page
    }

    /// Dropdown(์ ๋ ฌ) ๋ฒํผ ํฐ์น
    func onAlignSelected(index: Int, item: String) {
        guard index < dropdownMenu.count else { return }
        alignDropdown.hide()
        align.setTitle(dropdownMenu[index], for: .normal)
        
        let alignIndex = alignDropdown.indexForSelectedRow ?? 0
        getHomeReviews(selectedMenuItemIndex: menu.getSelectedItemIndex(), alignIndex: alignIndex)
    }
    
    private func createReviewCells(datas: [ReviewData]) {
        reviewStack.removeAllArrangedSubviews()
        
        for data in datas {
            let cell = ReviewItem(frame: .zero, data: data)
            reviewStack.addArrangedSubview(cell)
            cell.heightAnchor.constraint(equalToConstant: reviewItemHeight).isActive = true
        }
    }
    
    /// ๋ฆฌ๋ทฐ ๋ชฉ๋ก์ ๋ค์ ์์ฑํจ
    func setReviews(datas: [ReviewData]) {
        /*
        // ๋ฆฌ๋ทฐ๋ฅผ ์ธ๋ก๋ก ๋์ดํจ (๋ฌดํ ์คํฌ๋กค)
        self.datas = datas
        createReviewCells(datas: self.datas)
        */
        
        if nil == scrollView { return }
        
        // ๋ฆฌ๋ทฐ๋ฅผ ํ์ด์ง ํ์์ผ๋ก ๋์ดํจ
        self.datas = datas
        scrollView.subviews.forEach({ $0.removeFromSuperview() })
        setScrollPage()
        
    }
    
    /// ๋ฉ์ธ(ํ) ํ๋ฉด์ ๋ฆฌ๋ทฐ ์์ฒญ
    func getHomeReviews(selectedMenuItemIndex: Int, alignIndex: Int, completion: (() -> Void)? = nil) {
        guard let coordinate = locationManager.location?.coordinate else { return }     // ์ขํ ๋ชป๋ถ๋ฌ์์ผ๋ฉด return
        guard (coordinate.latitude + coordinate.longitude) != 0 else { return }         // ์ขํ๊ฐ (0, 0)์ด๋ฉด return
        
        let coor = Coordinate(lat: coordinate.latitude, lng: coordinate.longitude)
        let category = StorageCategory.getReviewCategory(reviewMenuIndex: selectedMenuItemIndex)
        let align = AlignNearReview.getAlign(alignIndex: alignIndex)
        homeVm.getReviews(all: true, coordinate: coor, category: category, align: align) { (success, msg) in
            self.setReviews(datas: self.homeVm.reviews)
            completion?()
        }
    }
    
    /// ์์น ์ ๊ทผ ๊ถํ ์์ Alert ํ์
    func createCantAccessAlert() {
        let ok = MyUtils.shared.createAlertAction(title: MyStrings.ok.rawValue, titleColor: .systemRed) { (_) in _utils.goToSettingsCarrifree() }
        let alert = MyUtils.shared.createAlert(title: MyStrings.alertNeedLocationPermissionTitle.rawValue, message: MyStrings.alertNeedLocationPermissionDesc02.rawValue, handlers: [ok], style: .alert, addCancel: true)
        self.present(alert, animated: true)
    }
}

// MARK: - Actions
extension ReviewsVc {
    @objc func onAlign(_ sender: UIGestureRecognizer) {
        alignDropdown.show()
    }
    
    @objc func onPageChanged(_ sender: UIPageControl) {
        scrollView.setContentOffset(CGPoint(x: CGFloat(sender.currentPage) * scrollView.frame.width, y: 0), animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension ReviewsVc: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(floorf(Float(scrollView.contentOffset.x) / Float(scrollView.frame.width)))
        pageControl.currentPage = currentPage
    }
}

// MARK: - PointMenuDelegate
extension ReviewsVc: PointMenuDelegate {
    func onPointMenuSelected(item: PointItem) {
        let alignIndex = alignDropdown?.indexForSelectedRow ?? 0
        if nil != homeVm { getHomeReviews(selectedMenuItemIndex: item.tag, alignIndex: alignIndex) }
        else if nil != storageVm {
            datas = storageVm.data.reviews
        }
    }
}

// MARK: - MyNaviDelegate
extension ReviewsVc: MyNaviDelegate {
    func onBack() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false) {
            self.delegate?.reviewsVcDismissed()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension ReviewsVc: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        MyLog.logWithArrow("get location failed", error.localizedDescription)
    }
    
    /// ์์น ์ ๊ทผ๊ถํ ๋ณ๊ฒฝ callback
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            MyLog.log("GPS ๊ถํ ์ค์ ๋จ")
            self.locationManager.startUpdatingLocation()
        case .restricted, .notDetermined:
            MyLog.log("GPS ๊ถํ ์ค์ ๋์ง ์์")
            locationManager.requestWhenInUseAuthorization()
            createCantAccessAlert()
        case .denied:
            MyLog.log("GPS ๊ถํ ์์ฒญ ๊ฑฐ๋ถ๋จ")
            locationManager.requestWhenInUseAuthorization()
            createCantAccessAlert()
        default:
            MyLog.log("GPS: Default")
        }
    }
    
    /// ์์น ์ ๊ทผ๊ถํ ๋ณ๊ฒฝ callback  (iOS 14 ์ด์)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        var authStatus = CLAuthorizationStatus.notDetermined
        if #available(iOS 14.0, *) {
            authStatus = manager.authorizationStatus
        } else {
            authStatus = CLLocationManager.authorizationStatus()
        }
        
        if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            MyLog.log("GPS ๊ถํ ์ค์ ๋จ")
        } else if authStatus == .notDetermined || authStatus == .restricted {
            manager.requestWhenInUseAuthorization()
            MyLog.log("GPS ๊ถํ ์ค์ ๋์ง ์์")
            createCantAccessAlert()
        } else if authStatus == .denied {
            MyLog.log("GPS ๊ถํ ์์ฒญ ๊ฑฐ๋ถ๋จ")
            createCantAccessAlert()
        }
    }
}
