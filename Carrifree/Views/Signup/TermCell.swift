//
//  TermCell.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/04.
//

import UIKit

protocol TermCellDelegate {
    func spreaded(cell: TermCell)
}

class TermCell: UIView {
    
    @IBOutlet weak var board: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var spread: UIButton!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var boardHeightCnst: NSLayoutConstraint!
    
    let contentTag: Int = 10
    var heightCnst: NSLayoutConstraint!
    var isSpreaded: Bool = false {
        didSet {
            setContentVisible(isSpreaded: isSpreaded)
        }
    }
    var agree: Bool = false
    var data: TermData!
    var delegate: TermCellDelegate?
    var xibLoaded: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    
    func loadNib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: TermCell.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        spread.addTarget(self, action: #selector(self.onSpread(_:)), for: .touchUpInside)
        board.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTouch(_:))))
        setHeightCnst()
    }
    
    func configure(data: TermData) {
        configure()
        self.data = data
        self.title.font = UIFont(name: "NanumSquareR", size: 14)
        self.title.text = data.title
    }
    
    // height constraint 설정
    func setHeightCnst() {
        for constraint in self.constraints {
            if constraint.firstAttribute == .height {
                heightCnst = constraint
                boardHeightCnst.constant = constraint.constant
                break
            }
        }
    }
    
    // 약관 내용 표시/숨김
    private func setContentVisible(isSpreaded: Bool) {
        if nil == data { return }
        
        // 펼침
        if isSpreaded {
            let contentView = UITextView()
//            contentView.text = data.content
//            contentView.font = UIFont(name: "NanumSquareR", size: 13)
            contentView.isScrollEnabled = true
            contentView.isEditable = false
            contentView.tag = contentTag
            contentView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            contentView.layer.cornerRadius = 8
            contentView.layer.borderColor = UIColor.systemGray.cgColor
            contentView.layer.borderWidth = 1
            _utils.setText(bold: .regular, size: 13, text: data.content, textview: contentView)
            self.addSubview(contentView)
            
            let contentHeight: CGFloat = 160
            contentView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: board.bottomAnchor, constant: 0),
                contentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
                contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
                contentView.heightAnchor.constraint(equalToConstant: contentHeight)
            ])
            
            if nil == heightCnst { print("term cell의 height constraint를 찾지 못함..") }
            else {
                heightCnst.constant = boardHeightCnst.constant + contentHeight
                spread.setImage(UIImage(systemName: "chevron.up"), for: .normal)
                line.isHidden = true
            }
            
            delegate?.spreaded(cell: self)
        }
        // 닫음
        else {
            self.viewWithTag(contentTag)?.removeFromSuperview()
            
            if nil == heightCnst { print("term cell의 height constraint를 찾지 못함..") }
            else {
                heightCnst.constant = boardHeightCnst.constant
                spread.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                line.isHidden = false
            }
        }
    }
    
    // 동의/비동의 표시
    func setAgree(agree: Bool) {
        self.agree = agree
        if agree {
            icon.tintColor = _availableColor
        } else {
            icon.tintColor = .systemGray
        }
    }
}

// MARK: - Actions
extension TermCell {
    @objc func onTouch(_ sender: UIGestureRecognizer) {
        setAgree(agree: !agree)
    }
    
    @objc func onSpread(_ sender: UIButton) {
        isSpreaded = !isSpreaded
    }
}
