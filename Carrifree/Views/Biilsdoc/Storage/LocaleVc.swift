//
//  LocaleVc.swift
//  TestProject
//
//  Created by orca on 2022/02/15.
//
//
//  💬 LocaleVc
//  특정한 위치만을 표시하기 위한 view controller
//

import UIKit
import MapKit

class LocaleVc: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    var localeName: String = ""
    var locale: (lat: Double, lng: Double) = (0, 0)
    var regionRadius: Double = 2000.0
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        map.showsUserLocation = true
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// 현재위치로 이동
    func setCurrentLocation() {
        var coordinate: CLLocationCoordinate2D?
        if locale.lat == 0 && locale.lng == 0 {
            coordinate = locationManager.location?.coordinate
        } else {
            coordinate = CLLocationCoordinate2D(latitude: locale.lat, longitude: locale.lng)
            if coordinate == nil { coordinate = locationManager.location?.coordinate }
        }
        
        let clLocation = CLLocationCoordinate2D(latitude: coordinate?.latitude ?? 0.0, longitude: coordinate?.longitude ?? 0.0)
        let region = MKCoordinateRegion(center: clLocation, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        map.setRegion(region, animated: true)
        createPin(coordinate: coordinate)
    }

    
    /// 핀(Annotation) 생성
    func createPin(coordinate: CLLocationCoordinate2D?)
    {
        guard let coordinate = coordinate else { return }
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = localeName
        map.addAnnotation(annotation)
    }
    
    /// 위치 접근 권한 없음 Alert 표시
    func createCantAccessAlert() {
        let ok = _utils.createAlertAction(title: MyStrings.ok.rawValue, titleColor: .systemRed) { (_) in _utils.goToSettingsCarrifree() }
        let alert = _utils.createAlert(title: MyStrings.alertNeedLocationPermissionTitle.rawValue, message: MyStrings.alertNeedLocationPermissionDesc01.rawValue, handlers: [ok], style: .alert, addCancel: true)
        self.present(alert, animated: true)
    }

}

// MARK: - Actions
extension LocaleVc {
    @IBAction func onExit(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension LocaleVc: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let resultLocation = manager.location else { return }
        
        CLGeocoder().reverseGeocodeLocation(resultLocation, completionHandler: { (placemarks, error)->Void in
                if error != nil {
                    MyLog.logWithArrow("Reverse geocoder failed", error?.localizedDescription ?? "")
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        MyLog.logWithArrow("get location failed", error.localizedDescription)
    }
    
    /// 위치 접근권한 변경 callback
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            MyLog.log("GPS 권한 설정됨")
            self.locationManager.startUpdatingLocation()
            setCurrentLocation()
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
//            CarryEvents.shared.callLocationAccessAuthorized()
            setCurrentLocation()
        } else if authStatus == .notDetermined || authStatus == .restricted {
            manager.requestWhenInUseAuthorization()
            MyLog.log("location authorization: notDetermined")
//            createCantAccessAlert()
        } else if authStatus == .denied {
            MyLog.log("location authorization: denied")
//            CarryEvents.shared.callLocationAccessDenied()
            createCantAccessAlert()
        }
    }
}


