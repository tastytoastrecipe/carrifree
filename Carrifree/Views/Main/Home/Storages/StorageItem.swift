//
//  StorageItem.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/10.
//
//
//  💬 StorageItem
//  메인(홈) 화면에서 표시되는 보관소
//

import UIKit

class StorageItem: UIView {

    @IBOutlet weak var board: UIView!
    @IBOutlet weak var storageImg: UIImageView!
    @IBOutlet weak var ratingImg: UIImageView!
    @IBOutlet weak var ratingTxt: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var infoHeightCnst: NSLayoutConstraint!

    var data: StorageData!
    var xibLoaded: Bool = false
    
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
        guard let view = self.loadNib(name: String(describing: StorageItem.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        
        self.clipsToBounds = false
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.2
        
        board.clipsToBounds = true
        board.layer.cornerRadius = 20
        board.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onBoard(_:))))
        
        _utils.setText(bold: .extraBold, size: 10, text: "", label: ratingTxt)
        _utils.setText(bold: .regular, size: 12, text: "", label: name)
        _utils.setText(bold: .bold, size: 15, text: "", label: distance)
        storageImg.image = UIImage(named: "img-default-store")
        storageImg.contentMode = .scaleAspectFill
    }
    
    func configure(data: StorageData) {
        configure()
        
        self.data = data
        
        // image
        storageImg.loadImage(url: data.imgUrl)
        
        // rating
        let rating = Ratings.getRatingByScore(score: data.rating)
        ratingImg.image = UIImage(named: rating.imgName)
        ratingTxt.textColor = rating.color
        ratingTxt.text = "\(data.rating)"
        
        // name
        name.text = data.name
        
        // distance
        distance.text = "\(data.distance)km"
         
        // gradient
        createGradient()
    }
    
    func createGradient() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            // gradation
            let gradientLayer = CAGradientLayer()
            let gradientHeight: CGFloat = 50
            let y = self.frame.height - self.infoHeightCnst.constant - gradientHeight
            gradientLayer.frame = CGRect(x: 0, y: y, width: self.frame.width, height: gradientHeight)
            
            let colors: [CGColor] = [
                .init(red: 1, green: 1, blue: 1, alpha: 0.0),
                .init(red: 1, green: 1, blue: 1, alpha: 1.0),
            ]
            
            gradientLayer.colors = colors
            gradientLayer.type = .axial
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.locations = [0.0, 0.95]
            self.storageImg.layer.addSublayer(gradientLayer)
        }
        
    }
}

// MARK: - Actions
extension StorageItem {
    @objc func onBoard(_ sender: UIGestureRecognizer) {
//        delegate?.onItemSelected?(item: self)
        _events.storageItemSelected(storageSeq: data.seq, storageName: data.name)
    }
}
