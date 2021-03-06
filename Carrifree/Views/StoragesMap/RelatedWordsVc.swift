//
//  RelatedWordsVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/13.
//
//
//  π¬ RelatedWordsVc
//  μ°κ΄ κ²μμ΄λ₯Ό νμ ViewController
//

import UIKit
import MapKit

@objc protocol RelatedWordsVcDelegate {
    /// μ°κ΄ κ²μμ΄ μ€ νκ°λ₯Ό μ ννμ κ²½μ° (μ νλ§΅μμ μ κ³΅νλ μ°κ΄ κ²μμ΄)
    @objc optional func selected(pin: MKPlacemark, move: Bool, address: String)     // move: ν΄λΉ νμ μμΉκ° μ€μμ μ€λλ‘ νλ©΄ μ΄λν μ§ μ¬λΆ
    
    /// μ°κ΄ κ²μμ΄ μ€ νκ°λ₯Ό μ ννμ κ²½μ° (μλ²μμ λ°μμ¨ μ°κ΄ κ²μμ΄)
    @objc optional func selected(storage: MatchingStorage, move: Bool)              // move: ν΄λΉ νμ μμΉκ° μ€μμ μ€λλ‘ νλ©΄ μ΄λν μ§ μ¬λΆ
    
    /// μ£Όλ³ λ³΄κ΄μ κ²μλ¨
    @objc optional func receiveStoragesNearby(storages: [MatchingStorage])
}

class RelatedWordsVc: UITableViewController {
    
    var matchingItems: [MKMapItem] = []
    var map: MKMapView? = nil
    var field: UITextField!
    
    var locationManager: CLLocationManager!
    var tempLat: Double = 0
    var tempLng: Double = 0
    var tempWord: String = ""
    
    var vm: RelatedWordsVm!
    var delegate: RelatedWordsVcDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
//            tableView.contentInset = UIEdgeInsets.init(top: 64, left: 0, bottom: 44, right: 0)
        }
        else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        let cellId = String(describing: UITableViewCell.self)
        let xib = UINib(nibName: cellId, bundle: nil)
        tableView.register(xib, forCellReuseIdentifier: cellId)
        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableView.automaticDimension

        vm = RelatedWordsVm()
        vm.delegate = self
    }
    
    /*
    /// κ²μμ΄  κ°±μ  (μ νλ§΅μμ μ κ³΅νλ μ°κ΄ κ²μμ΄ μ¬μ©)
    func updateWord(word: String) {
        guard let map = map else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = word
        request.region = map.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    */
    
    /// κ²μμ΄ κ°±μ  (μλ²μμ λ°μ μ°κ΄ κ²μμ΄ μ¬μ©)
    func updateWord(lat: Double, lng: Double, word: String) {
        tempLat = lat
        tempLng = lng
        tempWord = word
        vm.startLookupDelay()
    }
    
    /// κ²μμ΄κ° νμλ  λ·°μ λμ΄ μ€μ 
    func setContentHeight() {
        for cnst in self.view.constraints {
            if cnst.firstAttribute == .height {
                cnst.constant = (Double(self.vm.matchingStorages.count) * self.tableView.estimatedRowHeight) + 8
                return
            }
        }
    }
    
}

// MARK: - Actions
extension RelatedWordsVc {
    /// κ²μ
    @objc func onLookup(_ sender: UIButton) {
    }
}

// MARK: - UITableViewController
extension RelatedWordsVc {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.matchingStorages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let storage = vm.matchingStorages[indexPath.row]
        
        // title (λ³΄κ΄μ μ΄λ¦)
        var content = cell.defaultContentConfiguration()
        content.text = storage.name

        // subtitle (λ³΄κ΄μ μ£Όμ)
        let secondaryTextFont = UIFont(name: BoldCase.regular.name, size: 11) ?? UIFont.systemFont(ofSize: 11)
        content.secondaryAttributedText = NSAttributedString(string: storage.address, attributes: [ .font: secondaryTextFont, .foregroundColor: UIColor.systemGray ])
        cell.contentConfiguration = content
        
        // custom text (κ±°λ¦¬)
        let distance = UILabel()
        _utils.setText(bold: .regular, size: 11, text: "\(storage.distance)km", color: UIColor.systemGray, label: distance)
        distance.sizeToFit()
        let cellFrame = cell.frame
        let distanceFrame = distance.frame
        let xPadding: CGFloat = 8
        let x = cellFrame.width - distanceFrame.width - xPadding
        let y = cellFrame.midY + 14
        distance.frame.origin = CGPoint(x: x, y: y)
        cell.addSubview(distance)
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        let pin = matchingItems[indexPath.row].placemark
        delegate?.selected?(pin: pin, move: true, address: MyUtils.shared.parseAddress(pin: pin, nameInclude: true))
         */
        
        let index = indexPath.row
        let storage = vm.matchingStorages[index]
        delegate?.selected?(storage: storage, move: true)
    }
    
    
}

extension RelatedWordsVc: RelatedWordsVmDelegate {
    func lookupDelayed() {
        if (tempLng == 0 && tempLat == 0) || tempWord.isEmpty { return }
        
        // κ²μ
        vm.lookup(lat: tempLat, lng: tempLng, word: tempWord) { (success, msg) in
            guard success else {
                let alert = _utils.createSimpleAlert(title: "λ³΄κ΄μ κ²μ", message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
                return
            }
            
            self.tableView.reloadData()
            self.setContentHeight()
        }
    }
}


