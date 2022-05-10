//
//  StorageBillItem.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/09.
//
//
//  💬 StorageBillItem
//  주문 내역 목록의 아이템
//

import UIKit

protocol StorageBillContainerDelegate {
    func onSpread(container: StorageBillContainer, month: String)
}

class StorageBillContainer: UIView {

    @IBOutlet weak var title: UIButton!
    
    var datas: [StorageBillData] = []
    var minHeight: CGFloat = 0
    var maxHeight: CGFloat = 0
    var heightCnst: NSLayoutConstraint!
    var stack: UIStackView!
    var isSpreaded: Bool = false {
        didSet {
            if isSpreaded {
                if datas.isEmpty { delegate?.onSpread(container: self, month: title.titleLabel?.text ?? ""); return }
                spread()
            }
            else { shut() }
        }
    }
    
    var delegate: StorageBillContainerDelegate?
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
        guard let view = self.loadNib(name: String(describing: StorageBillContainer.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        _utils.setText(bold: .bold, size: 15, text: "", button: title)
        title.layer.cornerRadius = title.frame.height / 2
        title.setTitleColor(.white, for: .normal)
        title.addTarget(self, action: #selector(self.onSelected(_:)), for: .touchUpInside)
        
        for cnst in self.constraints {
            if cnst.firstAttribute == .height {
                self.minHeight = cnst.constant
                self.heightCnst = cnst
                break
            }
        }
    }
    
    func configure(title: String, datas: [StorageBillData]) {
        configure()
        self.datas = datas
        
        var titleText = title
        titleText = titleText.components(separatedBy: ["."]).joined()
        titleText.insert(".", at: titleText.index(titleText.endIndex, offsetBy: -2))
        self.title.setTitle(titleText, for: .normal)
    }
    
    func spread() {
        guard maxHeight == 0 else {
            if nil != heightCnst { heightCnst.constant = maxHeight }
            if nil != stack { stack.isHidden = false }
            return
        }
        if datas.isEmpty { _log.log("'StorageBillItem' data is empty.."); return }
        if nil == heightCnst { return }
        title.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        
        var contentHeight: CGFloat = 0
        stack = UIStackView(frame: CGRect.zero)
        stack.axis = .vertical
        stack.spacing = 10
        stack.distribution = .equalSpacing
        self.addSubview(stack)
        let topSpace: CGFloat = 20
        let bottomSpace: CGFloat = (topSpace * 2)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: title.bottomAnchor, constant: topSpace),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4)
//            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
        
        contentHeight += topSpace
        
        let cellHeight: CGFloat = 130
        for data in datas {
            let cell = StorageBillCell(frame: CGRect.zero)
            cell.configure(data: data)
            stack.addArrangedSubview(cell)
            cell.heightAnchor.constraint(equalToConstant: cellHeight).isActive = true
            contentHeight += (cellHeight + stack.spacing)
        }
        
        contentHeight += bottomSpace
        heightCnst.constant += contentHeight
        maxHeight = heightCnst.constant
    }
    
    func shut() {
        if nil != stack { stack.isHidden = true }
        title.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        heightCnst.constant = 40
    }
}

// MARK: - Actions
extension StorageBillContainer {
    @objc func onSelected(_ sender: UIButton) {
        isSpreaded = !isSpreaded
    }
}
