//
//  NotificationItem.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/26.
//

import UIKit

class NotificationItem: UIView {
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var messageBoard: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!

    var data: NotificationData!
    var subtitleMaxHeight: CGFloat = 12
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
        guard let view = self.loadNib(name: String(describing: NotificationItem.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()

        messageBoard.layer.cornerRadius = 16
        messageBoard.backgroundColor = .systemGray5
        
        _utils.setText(bold: .extraBold, size: 17, text: "", label: title)
        _utils.setText(bold: .bold, size: 12, text: "", label: subtitle)
        _utils.setText(bold: .bold, size: 12, text: "", label: date)
    }
    
    func configure(noticase: NotiCase, date: String, title: String, from: String, desc: String) {
        configure()
        if nil == data {
            data = NotificationData(noticase: noticase.rawValue, date: date, title: title, from: from, desc: desc)
        }
        setNoti(noticase: noticase, date: date, title: title, from: from, desc: desc)
    }
    
    func configure(data: NotificationData) {
        self.data = data
        let noticase = NotiCase(rawValue: data.noticase) ?? .none
        configure(noticase: noticase, date: data.date, title: data.title, from: data.from, desc: data.desc)
    }
    
    // 알림 종류에 따른 UI 설정
    func setNoti(noticase: NotiCase, date: String, title: String, from: String, desc: String) {
        self.title.text = title
        self.date.text = date
        
        // 아이템의 높이 설정
        for cnst in self.constraints {
            if cnst.firstAttribute == .height { cnst.constant = noticase.height; break }
        }
        
        // title의 centerY 설정
        self.title.centerYAnchor.constraint(equalTo: self.messageBoard.centerYAnchor, constant: noticase.centerY).isActive = true
        
        // subtitle의 색상, 높이 가져오기
        let subtitleColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
        var subtitleHeightCnst: NSLayoutConstraint!
        for cnst in subtitle.constraints {
            if cnst.firstAttribute == .height { subtitleHeightCnst = cnst; break }
        }
        guard let subtitleHeightCnst = subtitleHeightCnst else { return }
        
        // 아이템 UI 세부 조정
        switch noticase {
        case .gift:
            subtitle.text = "From. \(from)"
            subtitleHeightCnst.constant = subtitleMaxHeight
        case .review:
            // --------------- "스타벅스: 경기 수원시 팔달구 권선로 741" 형식의 문자열 생성 --------------- //
            
            // "스타벅스: " 부분 색상 적용
            let subtitleText = "\(from): \(desc)"
            let attributedSubtitleText = NSMutableAttributedString(string: subtitleText, attributes: [
              .foregroundColor: subtitleColor
            ])
            
            // "경기 수원시 팔달구 권선로 741" 부분 색상 적용
            attributedSubtitleText.addAttributes([
                .foregroundColor: UIColor.systemGray
            ], range: NSRange(location: from.count + 2, length: desc.count))
            
            subtitleHeightCnst.constant = subtitleMaxHeight
            subtitle.attributedText = attributedSubtitleText
            
            // ------------------------------------------------------------------------------ //
            
        default:
            subtitle.text = ""
            subtitleHeightCnst.constant = 0
        }
        
    }
}
