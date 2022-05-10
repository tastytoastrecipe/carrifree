//
//  OrderDatePickerView.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/03.
//
//
//  💬 OrderDatePickerView
//  주문 날짜, 시간 picker view
//

import UIKit

protocol OrderDatePickerViewDelegate {
    func onMinimumDateSelected(minimumDate: Date?)
}

class OrderDatePickerView: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var time: UITextField!
    @IBOutlet weak var desc: UILabel!

    private var minimumDate: Date?
    
    var delegate: OrderDatePickerViewDelegate?
    var pickcase: DatePickCase = .none
    
    var needEnter: Bool {
        get { return (true == date.text?.isEmpty || true == time.text?.isEmpty) }
    }
    
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
        guard let view = self.loadNib(name: String(describing: OrderDatePickerView.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        
        _utils.setText(bold: .bold, size: 16, text: "", label: title)
        _utils.setText(bold: .bold, size: 16, text: "", field: date)
        _utils.setText(bold: .bold, size: 16, text: "", field: time)
        _utils.setText(bold: .bold, size: 14, text: "", label: desc)
        
        let today = Date().localDate
        date.placeholder = today.toOnlyDateString()
        date.isUserInteractionEnabled = false
        time.placeholder = today.toOnlyTimeString()
        time.isUserInteractionEnabled = false
    }
    
    func configure(title: String, desc: String, pickcase: DatePickCase) {
        configure()
        self.title.text = title
        self.desc.text = desc
        self.pickcase = pickcase
    }
    
    func setMinimunDate(minimumDate: Date?) {
        self.minimumDate = minimumDate
        date.placeholder = minimumDate?.toOnlyDateString()
        time.placeholder = minimumDate?.toOnlyTimeString()
    }
    
    func stringToDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
//            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let date = dateFormatter.date(from: dateString)
        return date
    }
    
    func getFullString() -> String {
        let str = "\(date.text ?? "") \(time.text ?? "")"
        return str
    }
    
    func getDateString() -> String {
        return (date.text ?? "")
    }
    
    func getTimeString() -> String {
        return (time.text ?? "")
    }
}

// MARK: - Actions
extension OrderDatePickerView {
    @IBAction func onSelected(_ sender: UIGestureRecognizer) {
        let vc = DatePickerVc()
        vc.pickcase = pickcase
        vc.delegate = self
        
        if let dateStr = date.text, dateStr.isEmpty == false, let timeStr = time.text, timeStr.isEmpty == false {
            vc.date = stringToDate(dateString: "\(dateStr) \(timeStr)")
        }
        
        vc.minimumDate = minimumDate
        
        vc.modalPresentationStyle = .overFullScreen
        _utils.topViewController()?.present(vc, animated: false)
    }
}

// MARK: - DatePickerVcDelegate
extension OrderDatePickerView: DatePickerVcDelegate {
    func dateSelected(date: String, time: String, pickcase: DatePickCase) {
        self.date.text = date
        self.time.text = time
        
        if pickcase == .storageStart || pickcase == .deliveryStart {
            let date = stringToDate(dateString: "\(date) \(time)")
            delegate?.onMinimumDateSelected(minimumDate: date)
        }
    }
}
