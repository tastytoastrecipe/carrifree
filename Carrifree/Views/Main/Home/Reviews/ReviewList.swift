//
//  ReviewList.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/11.
//
//
//  💬 ReviewList
//  메인화면의 사용자 후기
//

import UIKit

@objc protocol ReviewListDelegate {
    @objc optional func onMore()
    @objc optional func onReviewMenuSelected(index: Int)
}

class ReviewList: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var more: UIButton!
    @IBOutlet weak var menu: PointMenu!
    @IBOutlet weak var reviewStack: UIStackView!
    @IBOutlet weak var noReviews: UILabel!
    
    let maxReviewCount: Int = 5                     // 표시할 리뷰의 최대 개수
    let defaultHeight: CGFloat = 200                // 리뷰 개수가 0일때의 높이
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
        guard let view = self.loadNib(name: String(describing: ReviewList.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        _utils.setText(bold: .extraBold, size: 20, text: "", label: title)
        _utils.setText(bold: .regular, size: 14, text: "전체보기", button: more)
        _utils.setText(bold: .regular, size: 15, text: "사용자 후기가 없습니다.", label: noReviews)
        noReviews.textAlignment = .center
        more.addTarget(self, action: #selector(self.onMore(_:)), for: .touchUpInside)
    }
    
    func configure(title: String, menuTitles: [String], datas: [ReviewData], reviewsInPage: Int = 5) {
        configure()
        self.title.text = title
        self.reviewsInPage = reviewsInPage
        menu.configure(itemTitles: menuTitles)
        menu.delegate = self
        setDatas(datas: datas)
        createReviewCells(datas: self.datas)
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
    
    func removeAllReviewItem() {
        reviewStack.arrangedSubviews.forEach({
            if noReviews != $0 {
                $0.removeFromSuperview()
                NSLayoutConstraint.deactivate($0.constraints)
            }
        })
    }
    
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
        
        let dataCount: CGFloat = Double(datas.count)
        let spacing: CGFloat = reviewStack.spacing
        let stackViewHeight: CGFloat = (dataCount * reviewItemHeight) + (dataCount * spacing)
        let listViewHeight: CGFloat = defaultHeight + stackViewHeight
        heightCnst.constant = listViewHeight
    }
    
    /// 리뷰 목록을 다시 생성함
    func setReviews(datas: [ReviewData]) {
        setDatas(datas: datas)
        createReviewCells(datas: self.datas)
        setHeight()
    }
    
    /// 현재 선택된 메뉴의 인덱스 반환
    func getSelectedMenuIndex() -> Int {
        let index = menu.getSelectedItemIndex()
        return index
    }
    
    /// 현재 선택된 메뉴에 해당하는 업종 반환
    func getSelectedMenuCategory() -> StorageCategory {
        let index = getSelectedMenuIndex()
        let category = StorageCategory.getReviewCategory(reviewMenuIndex: index)
        return category
    }
}

// MARK: - Actions
extension ReviewList {
    @objc func onMore(_ sender: UIButton) {
        delegate?.onMore?()
    }
}

// MARK: - PointMenuDelegate
extension ReviewList: PointMenuDelegate {
    func onPointMenuSelected(item: PointItem) {
        let tag = item.tag
        delegate?.onReviewMenuSelected?(index: tag)
    }
}
