//
//  Storages.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/10.
//
//
//  💬 StorageList
//  메인화면의 (주변)보관소 목록
//

import UIKit
import DropDown

@objc protocol StorageListDelegate {
    @objc optional func onMap()
    @objc optional func onAlignSelected(alignIndex: Int)
}

class StorageList: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var align: UIButton!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var map: UIButton!
    
    var storages: [StorageData] = []
    var alignDropdown: DropDown! = nil
    var dropdownMenu: [String] = ["거리순", "평점순"]
    var delegate: StorageListDelegate?
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
        guard let view = self.loadNib(name: String(describing: StorageList.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        self.clipsToBounds = false
        self.backgroundColor = .clear
        
        _utils.setText(bold: .extraBold, size: 20, text: "추천 보관 베이스", label: title)
        _utils.setText(bold: .regular, size: 14, text: "", button: align)
        align.isUserInteractionEnabled = true
        align.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onAlign(_:))))
        
        // Dropdown(정렬) 메뉴 표시
        if nil == alignDropdown {
            alignDropdown = DropDown()
            alignDropdown.dataSource = dropdownMenu
            alignDropdown.anchorView = align
            alignDropdown.bottomOffset = CGPoint(x: 0, y: align.frame.height)
            alignDropdown.selectionAction = self.onAlignSelected(index:item:)
            if dropdownMenu.count > 0 { align.setTitle(dropdownMenu[0], for: .normal) }
        }
        
        _utils.setText(bold: .bold, size: 17, text: "지 도 보 기", color: .white, button: map)
        map.layer.cornerRadius = (map.frame.height - 2) / 2
        map.layer.shadowOffset = CGSize(width: 2, height: 2)
        map.layer.shadowRadius = 1
        map.layer.shadowOpacity = 0.2
        map.addTarget(self, action: #selector(self.onMap(_:)), for: .touchUpInside)
    }
    
    func configure(storages: [StorageData]) {
        configure()
        setStorages(storages: storages)
    }
    
    func setStorages(storages: [StorageData]) {
        if stack.arrangedSubviews.count > 0 { stack.removeAllArrangedSubviews() }
        
        self.storages = storages
        for storage in storages {
            let item = StorageItem()
            item.configure(data: storage)
            stack.addArrangedSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = false
            item.widthAnchor.constraint(equalToConstant: 160).isActive = true
        }
    }
    
    /// Dropdown(정렬) 버튼 터치
    func onAlignSelected(index: Int, item: String) {
        guard index < dropdownMenu.count else { return }        
        alignDropdown.hide()
        align.setTitle(dropdownMenu[index], for: .normal)
        delegate?.onAlignSelected?(alignIndex: index)
    }
}

// MARK: - Actions
extension StorageList {
    @objc func onMap(_ sender: UIButton) {
        delegate?.onMap?()
    }
    
    @objc func onAlign(_ sender: UIGestureRecognizer) {
        alignDropdown.show()
    }
}

