//
//  PointMenu.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/11.
//

import UIKit

@objc protocol PointMenuDelegate {
    @objc optional func onPointMenuSelected(item: PointItem)
}

class PointMenu: UIView {

    @IBOutlet weak var stack: UIStackView!
    
    var delegate: PointMenuDelegate?
    var items: [PointItem] = []
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
        guard let view = self.loadNib(name: String(describing: PointMenu.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
    }
    
    func configure(itemTitles: [String], selectedIndex: Int = 0) {
        configure()
        
        for (index, title) in itemTitles.enumerated() {
            let item = PointItem(frame: .zero, title: title, selected: index == selectedIndex)
            item.delegate = self
            item.tag = index
            items.append(item)
            stack.addArrangedSubview(item)
//            item.widthAnchor.constraint(equalToConstant: 56).isActive = true
        }
    }
    
    func getSelectedItemIndex() -> Int {
        return items.filter({ $0.selected }).first?.tag ?? 0
    }
    
    func getMenuCount() -> Int {
        return items.count
    }

}

extension PointMenu: PointItemDelegate {
    func onPointItemSelected(selectedItem: PointItem) {
        for item in items {
            let isSelectedItem = (item == selectedItem)
            if isSelectedItem { continue }
            else { item.setSelected(selected: false) }
        }
        
        delegate?.onPointMenuSelected?(item: selectedItem)
    }
}
