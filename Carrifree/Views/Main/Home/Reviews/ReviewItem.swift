//
//  ReviewItem.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/11.
//
//
//  💬 ReviewItem
//  리뷰 목록의 각 아이템
//

import UIKit

class ReviewItem: UIView {

    @IBOutlet weak var board: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var bizname: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var like: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var ratingImg: UIImageView!
    @IBOutlet weak var ratingTxt: UILabel!
    
    var data: ReviewData!
    var xibLoaded: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    init(frame: CGRect, data: ReviewData) {
        super.init(frame: frame)
        configure(data: data)
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: ReviewItem.self)) else { return }
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
        self.backgroundColor = .clear

        board.clipsToBounds = true
        board.layer.cornerRadius = 10
        
        _utils.setText(bold: .regular, size: 13, text: "", label: bizname)
        _utils.setText(bold: .bold, size: 16, text: "", label: title)
        _utils.setText(bold: .regular, size: 10, text: "", color: _symbolColor, label: username)
        if nil != like { _utils.setText(bold: .regular, size: 12, text: "", color: _symbolColor, label: like) }
        img.image = UIImage(named: "img-no-review")
        img.tintColor = .systemGray4
    }
    
    func configure(data: ReviewData) {
        configure()
        self.data = data
        bizname.text = data.bizname
        title.text = data.content
        username.text = "\(data.username)님의 작성 후기"
        if nil != like { like.text = "\(data.like)" }
        
        
        img.loadImage(url: data.imgUrl)
//        img.image = UIImage(named: data.imgUrl)
        img.contentMode = .scaleAspectFill
        
        // rating
        let rating = Ratings.getRatingByScore(score: data.rating)
        ratingImg.image = UIImage(named: rating.imgName)
        ratingTxt.textColor = rating.color
        ratingTxt.text = "\(data.rating)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            self.setEffects()
        }
    }
    
    func setEffects() {
        let width = self.frame.width
        let height = self.frame.height
        let imgWidth = img.frame.width
        
        /*
        // gradation
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: imgWidth * 0.4, height: self.frame.height)
        
        let colors: [CGColor] = [
           .init(red: 0, green: 0, blue: 0, alpha: 0.8),
           .init(red: 0, green: 0, blue: 0, alpha: 0),
        ]
        gradientLayer.colors = colors
        gradientLayer.type = .axial
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.locations = [0.1, 1.0]
        img.layer.addSublayer(gradientLayer)
        
        // 평가 UI를 gradient 레이어 위로 배치함 (레이어 새로 생성하면 가려지기 때문에)
        board.bringSubviewToFront(ratingImg)
        board.bringSubviewToFront(ratingTxt)
        */
        
        // trapezium
        let path = CGMutablePath()
        path.move(to: CGPoint(x: imgWidth, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: imgWidth - 26, y: height))

        let shape = CAShapeLayer()
        shape.path = path
        shape.fillColor = UIColor.white.cgColor
        board.layer.addSublayer(shape)
        
        // 표시될 정보들을 trapezium 레이어 위로 배치함 (레이어 새로 생성하면 가려지기 때문에)
        board.bringSubviewToFront(infoView)
        
        // unerline
        let underline = UIView()
        underline.backgroundColor = UIColor(red: 242/255, green: 123/255, blue: 87/255, alpha: 1)
        underline.layer.cornerRadius = 0.5
        board.addSubview(underline)
        underline.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            underline.leadingAnchor.constraint(equalTo: img.trailingAnchor, constant: -22),
            underline.trailingAnchor.constraint(equalTo: board.trailingAnchor, constant: -7),
            underline.bottomAnchor.constraint(equalTo: board.bottomAnchor, constant: -10),
            underline.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // half arrow
        let arrow = UIView()
        arrow.backgroundColor = UIColor(red: 242/255, green: 123/255, blue: 87/255, alpha: 1)
        arrow.layer.cornerRadius = 0.5
        board.addSubview(arrow)
        
        arrow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arrow.leadingAnchor.constraint(equalTo: board.trailingAnchor, constant: -21),
            arrow.bottomAnchor.constraint(equalTo: board.bottomAnchor, constant: -16),
            arrow.widthAnchor.constraint(equalToConstant: 16),
            arrow.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        arrow.transform = CGAffineTransform(rotationAngle: .pi / 4)
    }
    
    
}

// MARK: - Actions
extension ReviewItem {
    @IBAction func onSelected(_ sender: UIGestureRecognizer) {
        let vc = ReviewDetailVc()
        vc.reviewSeq = data.seq
        vc.attachGrpSeq = data.attachGrpSeq
        vc.modalPresentationStyle = .overFullScreen
        _utils.topViewController()?.present(vc, animated: false)
    }
}


