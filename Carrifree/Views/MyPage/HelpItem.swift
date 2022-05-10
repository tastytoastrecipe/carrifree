//
//  HelpItem.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/25.
//
//
//  💬 HelpItem
//  검색된 문의사항
//

import UIKit

class HelpItem: UIView {

    @IBOutlet weak var board: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var indicator: UIImageView!
    
    var desc: String = ""
    var descTag: Int = 50
    var selected: Bool = false
    var originHeight: CGFloat = 0
    var heightCnst: NSLayoutConstraint!
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
        guard let view = self.loadNib(name: String(describing: HelpItem.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        
        for cnst in self.constraints {
            if cnst.firstAttribute == .height {
                originHeight = cnst.constant
                heightCnst = cnst
                break
            }
        }
        
        _utils.setText(bold: .regular, size: 17, text: "", label: title)
    }
    
    func configure(title: String, desc: String) {
        configure()
        self.title.text = title
        self.desc = desc
    }
    
    func setSelected(selected: Bool) {
        self.selected = selected
        if selected {
            let contentView = UITextView()
            contentView.text = desc
            contentView.isScrollEnabled = true
            contentView.isEditable = false
            contentView.font = UIFont(name: "NanumSquareR", size: 13)
            contentView.tag = descTag
            contentView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            contentView.textColor = .systemGray
            contentView.sizeToFit()
            self.addSubview(contentView)
            
            let contentHeight: CGFloat = contentView.frame.height + 10
            contentView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: board.bottomAnchor, constant: 0),
                contentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
                contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
                contentView.heightAnchor.constraint(equalToConstant: contentHeight)
            ])
            
            indicator.image = UIImage(systemName: "chevron.up")
            if nil != heightCnst { heightCnst.constant += contentHeight }
        } else {
            self.viewWithTag(descTag)?.removeFromSuperview()
            indicator.image = UIImage(systemName: "chevron.down")
            if nil != heightCnst { heightCnst.constant = originHeight }
        }
    }
    
    
}

// MARK: - Actions
extension HelpItem {
    @IBAction func onSelected(_ sender: UIGestureRecognizer) {
        setSelected(selected: !selected)
    }
}
