//
//  HelpVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/25.
//
//
//  💬 HelpVc
//  고객센터 화면
//

import UIKit

class HelpVc: NaviVc {
    
    @IBOutlet weak var board: UIScrollView!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var lookupBoard: UIView!
    @IBOutlet weak var lookup: UITextField!
    @IBOutlet weak var lookupBox: UIView!
    @IBOutlet var keywords: [UIButton]!
    @IBOutlet weak var emptyBoard: UIView!
    @IBOutlet weak var empty: UILabel!
    @IBOutlet var chat: UIButton!
    
    var vm: HelpVm!
    var items: [HelpItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        vm = HelpVm()
        createMyNavi(title: _strings[.settingsSection03], naviCase: .normal, btns: [], backHidden: false)
        myNavi.delegate = self
        _utils.setText(bold: .extraBold, size: 30, text: "고객센터", label: vcTitle)
        
        setBoard()
        setLookupUI()
        setKeywords()
        setChat()
        setEmpty()
    }
    
    // 검색 UI 설정
    func setLookupUI() {
        lookup.placeholder = "'키워드'를 입력하세요"
        lookup.returnKeyType = .search
        lookupBox.layer.shadowOffset = CGSize(width: 3, height: 3)
        lookupBox.layer.shadowRadius = 2
        lookupBox.layer.shadowOpacity = 0.1
        lookupBox.layer.cornerRadius = 6
        lookupBox.layer.borderWidth = 1
        lookupBox.layer.borderColor = UIColor.systemGray4.cgColor
        lookupBox.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onLookup(_:))))
    }
    
    // 키워드 버튼 설정
    func setKeywords() {
        for (i, keyword) in keywords.enumerated() {
            guard i < vm.keywords.count else { break }
            let keywordTxt = vm.keywords[i]
            _utils.setText(bold: .regular, size: 12, text: keywordTxt, button: keyword)
            keyword.setTitleColor(.white, for: .selected)
            keyword.setTitleColor(.darkGray, for: .normal)
            keyword.addTarget(self, action: #selector(self.onKeyword(_:)), for: .touchUpInside)
            keyword.tag = i
            keyword.layer.cornerRadius = (keyword.frame.height - 2) / 2
        }
        
        if keywords.count > 0 { onKeyword(keywords[0]) }
    }
    
    // 채팅 상담 버튼 설정
    func setChat() {
        chat.setTitle("실시간 채팅 상담", for: .normal)
        chat.backgroundColor = .white
        chat.layer.shadowOffset = CGSize(width: 2, height: 2)
        chat.layer.shadowRadius = 2
        chat.layer.shadowOpacity = 0.1
        chat.layer.borderWidth = 1
        chat.layer.borderColor = chat.titleLabel?.textColor.cgColor
        chat.layer.cornerRadius = chat.frame.height / 2
        chat.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onChat(_:))))
    }
    
    // 검색 결과 없을 경우 표시하는 UI 설정
    func setEmpty() {
        _utils.setText(bold: .regular, size: 15, text: "입력하신 문의사항을 찾지못했습니다.", label: empty)
    }

    // 모든 아이템(답변) 제거
    func removeAllItems() {
        items.forEach({ $0.removeFromSuperview() })
    }
    
    // 검색 요청
    func requestLookup(word: String?) {
        guard let word = word else { return }
        vm.lookup(word: word) { (success, msg) in
            self.addAnswers(answers: self.vm.answers) 
        }
    }
    
    // 아이템(답변) 생성
    func addAnswers(answers: [Answer]) {
        removeAllItems()
        emptyBoard.isHidden = !answers.isEmpty
        
        for answer in answers {
            let item = HelpItem(frame: CGRect.zero)
            item.translatesAutoresizingMaskIntoConstraints = false
            item.heightAnchor.constraint(equalToConstant: 60).isActive = true
            item.configure(title: answer.title, desc: answer.desc)
            stack.addArrangedSubview(item)
            stack.insertArrangedSubview(item, at: stack.arrangedSubviews.count - 2)
            items.append(item)
        }
    }
}

// MARK: - Actions
extension HelpVc {
    /// 검색창 터치시 호출됨
    @objc func onLookup(_ sender: UIGestureRecognizer) {
        lookup.becomeFirstResponder() 
    }
    
    /// 채팅 상담 버튼 터치시 호출됨
    @objc func onChat(_ sender: UIButton) {
        let alert = _utils.createSimpleAlert(title: "준비중", message: "해당 서비스는 현재 준비중입니다.", buttonTitle: _strings[.ok], handler: nil)
        self.present(alert, animated: true)
    }
    
    /// 키워드 버튼 선택시 호출됨
    @objc func onKeyword(_ sender: UIButton) {
        // 이미 선택되어있으면 return
        if sender.isSelected { return }
        
        // 선택 상태로 설정
        sender.isSelected = !sender.isSelected
        sender.layer.borderWidth = 0
        sender.backgroundColor = UIColor(red: 242/255, green: 123/255, blue: 87/255, alpha: 1)
        sender.tintColor = sender.backgroundColor
        
        // 나머지 버튼은 선택되지않은 상태로 설정
        for keyword in keywords {
            if sender !== keyword {
                keyword.isSelected = false
                keyword.layer.borderWidth = 1
                keyword.layer.borderColor = UIColor.systemGray.cgColor
                keyword.backgroundColor = .white
                keyword.tintColor = .clear
            }
        }
        
        // 검색 요청
        requestLookup(word: sender.titleLabel?.text ?? "")
    }
    
}

// MARK: - MyNaviDelegate
extension HelpVc: MyNaviDelegate {
    func onBack() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false)
    }
}
