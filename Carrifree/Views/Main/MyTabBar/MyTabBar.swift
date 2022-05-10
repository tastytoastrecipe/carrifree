//
//  MyTabBar.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/19.
//

import UIKit

@objc protocol MyTabBarDelegate {
    @objc optional func itemSelected(index: Int)
}

class MyTabBar: UIView {
    
    @IBOutlet weak var stick: UIView!           // 윗부분만 그림자 효과를 주기위한 뷰
    @IBOutlet weak var stack: UIStackView!

    var delegate: MyTabBarDelegate!
    var xibLoaded: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    init(frame: CGRect, itemSources: [MyTab]) {
        super.init(frame: frame)
        configure(itemSources: itemSources)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: MyTabBar.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        
        stick.layer.shadowOffset = CGSize(width: 0, height: 0)
        stick.layer.shadowRadius = 3
        stick.layer.shadowOpacity = 0.1
        stick.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: -5, y: -5, width: stick.frame.width + 10, height: stick.frame.height + 10), cornerRadius: stick.layer.cornerRadius).cgPath
    }
    
    func configure(itemSources: [MyTab]) {
        configure()
        
        for source in itemSources {
            let item = MyTabItem(frame: CGRect.zero, title: source.title, normalImgName: source.imgname, selectedImgName: source.selectedImgname)
            item.delegate = self
            stack.addArrangedSubview(item)
            NSLayoutConstraint.activate([
                item.heightAnchor.constraint(equalToConstant: 70),
                item.widthAnchor.constraint(equalToConstant: 70)
            ])
        }
    }
    
    func select(index: Int) {
        for (i, subview) in stack.arrangedSubviews.enumerated() {
            guard let myItem = subview as? MyTabItem else { continue }
            if i == index {
                myItem.select()
//                delegate.itemSelected?(index: index)
            }
        }
    }
}

// MARK:- MyTabItemDelegate
extension MyTabBar: MyTabItemDelegate {
    func selected(item: MyTabItem) {
        var index: Int = 0
        for (i, subview) in stack.arrangedSubviews.enumerated() {
            guard let myItem = subview as? MyTabItem else { continue }
            if myItem == item { index = i; continue }
            myItem.deselect()
        }
        
        delegate.itemSelected?(index: index)
    }
}
