//
//  LocaleVc.swift
//  TestProject
//
//  Created by orca on 2022/02/15.
//
//
//  π¬ LocaleVc
//  νΉμ ν μμΉλ§μ νμνκΈ° μν view controller
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
    
    /// νμ¬μμΉλ‘ μ΄λ
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

    
    /// ν(Annotation) μμ±
    func createPin(coordinate: CLLocationCoordinate2D?)
    {
        guard let coordinate = coordinate else { return }
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = localeName
        map.addAnnotation(annotation)
    }
    
    /// μμΉ μ κ·Ό κΆν μμ Alert νμ
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
    
    /// μμΉ μ κ·ΌκΆν λ³κ²½ callback
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            MyLog.log("GPS κΆν μ€μ λ¨")
            self.locationManager.startUpdatingLocation()
            setCurrentLocation()
        case .restricted, .notDetermined:
            MyLog.log("GPS κΆν μ€μ λμ§ μμ")
            locationManager.requestWhenInUseAuthorization()
            createCantAccessAlert()
        case .denied:
            MyLog.log("GPS κΆν μμ²­ κ±°λΆλ¨")
            locationManager.requestWhenInUseAuthorization()
            createCantAccessAlert()
        default:
            MyLog.log("GPS: Default")
        }
    }
    
    /// μμΉ μ κ·ΌκΆν λ³κ²½ callback  (iOS 14 μ΄μ)
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


