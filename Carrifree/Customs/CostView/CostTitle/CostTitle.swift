//
//  CostTitle.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/28.
//

import UIKit

class CostTitle: UIView {

    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    lazy var tooltip: CostTooltip = {
        // tooltip 생성
        let tooltip = CostTooltip(frame: CGRect.zero)
        tooltip.configure(tip: desc)
        tooltip.frame.origin = CGPoint(x: self.frame.width + 6, y: -10)
        tooltip.isHidden = true
        
        // tooltip 위치 계산
        let newPoint = self.convert(tooltip.frame.origin, to: tooltipBoard)
        tooltip.frame.origin = newPoint
        tooltipBoard.addSubview(tooltip)
        
        // tooltip 터치 설정
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onTooltipBoard(_:)))
//        tapGesture.delegate = self
        tooltipBoard.addGestureRecognizer(tapGesture)
        return tooltip
    }()
    
    lazy var tooltipBoard: UIView = {
        let rootview = _utils.topViewController()?.view
        let tempBoard = UIView()
        tempBoard.frame = (rootview?.frame ?? CGRect(x: 0, y: 0, width: 414, height: 896))
        tempBoard.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 50/255)
        rootview?.addSubview(tempBoard)
        return tempBoard
    }()
    
    var desc: String = ""
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
        guard let view = self.loadNib(name: String(describing: CostTitle.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        _utils.setText(bold: .bold, size: 17, text: "", label: Title)
        _utils.setText(bold: .bold, size: 12, text: "", label: subTitle)
    }
    
    func configure(title: String, subTitle: String, desc: String) {
        configure()
        self.Title.text = title
        self.subTitle.text = subTitle
        self.desc = desc
    }
}

// MARK:- Action
extension CostTitle {
    @IBAction func onTip(_ sender: UIButton) {
        tooltipBoard.isHidden = false
        tooltip.isHidden = false
        
        // 위치 갱신
        tooltip.frame.origin = CGPoint(x: self.frame.width + 6, y: -10)
        let newPoint = self.convert(tooltip.frame.origin, to: tooltipBoard)
        tooltip.frame.origin = newPoint
    }
    
    @objc func onTooltipBoard(_ sender: UIGestureRecognizer) {
        tooltipBoard.isHidden = true
        tooltip.isHidden = true
    }
}


/*
extension CostTitle: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 터치 영역이 해당 View의 Frame 안에 포함되는지를 파악해 리턴
        let isContained = !tooltipBoard.frame.contains(touch.location(in: tooltip))
//        _log.logWithArrow("tooltip is contained", isContained.description)
        
        _log.logWithArrow("tooltip frame", tooltip.frame.debugDescription)
        return isContained
    }
}
*/




