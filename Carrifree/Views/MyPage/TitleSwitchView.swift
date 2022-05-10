//
//  TitleSwitchView.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/25.
//
//
//  💬 TitleSwitchView
//  제목, 소제목, 스위치가 있는 view
//

import UIKit

class TitleSwitchView: UIView {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var sw: UISwitch!
    
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
        guard let view = self.loadNib(name: String(describing: TitleSwitchView.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        _utils.setText(bold: .regular, size: 17, text: "", label: title)
        _utils.setText(bold: .regular, size: 12, text: "", label: subtitle)
    }
    
    func configure(title: String, subtitle: String, on: Bool, tag: Int) {
        configure()
        self.title.text = title
        self.subtitle.text = subtitle
        sw.isOn = on
        self.tag = tag
    }
}
