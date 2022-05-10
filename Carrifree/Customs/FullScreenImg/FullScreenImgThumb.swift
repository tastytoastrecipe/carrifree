//
//  FullScreenImgThumb.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/20.
//

import UIKit

protocol FullScreenImgThumbDelegate {
    func thumbSelected(tag: Int)
}

class FullScreenImgThumb: UIView {

    @IBOutlet weak var img: UIImageView!
    
    var isSelected: Bool = false
    var delegate: FullScreenImgThumbDelegate?
    var xibLoaded: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }

    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: FullScreenImgThumb.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        self.clipsToBounds = false
        self.layer.borderColor = UIColor.systemYellow.cgColor
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onSelected(_:))))
        
        img.contentMode = .scaleAspectFill
    }
    
    func configure(imgUrl: String, tag: Int, selected: Bool = false) {
        configure()
        self.isSelected = selected
        self.tag = tag
        
        if imgUrl.count > 0 {
            img.loadImage(url: imgUrl)
        }
    }
    
    func configure(imgData: Data?, tag: Int, selected: Bool = false) {
        configure()
        self.tag = tag
        if let imgData = imgData { img.image = UIImage(data: imgData) }
        setSelected(selected: selected)
        if selected { delegate?.thumbSelected(tag: tag) }
    }
    
    func setSelected(selected: Bool) {
        self.isSelected = selected
        if selected {
            self.layer.borderWidth = 2
        } else {
            self.layer.borderWidth = 0
        }
    }
}

// MARK: - Actions
extension FullScreenImgThumb {
    @objc func onSelected(_ sender: UIGestureRecognizer) {
        if isSelected { return }
        setSelected(selected: !isSelected)
        delegate?.thumbSelected(tag: self.tag)
    }
}
