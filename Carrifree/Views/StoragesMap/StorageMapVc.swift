//
//  StorageMapVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/12.
//
//
//  💬 StorageMapVc
//  보관 검색 화면
//

import UIKit
import MapKit
import CoreLocation

class StorageMapVc: UIViewController {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var lookupView: LookupView!
    @IBOutlet weak var storage: StorageMapItem!
    
    var vm: StorageMapVm!
    var locationManager: CLLocationManager!
    var searchController: UISearchController!
    var field: UITextField!
    var regionRadius: Double = 1000.0
    var relatedWordsVc: RelatedWordsVc!
//    var selectedStorage: StorageData!
    var selectedStorageSeq: String = ""
    var selectedStorageName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        configure()
    }
    
    func viewWillAppear() {
        configure()
    }
    
    func viewWillHide() {
        self.parent?.view.endEditing(false)
        lookupView.isHidden = false
        storage.isHidden = true
        reset()
    }

    // 모든 데이터를 초기값으로 설정
    func reset() {
//        selectedStorage = nil
        selectedStorageSeq = ""
        
        field.text = ""
        
        if nil != vm {
            vm.reset()
        }
        
        if nil != relatedWordsVc {
            setRelatedWordsVcHidden(hidden: true)
//            relatedWordsVc.view.removeFromSuperview()
//            relatedWordsVc.removeFromParent()
        }
        
        lookupView.reset()
        map.removeAnnotations(map.annotations)
    }
    
    func configure() {
        if nil == vm || nil == locationManager {
            vm = StorageMapVm()
            
            map.delegate = self
            map.showsUserLocation = true
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
            field.addTarget(self, action: #selector(self.textFieldBeginEditing(_:)), for: .editingDidBegin)
            field.addTarget(self, action: #selector(self.textFieldEndEditing(_:)), for: .editingDidEnd)
            field.addTarget(self, action: #selector(self.textFieldEditingChanged(_:)), for: .editingChanged)
        } else {
            locationManager.startUpdatingLocation()
        }
        
        setHotWords()
//        setSelectedStorage(storage: selectedStorage)
        setSelectedStorage(storageSeq: selectedStorageSeq, storageName: selectedStorageName)
    }
    
    func setHotWords() {
        let tempLat = locationManager.location?.coordinate.latitude ?? 0
        let tempLng = locationManager.location?.coordinate.longitude ?? 0
        if (tempLng == 0 && tempLat == 0) { return }
        
        vm.getHotWords(lat: tempLat, lng: tempLng) { (_, _) in
            self.lookupView.configure(keywords: self.vm.hotWords)
            self.lookupView.delegate = self
        }
    }
    
    /// 현재위치로 이동
    func setCurrentLocation() {
        var coordinate: CLLocationCoordinate2D?
        if nil == vm.currentStorage {
            coordinate = locationManager.location?.coordinate
        } else {
            coordinate = CLLocationCoordinate2D(latitude: vm.currentStorage.lat, longitude: vm.currentStorage.lng)
            if coordinate == nil { coordinate = locationManager.location?.coordinate }
            storage.configure(detailData: vm.currentStorage)
            storage.isHidden = false
            lookupView.isHidden = true
        }
        
        let clLocation = CLLocationCoordinate2D(latitude: coordinate?.latitude ?? 0.0, longitude: coordinate?.longitude ?? 0.0)
        let region = MKCoordinateRegion(center: clLocation, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        map.setRegion(region, animated: true)
    }
    
    /// 원하는 위치로 이동
    func moveMap(lat: Double, lng: Double) {
        if lat == 0 && lng == 0 { createLoadFailedAlert(msg: ""); return }
        
        let clLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let region = MKCoordinateRegion(center: clLocation, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        map.setRegion(region, animated: true)
    }
    
    /// 현재 선택된 보관소 설정
    func setSelectedStorage(storageSeq: String, storageName: String) {
        if storageSeq.isEmpty { return }
        guard let coordinate = locationManager.location?.coordinate else { return }
        self.selectedStorageSeq = storageSeq
        self.vm.storages.removeAll()
        lookupView.isHidden = true
        setRelatedWordsVcHidden(hidden: true)
//        field.text = storage?.name ?? ""
        field.resignFirstResponder()
        
        if false == _utils.createIndicator() { return }
        vm.getStorage(currentLat: coordinate.latitude, currentLng: coordinate.longitude, storageSeq: storageSeq, word: storageName) { (success, msg) in
            _utils.removeIndicator()
            
            guard success else {
                self.createLoadFailedAlert(msg: msg)
                return
            }
            self.lookupDone()
            self.field.text = self.vm.currentStorage.name
        }
    }

    /// 검색된 결과를 맵에 표시함
    func lookupDone() {
        var storage: StorageMapData!
        if self.vm.storages.count > 0 {
            self.vm.currentStorage = self.vm.storages[0]
            storage = self.vm.currentStorage
        }
        else {
            self.createLoadFailedAlert(msg: "")
            return
        }
        self.addStorage(datas: self.vm.storages)
        self.moveMap(lat: storage.lat, lng: storage.lng)
        self.lookupView.isHidden = true
//        self.storage.isHidden = false
    }
    
    /// 핀(Annotation) 생성
    func createPin(targetPin: MKPlacemark?, data: StorageMapData? = nil)
    {
        guard let pin = targetPin else { return }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinate
        
        if let data = data {
            annotation.subtitle = data.address
        } else {
            annotation.subtitle = "\(pin.locality ?? "") \(pin.administrativeArea ?? "")"
        }
        
        map.addAnnotation(annotation)
    }
    
    /// 지도에 보관소 추가
    func addStorage(datas: [StorageMapData]) {
        for data in datas {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: data.lat, longitude: data.lng)
            annotation.title = data.name
            annotation.subtitle = data.address
            map.addAnnotation(annotation)
         
            // 현재 선택된 보관소를 선택 상태로 변경
            if data == vm.currentStorage {
                map.selectAnnotation(annotation, animated: true)
            }
        }
    }
   
    /*
    /// 선택된 보관소 표시
    func setSelectedStorage(selectedStorage: StorageData) {
        // 선택된 보관소 주변의 다른 보관소들을 서버에 다시 요청한 후
        // 기존의 모든 보관소(annotation)을 지우고
        // 새로 받아온 보관소들을 표시함
        self.selectedStorage = selectedStorage
        vm.setCurrentStorageByName(name: selectedStorage.name)
//        vm.getStorages()
        removeAllStorages()
        addStorage(datas: vm.storages)
        
        vm.setCurrentStorageByName(name: selectedStorage.name)
        setCurrentLocation()
    }
    */
    
    /// 위치 접근 권한 없음 Alert 표시
    func createCantAccessAlert() {
        let ok = MyUtils.shared.createAlertAction(title: MyStrings.ok.rawValue, titleColor: .systemRed) { (_) in _utils.goToSettingsCarrifree() }
        let alert = MyUtils.shared.createAlert(title: MyStrings.alertNeedLocationPermissionTitle.rawValue, message: MyStrings.alertNeedLocationPermissionDesc01.rawValue, handlers: [ok], style: .alert, addCancel: true)
        self.present(alert, animated: true)
    }
    
    /// 연관 검색어 UI 표시
    func setRelatedWordsVcHidden(hidden: Bool) {
        if hidden {
            if false == relatedWordsVc?.view.isHidden { relatedWordsVc?.view.isHidden = true }
            return
        }
        
        guard nil == relatedWordsVc else {
            if true == relatedWordsVc?.view.isHidden { relatedWordsVc?.view.isHidden = false }
            return
        }
        
        relatedWordsVc = RelatedWordsVc()
        relatedWordsVc.view.layer.cornerRadius = 5
        relatedWordsVc.map = map
        relatedWordsVc.locationManager = locationManager
        relatedWordsVc.delegate = self
        
        self.addChild(relatedWordsVc)
        self.view.addSubview(relatedWordsVc.view)
        relatedWordsVc.didMove(toParent: self)
        
        relatedWordsVc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            relatedWordsVc.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -14),
            relatedWordsVc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            relatedWordsVc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            relatedWordsVc.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        ])
    }
    
    /// 모든 보관소(Annotation) 제거
    func removeAllStorages() {
        map.removeAnnotations(map.annotations)
    }
    
    /// 주변 보관소 표시
    func setStoragesNearby() {
        getStoragesNearby() {
            self.lookupView.isHidden = true
            self.addStorage(datas: self.vm.storages)
        }
    }
    
    /// 주변 보관소 목록 받아오기
    func getStoragesNearby(completion: (() -> Void)? = nil) {
        let tempLat = locationManager.location?.coordinate.latitude ?? 0
        let tempLng = locationManager.location?.coordinate.longitude ?? 0
        if (tempLng == 0 && tempLat == 0) { return }
        
        vm.lookupStoragesNearby(lat: tempLat, lng: tempLng) { (success, msg) in
            guard success else {
                let alert = _utils.createSimpleAlert(title: "보관소 검색", message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
                return
            }
            
            completion?()
        }
    }
    
    /// 보관소 정보를 불러오지 못했을때 Alert 표시
    func createLoadFailedAlert(msg: String) {
        var message = msg
        if message.isEmpty { message = "검색한 보관소의 정보를 불러오지 못했습니다. 다시 시도해주시기 바랍니다." }
        let alert = _utils.createSimpleAlert(title: "보관소 정보", message: msg, buttonTitle: _strings[.ok])
        self.present(alert, animated: true)
    }
}

// MARK: - Actions
extension StorageMapVc {
    @objc func textFieldBeginEditing(_ sender: UITextField) {
        lookupView.isHidden = false
        let lat = locationManager.location?.coordinate.latitude ?? 0
        let lng = locationManager.location?.coordinate.longitude ?? 0
        if lat == 0 && lng == 0 { createCantAccessAlert(); return }
    }
    
    @objc func textFieldEndEditing(_ sender: UITextField) {
        if sender.text?.isEmpty == false { lookupView.isHidden = true }
        setRelatedWordsVcHidden(hidden: true)
    }
    
    @objc func textFieldEditingChanged(_ sender: UITextField) {
        let lat = locationManager.location?.coordinate.latitude ?? 0
        let lng = locationManager.location?.coordinate.longitude ?? 0
        if lat == 0 && lng == 0 { return }
        
        let word = sender.text ?? ""
        setRelatedWordsVcHidden(hidden: word.isEmpty)
//        lookupView.isHidden = !word.isEmpty
        if word.isEmpty { return }
        
        relatedWordsVc.updateWord(lat: lat, lng: lng, word: word)
    }
}

// MARK: - MKMapViewDelegate
extension StorageMapVc: MKMapViewDelegate {
    /// 지도에 표시된 pin을 터치했을때
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let lat = view.annotation?.coordinate.latitude ?? 0
        let lng = view.annotation?.coordinate.longitude ?? 0
        for storage in vm.storages {
            if storage.lat == lat && storage.lng == lng {
                vm.currentStorage = storage
                self.storage.isHidden = false
                self.storage.configure(detailData: storage)
                break
            }
        }
    }
    
}

// MARK: - LookupViewDelegate
extension StorageMapVc: LookupViewDelegate {
    func lookupViewHide() {
        field.resignFirstResponder()
    }
    
    func lookupViewLookup() {
        /*
        if nil == relatedWordsVc { return }
        if relatedWordsVc.matchingItems.isEmpty { return }
        
        lookupView.isHidden = true
        field.resignFirstResponder()
        self.setEditing(false, animated: true)
        setRelatedWordsVcHidden(hidden: true)
        removeAllStorages()
        
        var datas: [StorageMapData] = []
        for item in relatedWordsVc.matchingItems {
            var data = StorageMapData(name: item.name ?? "")
            data.setLat(lat: item.placemark.coordinate.latitude)
            data.setLng(lng: item.placemark.coordinate.longitude)
            data.setAddress(address: _utils.parseAddress(pin: item.placemark))
            datas.append(data)
        }
        
        addStorage(datas: datas)
        */
        
        setStoragesNearby()
    }
    
    func hotWordSelected(word: String) {
        guard let coordinate = locationManager.location?.coordinate else {
            let alert = _utils.createSimpleAlert(title: "보관소 정보", message: "검색한 보관소의 정보를 불러오지 못했습니다. 다시 시도해주시기 바랍니다.\n(current location is empty)", buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
            return
        }
        
        vm.getStorage(currentLat: coordinate.latitude, currentLng: coordinate.longitude, word: word) { (success, msg) in
            guard success else {
                let alert = _utils.createSimpleAlert(title: "보관소 정보", message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
                return
            }
            self.lookupDone()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension StorageMapVc: CLLocationManagerDelegate {
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

extension StorageMapVc: RelatedWordsVcDelegate {
    /*
    func selected(pin: MKPlacemark, move: Bool, address: String) {
        setRelatedWordsVcHidden(hidden: true)
        onLookup()
    }
    */
    
    func selected(storage: MatchingStorage, move: Bool) {
        setSelectedStorage(storageSeq: storage.seq, storageName: storage.name)
    }
    
    func receiveStoragesNearby(storages: [MatchingStorage]) {
    }
}


// MARK:- UISearchController
extension StorageMapVc: UISearchControllerDelegate, UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        _log.logWithArrow("UISearchControllerDelegate", "searchBarTextDidBeginEditing(_:)")
    }
}

