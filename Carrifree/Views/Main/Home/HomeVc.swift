//
//  HomeVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/07.
//

import UIKit
import CoreLocation

@objc protocol HomeVcDelegate {
    @objc optional func onMap()
    @objc optional func onStorageItemSelected(item: StorageItem)
}

class HomeVc: UIViewController {
    
    @IBOutlet weak var banner: BannerList!      // banner
    @IBOutlet weak var storages: StorageList!   // storages
    @IBOutlet weak var guideTitle: UILabel!
    @IBOutlet weak var guideDesc: UILabel!
    @IBOutlet weak var reviews: ReviewList!     // reviews
    
    var delegate: HomeVcDelegate?
    var vm: HomeVm!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        vm = HomeVm(delegate: self)
        banner.configure(banners: vm.banners)
        storages.configure(storages: vm.storages)
        storages.delegate = self
        let reviewMenuTitles: [String] = [StorageCategory.storage999.name,
                                          StorageCategory.storage006.name,
                                          StorageCategory.storage005.name,
                                          StorageCategory.storage003.name,
                                          StorageCategory.storage002.name,
                                          StorageCategory.storage001.name
                                         ]
        reviews.configure(title: "고마워요~ 캐리프리!", menuTitles: reviewMenuTitles, datas: vm.reviews)
        reviews.delegate = self
        _utils.setText(bold: .bold, size: 20, text: _strings[.guide], label: guideTitle)
        _utils.setText(bold: .bold, size: 16, text: "여행에 즐거움이 배가되는 캐리프리\n이렇게 사용해 보세요!", label: guideDesc)
    }
    
    func willAppear() {
        configure()
    }
    
    func configure() {
        getStorages(align: .dist)
        getReviews()
        getBanners()
    }
    
    /// 배너 요청
    func getBanners() {
        vm.getBanners() { (success, msg) in
            guard success else {
                let alert = _utils.createSimpleAlert(title: _strings[.requestFailed], message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
                return
            }
            
            self.banner.setBanners(banners: self.vm.banners)
        }
    }
    
    /// 주변 보관소 목록 요청
    func getStorages(align: AlignNearStorage) {
        guard let coordinate = locationManager.location?.coordinate else { return }     // 좌표 못불러왔으면 return
        if coordinate.latitude == 0 && coordinate.longitude == 0 { return }             // 좌표가 (0, 0)이면 return
        
        let coor = Coordinate(lat: coordinate.latitude, lng: coordinate.longitude)
        vm.getStorages(coordinate: coor, align: align) { (success, msg) in
            if success {
                self.storages.setStorages(storages: self.vm.storages)
            } else {
                let alert = _utils.createSimpleAlert(title: _strings[.requestFailed], message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
            }
        }
    }
    
    /// 주변 보관소 리뷰 목록 요청
    func getReviews() {
        guard let coordinate = locationManager.location?.coordinate else { return }     // 좌표 못불러왔으면 return
        if coordinate.latitude == 0 && coordinate.longitude == 0 { return }             // 좌표가 (0, 0)이면 return
        
        let coor = Coordinate(lat: coordinate.latitude, lng: coordinate.longitude)
        vm.getReviews(all: false, coordinate: coor, category: reviews.getSelectedMenuCategory(), align: .recent) { (success, msg) in
            if success {
                self.reviews.setReviews(datas: self.vm.reviews)
            } else {
                let alert = _utils.createSimpleAlert(title: _strings[.requestFailed], message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
            }
        }
    }

    /// 위치 접근 권한 없음 Alert 표시
    func createCantAccessAlert() {
        
        let ok = MyUtils.shared.createAlertAction(title: MyStrings.ok.rawValue, titleColor: .systemRed) { (_) in _utils.goToSettingsCarrifree() }
        let alert = MyUtils.shared.createAlert(title: MyStrings.alertNeedLocationPermissionTitle.rawValue, message: MyStrings.alertNeedLocationPermissionDesc01.rawValue, handlers: [ok], style: .alert, addCancel: true)
        self.present(alert, animated: true)
    }
}

extension HomeVc: HomeVmDelegate {
}

// MARK: - StorageListDelegate
extension HomeVc: StorageListDelegate {
    func onMap() {
        delegate?.onMap?()
    }
    
    func onAlignSelected(alignIndex: Int) {
        let align = AlignNearStorage.getAlign(index: alignIndex)
        getStorages(align: align)
    }
}

// MARK: - ReviewListDelegate
extension HomeVc: ReviewListDelegate {
    func onMore() {
        let vc = ReviewsVc()
        vc.dropdownMenu = [AlignNearReview.recent.name,
                           AlignNearReview.avg.name]
        
        let reviewMenuTitles: [String] = [StorageCategory.storage999.name,
                                          StorageCategory.storage006.name,
                                          StorageCategory.storage005.name,
                                          StorageCategory.storage003.name,
                                          StorageCategory.storage002.name,
                                          StorageCategory.storage001.name]
        
        vc.categories = reviewMenuTitles
        vc.homeVm = vm
        vc.selectedMenuIndex = reviews.getSelectedMenuIndex()
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen

        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.present(vc, animated: false, completion: nil)
    }
    
    func onReviewMenuSelected(index: Int) {
        getReviews()
    }
}

// MARK: - Actions
extension HomeVc {
    @IBAction func onGuide(_ sender: UIGestureRecognizer) {
        let vc = AppGuideVc()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

// MARK: - ReviewsVcDelegate
extension HomeVc: ReviewsVcDelegate {
    func reviewsVcDismissed() {
        getReviews()
    }
}

// MARK: - CLLocationManagerDelegate
extension HomeVc: CLLocationManagerDelegate {
    /*
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let resultLocation = manager.location else { return }
        
        CLGeocoder().reverseGeocodeLocation(resultLocation, completionHandler: { (placemarks, error)->Void in
                if error != nil {
//                    MyLog.logWithArrow("Reverse geocoder failed", error?.localizedDescription ?? "")
                    return
                }
                guard let placemarks = placemarks else { return }
                if placemarks.count > 0 {
//                    let clPlaceMark = placemarks[0] as CLPlacemark
//                    let mkPlaceMark = MKPlacemark(placemark: clPlaceMark)
//                    let address = _utils.parseAddress(pin: mkPlaceMark)
                    
                } else {
                    MyLog.log("Problem with the data received from geocoder")
                }
            })
    }
    */
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        MyLog.logWithArrow("get location failed", error.localizedDescription)
    }
    
    /// 위치 접근권한 변경 callback
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            MyLog.log("GPS 권한 설정됨")
            self.locationManager.startUpdatingLocation()
            configure()
        case .restricted, .notDetermined:
            MyLog.log("GPS 권한 설정되지 않음")
            locationManager.requestWhenInUseAuthorization()
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
            configure()
        } else if authStatus == .notDetermined || authStatus == .restricted {
            manager.requestWhenInUseAuthorization()
            MyLog.log("GPS 권한 설정되지 않음")
        } else if authStatus == .denied {
            MyLog.log("GPS 권한 요청 거부됨")
            createCantAccessAlert()
        }
    }
}
