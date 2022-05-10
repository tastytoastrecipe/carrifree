//
//  CostTooltip.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/28.
//

import UIKit

class CostTooltip: UIView {
    
    var tooltipLabel: UIPaddingLabel!
    var tooltipTail: UIImageView!
    var tip: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func configure() {
//        self.backgroundColor = .clear
        
        tooltipTail = UIImageView(image: UIImage(named: "img-tooltip-tail"))
        tooltipTail.frame = CGRect(x: 0, y: 16, width: 15, height: 12)
        self.addSubview(tooltipTail)
    }
    
    func configure(tip: String) {
        configure()
        self.tip = tip
        
        tooltipLabel = UIPaddingLabel()
        tooltipLabel.inset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        tooltipLabel.numberOfLines = 0
        tooltipLabel.text = tip
        tooltipLabel.font = UIFont(name: "NanumSquareR", size: 13)
        tooltipLabel.textColor = .white
        tooltipLabel.sizeToFit()
        tooltipLabel.frame = CGRect(x: tooltipTail.frame.width, y: 0, width: tooltipLabel.frame.width + 30, height: tooltipLabel.frame.height + 20)
        tooltipLabel.textAlignment = .left
        tooltipLabel.backgroundColor = UIColor(red: 242/255, green: 123/255, blue: 87/255, alpha: 1)
        tooltipLabel.layer.cornerRadius = 8
        tooltipLabel.clipsToBounds = true
//        self.frame.size = CGSize(width: tooltipTail.frame.size.width + tooltipLabel.frame.size.width, height: tooltipTail.frame.size.height + tooltipLabel.frame.size.height)
        self.addSubview(tooltipLabel)
        
    }
}
