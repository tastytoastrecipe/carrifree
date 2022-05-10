//
//  BillLugCell.swift
//  TestProject
//
//  Created by orca on 2022/02/14.
//

import UIKit

class BillLugCell: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var ea: UILabel!

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
        guard let view = self.loadNib(name: String(describing: BillLugCell.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        _utils.setText(bold: .regular, size: 17, text: "", color: .systemGray, label: title)
        _utils.setText(bold: .regular, size: 13, text: "", color: .systemGray, label: desc)
        _utils.setText(bold: .bold, size: 17, text: "", color: _tungsten, label: ea)
    }
    
    func configure(title: String, desc: String, ea: Int) {
        self.title.text = title
        self.desc.text = desc
        self.ea.text = "\(ea)"
    }
}
