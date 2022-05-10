//
//  OrderLugPickerView.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/03.
//
//
//  💬 OrderLugPickerView
//  주문할 짐 개수 picker view
//

import UIKit

class OrderLugPickerView: UIView {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var count: UITextField!

    var val: Int = 0
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
        guard let view = self.loadNib(name: String(describing: OrderLugPickerView.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        _utils.setText(bold: .bold, size: 15, text: "", label: title)
        _utils.setText(bold: .bold, size: 10, text: "", label: desc)
        _utils.setText(bold: .bold, size: 20, text: "", field: count)
    }
    
    func configure(title: String, desc: String) {
        configure()
        self.title.text = title
        self.desc.text = desc
    }
    
    func getCount() -> Int {
        let countStr = count.text ?? ""
        let countInt = Int(countStr) ?? 0
        return countInt
    }

}

// MARK: - Actions
extension OrderLugPickerView {
    
    @IBAction func onMinus(_ sender: UIGestureRecognizer) {
        if val == 0 || count.text?.isEmpty == true { return }
        if val < 0 { val = 0; return }
        val -= 1
        
        if val == 0 { count.text = "" }
        else { count.text = "\(val)" }
    }
    
    @IBAction func onPlus(_ sender: UIGestureRecognizer) {
        if val == 6 { return }
        if val > 6 { val = 6; return }
        val += 1
        
        count.text = "\(val)"
    }
}
