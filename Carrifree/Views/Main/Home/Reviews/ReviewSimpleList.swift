//
//  ReviewSimpleList.swift
//  Carrifree
//
//  Created by plattics-kwon on 2022/03/31.
//  Copyright ยฉ 2022 plattics. All rights reserved.
//
//
//  ๐ฌ ReviewList
//  ๋ฉ์ธํ๋ฉด์ ์ฌ์ฉ์ ํ๊ธฐ
//

import UIKit

@objc protocol ReviewSimpleListDelegate {
    @objc optional func onReviewMenuSelected(index: Int)
}

class ReviewSimpleList: UIView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var reviewStack: UIStackView!
    @IBOutlet weak var noReviews: UILabel!
    let maxReviewCount: Int = 100                   // ํ์ํ  ๋ฆฌ๋ทฐ์ ์ต๋ ๊ฐ์
    let defaultHeight: CGFloat = 150                // ๋ฆฌ๋ทฐ ๊ฐ์๊ฐ 0์ผ๋์ ๋์ด
    let reviewItemHeight: CGFloat = 110             // ReviewItem์ ๋์ด
    let heightCnstId: String = "reviewListHeight"   // ReviewList์ height constraint id
    var heightCnst: NSLayoutConstraint!             // ReviewList์ height constraint
    
    var delegate: ReviewListDelegate?
    var reviewsInPage: Int = 5          // ํ ํ์ด์ง์ ํ์๋  ๋ฆฌ๋ทฐ ๊ฐ์
    var datas: [ReviewData] = []
    var xibLoaded: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: ReviewSimpleList.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        _utils.setText(bold: .extraBold, size: 20, text: "", label: title)
        _utils.setText(bold: .regular, size: 15, text: "์ฌ์ฉ์ ํ๊ธฐ๊ฐ ์์ต๋๋ค.", label: noReviews)
        noReviews.textAlignment = .center
    }
    
    func configure(title: String, datas: [ReviewData], reviewsInPage: Int = 5) {
        configure()
        self.title.text = title
        self.reviewsInPage = reviewsInPage
        setReviews(datas: datas)
    }
    
    func setDatas(datas: [ReviewData]) {
        self.datas.removeAll()
        self.datas = datas
        while self.datas.count > maxReviewCount {
            _ = self.datas.popLast()
        }
    }
    
    private func createReviewCells(datas: [ReviewData]) {
        let noReviewsHidden = !(datas.isEmpty)
        noReviews.isHidden = noReviewsHidden
        removeAllReviewItem()
        
        for data in datas {
            let cell = ReviewItem(frame: .zero, data: data)
            reviewStack.addArrangedSubview(cell)
            cell.heightAnchor.constraint(equalToConstant: reviewItemHeight).isActive = true
        }
    }
    
    /// noReview๋ฅผ ์ ์ธํ ๋ชจ๋  review item ์ ๊ฑฐ
    func removeAllReviewItem() {
        reviewStack.arrangedSubviews.forEach({
            if noReviews != $0 {
                $0.removeFromSuperview()
                NSLayoutConstraint.deactivate($0.constraints)
            }
        })
    }
    
    /// ์ ์ฒด ๋ทฐ์ ๋์ด ์กฐ์ 
    func setHeight() {
        if nil == heightCnst {
            for cnst in self.constraints {
                if cnst.identifier == heightCnstId {
                    heightCnst = cnst
                    break
                }
            }
        }
        
        if nil == heightCnst { return }
        guard datas.count > 0 else {
            heightCnst.constant = defaultHeight
            return
        }
        
        let dataCount: CGFloat = Double(datas.count)
        let spacing: CGFloat = reviewStack.spacing
        let stackViewHeight: CGFloat = (dataCount * reviewItemHeight) + ((dataCount - 1) * spacing)
        let noReviewHeight = (noReviews.constraints.filter({ $0.firstAttribute == .height }).first?.constant ?? 0) + 20
        let listViewHeight: CGFloat = (defaultHeight - noReviewHeight) + stackViewHeight
        heightCnst.constant = listViewHeight
    }
    
    /// ๋ฆฌ๋ทฐ ๋ชฉ๋ก์ ๋ค์ ์์ฑํจ
    func setReviews(datas: [ReviewData]) {
        setDatas(datas: datas)
        createReviewCells(datas: self.datas)
        setHeight()
    }
    
}
