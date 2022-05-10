//
//  PointItem.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/11.
//

import UIKit

@objc protocol PointItemDelegate {
    @objc optional func onPointItemSelected(selectedItem: PointItem)
}

class PointItem: UIView {

    @IBOutlet weak var board: UIView!
    @IBOutlet weak var point: UILabel!
    @IBOutlet weak var title: UILabel!
    
    var delegate: PointItemDelegate?
    var selected: Bool = false
    var xibLoaded: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    init(frame: CGRect, title: String, tag: Int = 0, selected: Bool = false) {
        super.init(frame: frame)
        configure(title: title, selected: selected)
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: PointItem.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        
        board.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onSelected(_:))))
        _utils.setText(bold: .bold, size: 17, text: "", label: title)
    }

    func configure(title: String, selected: Bool = false) {
        configure()
        
        self.title.text = title
        setSelected(selected: selected)
        
        self.title.sizeToFit()
        let width = self.title.frame.width + 16
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func setSelected(selected: Bool) {
        self.selected = selected
        
        if selected {
            title.textColor = UIColor(red: 242/255, green: 123/255, blue: 87/255, alpha: 1)
        } else {
            title.textColor = .systemGray
        }
        
        point.isHidden = !selected
    }
}

// MARK: - Actions
extension PointItem {
    @objc func onSelected(_ sender: UIGestureRecognizer) {
        if selected { return }
        setSelected(selected: !selected)
        delegate?.onPointItemSelected?(selectedItem: self)
    }
}
