//
//  StorageMapItem.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/14.
//

import UIKit

class StorageMapItem: UIView {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var open: UILabel!
    @IBOutlet weak var statusTitle: UILabel!
    @IBOutlet weak var statusDesc: UILabel!
    @IBOutlet weak var ratingImg: UIImageView!
    @IBOutlet weak var ratingTxt: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    var simpleData: MatchingStorage!
    var detailData: StorageMapData!
    var xibLoaded: Bool = false
    var configured: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: StorageMapItem.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        if configured { return }
        configured = true
        loadXib()
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 16
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.25
        
        _utils.setText(bold: .regular, size: 11, text: "", label: category)
        _utils.setText(bold: .bold, size: 17, text: "", label: name)
        _utils.setText(bold: .regular, size: 12, text: "", label: address)
        _utils.setText(bold: .bold, size: 14, text: "", label: open)
        _utils.setText(bold: .regular, size: 11, text: "", label: statusTitle)
        _utils.setText(bold: .bold, size: 14, text: "", label: statusDesc)
        _utils.setText(bold: .extraBold, size: 10, text: "", label: ratingTxt)
        _utils.setText(bold: .extraBold, size: 11, text: "", label: distance)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onSelected(_:))))
        
        img.image = UIImage(named: "img-default-store")
    }
    
    func configure(detailData: StorageMapData) {
        configure()
        setData(detailData: detailData)
    }
    
    func setData(detailData: StorageMapData) {
        self.detailData = detailData
        
        // category
        category.text = StorageCategory(rawValue: detailData.category)?.name ?? ""
        
        // name
        name.text = detailData.name
        
        // address
        address.text = detailData.address
        
        // open/close
        if detailData.available { open.text = "이용가능" }
        else                    { open.text = "이용불가" }
        
        // status
        statusTitle.text = "보관상태:"
        statusDesc.text = detailData.status
        
        // rating
        let rating = Ratings.getRatingByScore(score: detailData.rating)
        ratingImg.image = UIImage(named: rating.imgName)
        ratingTxt.textColor = rating.color
        ratingTxt.text = "\(detailData.rating)"
        
        // distance
        distance.text = "\(detailData.distance)km 이내"
        
        // image
        img.image = UIImage(named: "img-default-store")
        img.loadImage(url: detailData.imgUrl)
//        img.image = UIImage(named: detailData.imgUrl)
        img.contentMode = .scaleAspectFill
    }
    
    func configure(simpleData: MatchingStorage) {
        configure()
        setData(simpleData: simpleData)
    }
    
    func setData(simpleData: MatchingStorage) {
        self.simpleData = simpleData
        
        // name
        name.text = simpleData.name
        
        // address
        address.text = simpleData.address
    }
    
    func createSimpleAlert(msg: String) {
        let alert = _utils.createSimpleAlert(title: "오류", message: msg, buttonTitle: _strings[.ok])
        _utils.topViewController()?.present(alert, animated: true)
    }
}

// MARK: - Actions
extension StorageMapItem {
    @objc func onSelected(_ sender: UIGestureRecognizer) {
        guard detailData.available else { return }
        
        var storageSeq = detailData?.seq ?? ""
        if storageSeq.isEmpty { storageSeq = simpleData?.seq ?? "" }
        if storageSeq.isEmpty { createSimpleAlert(msg: "잘못된 보관소 정보입니다.\n(empty seq)"); return }
        
        let lat = detailData?.lat ?? 0
        let lng = detailData?.lng ?? 0
        if lat == 0 && lng == 0 { createSimpleAlert(msg: "잘못된 보관소 정보입니다.\n(location nil)"); return }
        
        let vc = StorageDetailVc()
        vc.storageSeq = storageSeq
        vc.lat = lat
        vc.lng = lng
        vc.modalPresentationStyle = .fullScreen
        _utils.topViewController()?.present(vc, animated: true)
    }
}
