//
//  ReviewSimpleList.swift
//  Carrifree
//
//  Created by plattics-kwon on 2022/03/31.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 ReviewList
//  메인화면의 사용자 후기
//

import UIKit

@objc protocol ReviewSimpleListDelegate {
    @objc optional func onReviewMenuSelected(index: Int)
}

class ReviewSimpleList: UIView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var reviewStack: UIStackView!
    @IBOutlet weak var noReviews: UILabel!
    let maxReviewCount: Int = 100                   // 표시할 리뷰의 최대 개수
    let defaultHeight: CGFloat = 150                // 리뷰 개수가 0일때의 높이
    let reviewItemHeight: CGFloat = 110             // ReviewItem의 높이
    let heightCnstId: String = "reviewListHeight"   // ReviewList의 height constraint id
    var heightCnst: NSLayoutConstraint!             // ReviewList의 height constraint
    
    var delegate: ReviewListDelegate?
    var reviewsInPage: Int = 5          // 한 페이지에 표시될 리뷰 개수
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
        _utils.setText(bold: .regular, size: 15, text: "사용자 후기가 없습니다.", label: noReviews)
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
    
    /// noReview를 제외한 모든 review item 제거
    func removeAllReviewItem() {
        reviewStack.arrangedSubviews.forEach({
            if noReviews != $0 {
                $0.removeFromSuperview()
                NSLayoutConstraint.deactivate($0.constraints)
            }
        })
    }
    
    /// 전체 뷰의 높이 조정
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
    
    /// 리뷰 목록을 다시 생성함
    func setReviews(datas: [ReviewData]) {
        setDatas(datas: datas)
        createReviewCells(datas: self.datas)
        setHeight()
    }
    
}
