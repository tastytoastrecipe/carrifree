//
//  BillScheduleCell.swift
//  TestProject
//
//  Created by orca on 2022/02/14.
//
//
//  💬 BillScheduleCell
//  주문의 상세 내역 화면 -> 스케쥴 표시 cell
//

import UIKit

class BillScheduleCell: UIView {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var schedule: UILabel!
    @IBOutlet weak var desc: UILabel!

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
        guard let view = self.loadNib(name: String(describing: BillScheduleCell.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        _utils.setText(bold: .regular, size: 16, text: "", label: title)
        _utils.setText(bold: .bold, size: 18, text: "", label: schedule)
        _utils.setText(bold: .regular, size: 16, text: "", label: desc)
    }
    
    func configure(title: String, schedule: String, desc: String) {
        configure()
        self.title.text = title
        self.schedule.text = schedule
        self.desc.text = desc
    }

}
