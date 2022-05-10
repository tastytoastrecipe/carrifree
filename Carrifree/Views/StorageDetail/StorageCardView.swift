//
//  StorageCardView.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/17.
//

import UIKit

class StorageCardView: UIView {

    @IBOutlet weak var board: UIView!
    @IBOutlet weak var band: UIView!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var ratingTitle: UILabel!
    @IBOutlet weak var ratingImg: UIImageView!
    @IBOutlet weak var ratingTxt: UILabel!
    @IBOutlet weak var workTime: UILabel!
    @IBOutlet weak var meritsBoard: UIView!
    @IBOutlet weak var pr: UITextView!
    @IBOutlet weak var moreBoard: UIView!
    @IBOutlet weak var more: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    
    let shortCardviewHeight: CGFloat = 256      // 보관장점이 없고, 소개글이 3줄 미만일때의 높이
    let defaultCardviewHeight: CGFloat = 300    // 보관장점이 있고, 소개글이 3줄 이상일때의 높이
    let maxCardviewHeight: CGFloat = 500        // 보관장점이 있고, 소개글이 3줄 이상일때의 최대 높이
    let minCardviewHeight: CGFloat = 194        // 보관장점이 없고, 소개글이 3줄 미만일때의 높이                   // origin: 226
    
    var data: StorageDetailData!
    var heightCnstId: String = ""
    var originHeight: CGFloat = 0
    var spreaded: Bool = false
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
        guard let view = self.loadNib(name: String(describing: StorageCardView.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        
        _utils.setText(bold: .regular, size: 13, text: "", label: category)
        _utils.setText(bold: .extraBold, size: 24, text: "", label: title)
        _utils.setText(bold: .regular, size: 12, text: "", label: address)
        let ratingColor = UIColor(red: 238/255, green: 129/255, blue: 129/255, alpha: 1)
        _utils.setText(bold: .bold, size: 10, text: "", color: ratingColor, label: ratingTitle)
        _utils.setText(bold: .extraBold, size: 9, text: "", color: ratingColor, label: ratingTxt)
        _utils.setText(bold: .regular, size: 15, text: "", label: workTime)
        _utils.setText(bold: .regular, size: 16, text: "", textview: pr)
        pr.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8)
        _utils.setText(bold: .extraBold, size: 12, text: "더보기", alignment: .center, label: more)
        moreBoard.isUserInteractionEnabled = true
        moreBoard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onMore(_:))))
        meritsBoard.translatesAutoresizingMaskIntoConstraints = false
        
        board.layer.cornerRadius = 20
        board.layer.shadowOffset = CGSize(width: 2, height: 2)
        board.layer.shadowRadius = 4
        board.layer.shadowOpacity = 0.2
        board.clipsToBounds = true
        board.layer.masksToBounds = false
        
        band.roundCorners(cornerRadius: 20, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
    }
    
    func configure(data: StorageDetailData, heightCnst: String) {
        configure()
        self.data = data
        self.heightCnstId = heightCnst
        
        // category
        category.text = StorageCategory(rawValue: data.category)?.name ?? ""
        
        // title
        title.text = data.name
        
        // address
        address.text = data.address
        
        // ratings
        ratingTitle.text = "사용자 총 평점"
        ratingTxt.text = "\(data.rating)"
        let rating = Ratings.getRatingByScore(score: data.rating)
        ratingImg.image = UIImage(named: rating.imgName)
        ratingTxt.textColor = rating.color
        ratingTxt.text = "\(data.rating)"
        ratingTitle.textColor = rating.color
        
        // pr
        _utils.setText(bold: .regular, size: 16, text: data.pr, alignment: .center, textview: pr)
        
        if pr.numberOfLines() <= 3 {
            moreBoard.removeFromSuperview()
        }
        
        // worktime
        setWorktime()
        
        // merits
        setMerits()
        
        spread(spread: true)
    }
    
    // worktime 문자열 생성
    func setWorktime() {
        let worktimeTitle = "운영시간"
        let dayoffTitle = "휴무일"
        let titleFont = UIFont(name: "NanumSquareR", size: 15)
        let descFont = UIFont(name: "NanumSquareB", size: 15)
        
        var dayoffDesc = ""
        for off in data.dayoff {
            let dayoffName = Weekday(rawValue: off)?.name ?? ""
            dayoffDesc += "\(dayoffName),"
        }
        
        if data.dayoff.isEmpty { dayoffDesc = "없음" }
        else { _ = dayoffDesc.popLast() }
        
        // "운영시간: 00:00 - 00:00 휴무일: 일, 월..." 형식의 문자열 생성
//        let totalWorktimeStr = "\(worktimeTitle): \(data.worktime)  \(dayoffTitle): \(dayoffDesc)"
        
        // "운영시간: 00:00 - 00:00" 형식의 문자열 생성
        let totalWorktimeStr = "\(worktimeTitle): \(data.worktime)   \(dayoffTitle): \(dayoffDesc)"
        let workTimeAttString = NSMutableAttributedString(string: totalWorktimeStr, attributes: [
          .font: titleFont!,
          .foregroundColor: UIColor.gray
        ])
        
        // "oo시 ~ oo시" 폰트 설정
        let descColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
        workTimeAttString.addAttributes([
          .font: descFont!,
          .foregroundColor: descColor
        ], range: NSRange(location: worktimeTitle.count + 2, length: data.worktime.count))
        
//        workTime.attributedText = workTimeAttString
        
        // "일, 월..." 폰트 설정
        let range = totalWorktimeStr.range(of: "\(dayoffTitle): ")
        if let index = range?.upperBound.utf16Offset(in: totalWorktimeStr) {
            workTimeAttString.addAttributes([
              .font: descFont!,
              .foregroundColor: descColor
            ], range: NSRange(location: index, length: dayoffDesc.count))
            
            workTime.attributedText = workTimeAttString
        }
        
        workTime.attributedText = workTimeAttString
    }
    
    // merits UI 생성
    func setMerits() {
        if data.merits.isEmpty {
            meritsBoard.removeFromSuperview()
            return
        }
        
        let leadingSpace: CGFloat = 0           // 처음 생성되는 버튼과 화면 왼쪽끝의 거리
        let wordHorizontalInset: CGFloat = 10   // 버튼의 좌우 inset
        let wordSpace: CGFloat = 8              // 버튼과 버튼 사이의 거리(가로)
        let lineSpace: CGFloat = 4              // 버튼과 버튼 사이의 거리(세로)
        let wordHeight: CGFloat = 26            // 버튼 높이
        var x: CGFloat = leadingSpace           // 버튼의 x값
        var y: CGFloat = 10                     // 버튼의 y값
        
        for merit in data.merits {
            // 버튼 생성
            let keyword = UIButton()
            _utils.setText(bold: .regular, size: 14, text: merit, button: keyword)
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
            keyword.layer.cornerRadius = wordHeight / 2
            keyword.backgroundColor = band.backgroundColor
            keyword.setTitleColor(.white, for: .normal)
            keyword.contentHorizontalAlignment = .center
            
            // 버튼 표시
            meritsBoard.addSubview(keyword)

            // 다음 버튼이 표시될 위치 계산
            x += (keywordFrame.width + wordSpace)
        }
        
        for constraint in meritsBoard.constraints {
            if constraint.firstAttribute == .height { constraint.constant = y + wordHeight; break }
        }
    }
    
    func meritsViewHeight() -> CGFloat {
        guard data.merits.count > 0 else { return 0 }
        
        var height: CGFloat = 0
        for constraint in meritsBoard.constraints {
            if constraint.firstAttribute == .height { height = constraint.constant; break }
        }
        
        return height
    }
    
    func moreBoardHeight() -> CGFloat {
        var height: CGFloat = 0
        for constraint in moreBoard.constraints {
            if constraint.firstAttribute == .height { height = constraint.constant; break }
        }
        
        return height
    }
    
    // pr 더보기/접기
    func spread(spread: Bool) {
        if self.spreaded == spread { return }
        self.spreaded = spread
        
        var height: CGFloat = minCardviewHeight
//        pr.sizeToFit()
        let prHeight = pr.contentSize.height
        var fontSize = pr.font?.pointSize ?? 0
        fontSize += (fontSize * 0.5)
        var numberOfLines = (prHeight / fontSize)
//        var numberofLines3 = pr.numberOfLines()
//        var numberOfLines = numberofLines3 - 3
        if numberOfLines < 0 { numberOfLines = 0 }
        
        if spreaded {
            spreaded = true
            
//            if numberOfLines > 3 {
                let addHeight = CGFloat(numberOfLines) * fontSize
                height += addHeight
//                height += moreBoardHeight()
//            }
            height += meritsViewHeight()
            
//            if height > maxCardviewHeight { height = maxCardviewHeight }
            more.text = "접기"
            arrow.image = UIImage(systemName: "arrowtriangle.up.fill")
            
        } else {
            spreaded = false
            
            if numberOfLines > 3 {
                more.text = "더보기"
                arrow.image = UIImage(systemName: "arrowtriangle.down.fill")
//                height += moreBoardHeight()
            }
            
            height += meritsViewHeight()
        }
        
        UIView.animate(withDuration: 0.15, animations: { () -> Void in
//            self.constraints.first(where: { $0.firstAttribute == .height })?.constant = height
            self.constraints.first(where: { $0.identifier == self.heightCnstId })?.constant = height
            self.board.translatesAutoresizingMaskIntoConstraints = false
            self.board.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
            
            self.layoutIfNeeded()
            self.superview?.layoutSubviews()
            
        })
    }
}

// MARK: - Actions
extension StorageCardView {
    @objc func onMore(_ sender: UIGestureRecognizer) {
        spread(spread: !spreaded)
    }
}
