//
//  MyTabItem.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/19.
//

import UIKit

@objc protocol MyTabItemDelegate {
    @objc optional func selected(item: MyTabItem)
}

class MyTabItem: UIView {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!

    var delegate: MyTabItemDelegate!
    var normalFont: UIFont!
    var selectedFont: UIFont!
    var normalColor: UIColor!
    var selectedColor: UIColor!
    var normalImg: UIImage!
    var selectedImg: UIImage!
    var isSelected: Bool = false
    var xibLoaded: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    init(frame: CGRect, title: String, normalImgName: String, selectedImgName: String) {
        super.init(frame: frame)
        configure(title: title, normalImgName: normalImgName, selectedImgName: selectedImgName)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: MyTabItem.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        normalFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        selectedFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        normalColor = .systemGray
        selectedColor = .label
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:))))
    }
    
    func configure(title: String, normalImgName: String, selectedImgName: String) {
        configure()
        
        self.title.text = title
        setNormalImage(imgName: normalImgName)
        setSelectedImage(imgName: selectedImgName)
        if selectedImg == nil { selectedImg = normalImg }
        
        update()
    }
    
    func setNormalImage(imgName: String) {
        normalImg = UIImage(named: imgName)
        if nil == normalImg { normalImg = UIImage(systemName: imgName) }
    }
    
    func setSelectedImage(imgName: String) {
        selectedImg = UIImage(named: imgName)
        if nil == selectedImg { selectedImg = UIImage(systemName: imgName) }
    }

    // update item status
    func update() {
        if isSelected {
            img.image = selectedImg
            title.font = selectedFont
            title.textColor = selectedColor
        } else {
            img.image = normalImg
            title.font = normalFont
            title.textColor = normalColor
        }
    }
    
    // select item
    func select() {
        if isSelected { return }
        
        isSelected = true
        update()
        
        if isSelected { delegate.selected?(item: self) }
    }
    
    // deselect item
    func deselect() {
        if false == isSelected { return }
        
        isSelected = false
        update()
    }
}

// MARK:- Actions
extension MyTabItem {
    @objc func onTap(_ sender: UIGestureRecognizer) {
        select()
    }
}

