//
//  IssueVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/06.
//
//
//  💬 IssueVc
//  폰번호 변경 화면
//

import UIKit
import DropDown

class IssueVc: UIViewController {
    
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var oldPhoneTitle: UILabel!
    @IBOutlet weak var oldCountrycode: UILabel!
    @IBOutlet weak var oldCountry: UIView!
    @IBOutlet weak var oldPhone: UITextField!
    @IBOutlet weak var newPhoneTitle: UILabel!
    @IBOutlet weak var newCountrycode: UILabel!
    @IBOutlet weak var newCountry: UIView!
    @IBOutlet weak var newPhone: UITextField!
    @IBOutlet weak var issue: UITextView!
    @IBOutlet weak var guideTitle: UILabel!
    @IBOutlet weak var guide01: UILabel!
    @IBOutlet weak var guide02: UILabel!
    @IBOutlet weak var save: UIButton!
    
    let issuePlaceholder: String = "문의사항을 입력해주세요."
    
    var vm: IssueVm!
    var oldPhoneDropdown: DropDown! = nil
    var newPhoneDropdown: DropDown! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = IssueVm()
        configure()
    }
    
    func configure() {
        _utils.setText(bold: .extraBold, size: 30, text: "문의사항", label: vcTitle)
        _utils.setText(bold: .bold, size: 15, text: "변경 전 전화번호", label: oldPhoneTitle)
        _utils.setText(bold: .bold, size: 22, text: "", label: oldCountrycode)
        _utils.setText(bold: .bold, size: 22, text: "", field: oldPhone)
        oldPhone.placeholder = "‘-’를 제외한 전화번호를 입력해주세요"
        
        _utils.setText(bold: .bold, size: 15, text: "변경 후 전화번호", label: newPhoneTitle)
        _utils.setText(bold: .bold, size: 22, text: "", label: newCountrycode)
        _utils.setText(bold: .bold, size: 22, text: "", field: newPhone)
        newPhone.placeholder = "‘-’를 제외한 전화번호를 입력해주세요"
        
        _utils.setText(bold: .regular, size: 15, text: issuePlaceholder, textview: issue)
        issue.textColor = .systemGray
        issue.layer.borderColor = UIColor.systemGray4.cgColor
        issue.layer.borderWidth = 1
        issue.contentInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        issue.delegate = self
        _utils.setText(bold: .bold, size: 14, text: "안내사항", label: guideTitle)
        _utils.setText(bold: .regular, size: 13, text: "- 답변에는 시간이 다소 소요됩니다.", label: guide01)
        _utils.setText(bold: .regular, size: 13, text: "- 문의사항 안내는 ‘변경 후 휴대폰번호’로 연락을 드립니다.", label: guide02)
        _utils.setText(bold: .bold, size: 20, text: _strings[.save], button: save)
        
        setOldPhoneDropdown()
        setNewPhoneDropdown()
    }
    
    // 변경 전 국제전화 번호 dropdown 메뉴
    func setOldPhoneDropdown() {
        
        oldCountry.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onOldCountrycode)))
        newCountry.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onNewCountrycode)))
        
        guard nil == oldPhoneDropdown else { return }
        oldPhoneDropdown = DropDown()
        oldPhoneDropdown.dataSource = vm.countrycodes
        oldPhoneDropdown.anchorView = oldCountry
        oldPhoneDropdown.bottomOffset = CGPoint(x: 0, y: oldCountry.frame.height)
        oldPhoneDropdown.selectionAction = self.onOldCountrySelect(index:item:)
        if vm.countrycodes.count > 0 { oldCountrycode.text = vm.countrycodes[0] }
    }

    // 변경 전 국제전화 코드 선택
    func onOldCountrySelect(index: Int, item: String) {
        guard index < vm.countrycodes.count else { return }
        
        oldPhoneDropdown.hide()
        oldCountrycode.text = vm.countrycodes[index]
    }
    
    // 변경 후 국제전화 번호 dropdown 메뉴
    func setNewPhoneDropdown() {
        guard nil == newPhoneDropdown else { return }
        newPhoneDropdown = DropDown()
        newPhoneDropdown.dataSource = vm.countrycodes
        newPhoneDropdown.anchorView = newCountry
        newPhoneDropdown.bottomOffset = CGPoint(x: 0, y: newCountry.frame.height)
        newPhoneDropdown.selectionAction = self.onNewCountrySelect(index:item:)
        if vm.countrycodes.count > 0 { newCountrycode.text = vm.countrycodes[0] }
    }

    // 변경 전 국제전화 코드 선택
    func onNewCountrySelect(index: Int, item: String) {
        guard index < vm.countrycodes.count else { return }
        
        newPhoneDropdown.hide()
        newCountrycode.text = vm.countrycodes[index]
    }
}

// MARK: - Actions
extension IssueVc {
    @IBAction func onExit(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @objc func onOldCountrycode(_ sender: UIGestureRecognizer) {
        oldPhoneDropdown.show()
    }
    
    @objc func onNewCountrycode(_ sender: UIGestureRecognizer) {
        newPhoneDropdown.show()
    }
    
    @objc func onIssueEditBegin(_ sender: UITextView) {
        _log.log("onIssueEditBegin")
    }
}


// MARK: - UITextViewDelegate
extension IssueVc: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == issuePlaceholder {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text == issuePlaceholder {
            textView.text = ""
            textView.textColor = .label
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = issuePlaceholder
            textView.textColor = .systemGray
        }
    }
}
