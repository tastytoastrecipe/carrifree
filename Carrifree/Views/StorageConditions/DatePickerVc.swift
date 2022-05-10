//
//  SetDateViewController.swift
//  Carrifree
//
//  Created by orca on 2020/10/10.
//  Copyright © 2020 plattics. All rights reserved.
//

import UIKit

protocol DatePickerVcDelegate {
    func dateSelected(date: String, time: String, pickcase: DatePickCase)
}

class DatePickerVc: UIViewController {

    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var board: UIView!
    @IBOutlet weak var timeTitle: UILabel!
    @IBOutlet weak var timeDesc: UILabel!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var picker: UIDatePicker!
    
    var delegate: DatePickerVcDelegate?
    var date: Date?
    var minimumDate: Date?
    var pickcase: DatePickCase = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        super.viewDidLoad()
        bg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onBoard(_:))))
        board.layer.cornerRadius = 10
        board.clipsToBounds = true
        btnDone.setTitle(MyStrings.ok.rawValue, for: .normal)
        
        // 찾는 시간은 30분 단위로 선택할 수 있음
//        if pickcase == .storageEnd || pickcase == .deliveryEnd { picker.minuteInterval = 30 }
        picker.minuteInterval = 30
        
        // set texts
        switch pickcase {
        case .storageStart:
            self.timeTitle.text = "보관시작"
        case .storageEnd:
            self.timeTitle.text = "보관종료"
        case .deliveryStart:
            self.timeTitle.text = "운반시작"
        case .deliveryEnd:
            self.timeTitle.text = "운반종료"
        case .none: break
        }
        
        timeDesc.text = ""
        
        // set minimum date
        switch pickcase {
        case .storageStart, .deliveryStart:
            picker.minimumDate = Date()
        case .storageEnd, .deliveryEnd:
            picker.minimumDate = minimumDate
        case .none: break
        }
        
        // set date
        if let date = date {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                self.picker.setDate(date, animated: true)
            }
        }
    }
    
    @IBAction func onDone(_ sender: UIButton) {
        self.dismiss(animated: false)
        let date = picker.date.toOnlyDateString()
        let time = picker.date.toOnlyTimeString()
        delegate?.dateSelected(date: date, time: time, pickcase: pickcase)
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
}

// MARK: - Actions
extension DatePickerVc {
    @objc func onBoard(_ sender: UIGestureRecognizer) {
        self.dismiss(animated: false)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension DatePickerVc: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 터치 영역이 해당 View의 Frame 안에 포함되는지를 파악해 리턴
        return !self.board.frame.contains(touch.location(in: self.view))
    }
}
