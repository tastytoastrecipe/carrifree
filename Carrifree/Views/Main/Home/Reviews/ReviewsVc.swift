//
//  ReviewsVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/12.
//
//
//  💬 ReviewsVc
//  사용자 후기 전체보기 화면
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
    
    let reviewItemHeight: CGFloat = 110             // ReviewItem의 높이
    
    var delegate: ReviewsVcDelegate?
    var alignDropdown: DropDown! = nil
    var dropdownMenu: [String] = []             // 정렬 메뉴 Titles
    var categories: [String] = []               // 리뷰의 카테고리 Titles
    var datas: [ReviewData] = []
    var homeVm: HomeVm!                         // 메인(홈) 화면에서 표시될 리뷰
    var storageVm: StorageDetailVm!             // 보관 사업자 화면에서 표시될 리뷰
    var selectedMenuIndex: Int = 0              // 이전화면에서 선택된 메뉴의 인덱스를 그대로 받아옴
    var locationManager: CLLocationManager!
    
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    var reviewsInPage: Int = 5                  // 한 페이지에 표시될 리뷰 개수
    var scrollViewHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaults()
        
        // 선택된 ViewModel에 따라 보여질 데이터를 구분함
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
        createMyNavi(title: "고마워요 캐리프리", naviCase: .normal, btns: [], backHidden: false)
        myNavi.delegate = self
        setBoard()
        
        _utils.setText(bold: .extraBold, size: 30, text: "사용자 후기", label: vcTitle)
        _utils.setText(bold: .regular, size: 14, text: "", button: align)
        _utils.setText(bold: .regular, size: 20, text: "사용자 후기가 없습니다.", alignment: .center, label: noReviews)
    }

    func configure() {
        // 카테고리 표시
        if categories.isEmpty {
            menu.isHidden = true
        } else {
            menu.configure(itemTitles: categories, selectedIndex: selectedMenuIndex)
            menu.delegate = self
        }
        
        // Dropdown(정렬) 메뉴 표시
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
            
            // 5개씩 묶어서 페이지를 만든다
            let full: Bool = (index + 1) % reviewsInPage == 0
            if full {
                let page = createPage(pageIndex: pageIndex, dataIndex: index, datas: tempDatas)
                scrollView.addSubview(page)
                tempDatas.removeAll()
            }
            
            // 마지막 페이지 생성 (5개가 아닌지 확인)
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
    
    // 페이지와 그안의 셀을 만든다
    func createPage(pageIndex: Int, dataIndex: Int, datas: [ReviewData]) -> UIView {
        // 페이지 생성
        let scrollViewFrame = scrollView.frame
        let page = UIView(frame: CGRect(x: scrollViewFrame.width * CGFloat(pageIndex), y: 0, width: scrollViewFrame.width, height: scrollViewFrame.height))
        
        // 페이지 안의 셀 생성
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

    /// Dropdown(정렬) 버튼 터치
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
    
    /// 리뷰 목록을 다시 생성함
    func setReviews(datas: [ReviewData]) {
        /*
        // 리뷰를 세로로 나열함 (무한 스크롤)
        self.datas = datas
        createReviewCells(datas: self.datas)
        */
        
        if nil == scrollView { return }
        
        // 리뷰를 페이지 형식으로 나열함
        self.datas = datas
        scrollView.subviews.forEach({ $0.removeFromSuperview() })
        setScrollPage()
        
    }
    
    /// 메인(홈) 화면의 리뷰 요청
    func getHomeReviews(selectedMenuItemIndex: Int, alignIndex: Int, completion: (() -> Void)? = nil) {
        guard let coordinate = locationManager.location?.coordinate else { return }     // 좌표 못불러왔으면 return
        guard (coordinate.latitude + coordinate.longitude) != 0 else { return }         // 좌표가 (0, 0)이면 return
        
        let coor = Coordinate(lat: coordinate.latitude, lng: coordinate.longitude)
        let category = StorageCategory.getReviewCategory(reviewMenuIndex: selectedMenuItemIndex)
        let align = AlignNearReview.getAlign(alignIndex: alignIndex)
        homeVm.getReviews(all: true, coordinate: coor, category: category, align: align) { (success, msg) in
            self.setReviews(datas: self.homeVm.reviews)
            completion?()
        }
    }
    
    /// 위치 접근 권한 없음 Alert 표시
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
    
    /// 위치 접근권한 변경 callback
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            MyLog.log("GPS 권한 설정됨")
            self.locationManager.startUpdatingLocation()
        case .restricted, .notDetermined:
            MyLog.log("GPS 권한 설정되지 않음")
            locationManager.requestWhenInUseAuthorization()
            createCantAccessAlert()
        case .denied:
            MyLog.log("GPS 권한 요청 거부됨")
            locationManager.requestWhenInUseAuthorization()
            createCantAccessAlert()
        default:
            MyLog.log("GPS: Default")
        }
    }
    
    /// 위치 접근권한 변경 callback  (iOS 14 이상)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        var authStatus = CLAuthorizationStatus.notDetermined
        if #available(iOS 14.0, *) {
            authStatus = manager.authorizationStatus
        } else {
            authStatus = CLLocationManager.authorizationStatus()
        }
        
        if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            MyLog.log("GPS 권한 설정됨")
        } else if authStatus == .notDetermined || authStatus == .restricted {
            manager.requestWhenInUseAuthorization()
            MyLog.log("GPS 권한 설정되지 않음")
            createCantAccessAlert()
        } else if authStatus == .denied {
            MyLog.log("GPS 권한 요청 거부됨")
            createCantAccessAlert()
        }
    }
}
