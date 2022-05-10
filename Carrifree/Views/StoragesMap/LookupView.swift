//
//  LookupView.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/12.
//

import UIKit

@objc protocol LookupViewDelegate {
    /// LookupView 숨김
    @objc optional func lookupViewHide()
    
    /// 주변 보관소 검색
    @objc optional func lookupViewLookup()
    
    @objc optional func hotWordSelected(word: String)
}

class LookupView: UIView {

    @IBOutlet weak var board: UIView!
    @IBOutlet weak var keywordsTitle: UILabel!
    @IBOutlet weak var lookup: UIButton!
    @IBOutlet weak var lookupCenterYCnst: NSLayoutConstraint!

    var delegate: LookupViewDelegate?
    var keywordBtns: [UIButton] = []
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
        guard let view = self.loadNib(name: String(describing: LookupView.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        board.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onBoard(_:))))
        _utils.setText(bold: .regular, size: 15, text: "현재 위치에서 가장 많이 검색된 검색어 입니다.", color: .white, label: keywordsTitle)
        _utils.setText(bold: .bold, size: 17, text: "내 주변 보관소 검색", color: .white, button: lookup)
        lookup.layer.cornerRadius = lookup.frame.height / 2
        lookup.layer.borderColor = UIColor.white.cgColor
        lookup.layer.borderWidth = 1
        lookup.addTarget(self, action: #selector(self.onLookup(_:)), for: .touchUpInside)
    }
    
    func configure(keywords: [String]) {
        configure()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            self.createKeywords(keywords: keywords)
        }
    }
    
    /// 키워드 버튼 생성
    func createKeywords(keywords: [String]) {
        let leadingSpace: CGFloat = 20                      // 처음 생성되는 버튼과 화면 왼쪽끝의 거리
        let wordHorizontalInset: CGFloat = 10               // 버튼의 좌우 inset
        let wordSpace: CGFloat = 8                          // 버튼과 버튼 사이의 거리(가로)
        let lineSpace: CGFloat = 8                          // 버튼과 버튼 사이의 거리(세로)
        let wordHeight: CGFloat = 26                        // 버튼 높이
        let wordColor = UIColor.white                       // 버튼 색
        var x: CGFloat = leadingSpace                       // 버튼의 x값
        var y: CGFloat = keywordsTitle.frame.maxY + 12      // 버튼의 y값
        
        for (i, word) in keywords.enumerated() {
            // 버튼 생성
            let keyword = UIButton()
            _utils.setText(bold: .regular, size: 14, text: word, button: keyword)
            keyword.sizeToFit()
            keyword.contentEdgeInsets = UIEdgeInsets(top: 0, left: wordHorizontalInset, bottom: 0, right: wordHorizontalInset)
            
            // 현재 버튼 위치 계산
            let keywordWidth = keyword.frame.width + (wordHorizontalInset * 2)
            let keywordMaxX = (x + keywordWidth + wordSpace)
            if keywordMaxX > board.frame.width - leadingSpace {     // 화면 밖(오른쪽)을 넘어가면 아랫줄의 처음 위치로 이동
                y += (keyword.frame.height + lineSpace)
                x = leadingSpace
            }
            
            // 버튼 세부사항 설정
            let keywordFrame = CGRect(x: x, y: y, width: keyword.frame.width + (wordHorizontalInset * 2), height: wordHeight)
            keyword.frame = keywordFrame
            keyword.layer.shadowOffset = CGSize(width: 2, height: 2)
            keyword.layer.shadowRadius = 0.8
            keyword.layer.shadowOpacity = 0.1
            keyword.layer.borderWidth = 1
            keyword.layer.borderColor = wordColor.cgColor
            keyword.layer.cornerRadius = wordHeight / 2
            keyword.backgroundColor = .clear
            keyword.setTitleColor(wordColor, for: .normal)
            keyword.contentHorizontalAlignment = .center
            keyword.tag = i
            keyword.addTarget(self, action: #selector(self.onWord(_:)), for: .touchUpInside)
            
            // 버튼 표시
            keywordBtns.append(keyword)
            board.addSubview(keyword)

            // 다음 버튼이 표시될 위치 계산
            x += (keywordFrame.width + wordSpace)
        }
        
        let contentHeight = y + wordHeight
        let lookupY = lookup.frame.origin.y
        if contentHeight > lookupY {
            _log.log("넘어감!!!!")
            
            let gap = contentHeight - lookupY
            let space: CGFloat = 20
            lookupCenterYCnst.constant += (gap + space)
        }
    }
    
    func reset() {
        for btn in keywordBtns { btn.removeFromSuperview()}
        keywordBtns.removeAll()
    }
    
}

// MARK: - Actions
extension LookupView {
    @objc func onBoard(_ sender: UIGestureRecognizer) {
        self.isHidden = true
        delegate?.lookupViewHide?()
    }
    
    @objc func onWord(_ sender: UIButton) {
//        _log.logWithArrow("keyword", sender.titleLabel?.text ?? "")
        let word = sender.titleLabel?.text ?? ""
        delegate?.hotWordSelected?(word: word)
    }
    
    @objc func onLookup(_ sender: UIButton) {
        delegate?.lookupViewLookup?()
    }
}
