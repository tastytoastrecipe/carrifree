//
//  MyNavi.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/20.
//

import UIKit

typealias NaviCallback = (target: Any?, handler: Selector)

@objc protocol MyNaviDelegate {
    @objc optional func onBack()
    @objc optional func onTextfieldEditingBegin()
}

class MyNavi: UIView {

    @IBOutlet weak var board: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var rightStack: UIStackView!
    @IBOutlet weak var leftStack: UIStackView!
    @IBOutlet weak var field: UITextField!
    @IBOutlet weak var lookup: UIButton!
    @IBOutlet weak var back: UIButton!

    var heightCnst: NSLayoutConstraint!
    
    enum NaviCase {     // 네비게이션 종류
        case long       // 가장 긴 네비 (메인화면)
        case search     // 검색 네비
        case normal     // 일반 네비
        
        var height: CGFloat {
            switch self {
            case .long: return 230
            case .search: return 124
            case .normal: return 76
            }
        }
    }
    
    var delegate: MyNaviDelegate?
    var naviCase: NaviCase = .normal
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
        guard let view = self.loadNib(name: String(describing: MyNavi.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        _utils.setText(bold: .bold, size: 18, text: "", color: .white, label: title)
        _utils.setText(bold: .regular, size: 15, text: "", field: field)
        field.delegate = self
    }
    
    func configure(title: String, naviCase: NaviCase, btns: [UIButton] = [], backHidden: Bool = false) {
        configure()
        setTitle(title: title)
        back.isHidden = backHidden
        back.addTarget(self, action: #selector(self.onBack(_:)), for: .touchUpInside)
        for constraint in self.constraints {
            if constraint.firstAttribute == .height { heightCnst = constraint; break }
        }
        
        setNaviCase(naviCase: naviCase)
        
        for btn in btns {
            rightStack.addArrangedSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        }
    }
    
    func setTitle(title: String) {
        self.title.text = title
    }
    
    func setNaviCase(naviCase: NaviCase) {
        if nil == heightCnst { return }
        
        self.naviCase = naviCase
        heightCnst.constant = naviCase.height
        
        field.isHidden = (naviCase == .normal)
        lookup.isHidden = (naviCase == .normal)
    }
    
    func removeRightBtns() {
        rightStack.removeAllArrangedSubviews()
    }
    
    func removeLeftBtns() {
        leftStack.removeAllArrangedSubviews()
    }
    
    func addNaviRightBtn(btn: UIButton) {
        rightStack.addArrangedSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 40).isActive = true
    }

    func addNaviLeftBtn(btn: UIButton) {
        leftStack.addArrangedSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func addNaviRightBtn(title: String, callback: NaviCallback? = nil) {
        let btn = UIButton()
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.textColor = .white
        addNaviRightBtn(btn: btn)
        
        if let callback = callback {
            btn.addTarget(callback.target, action: callback.handler, for: .touchUpInside)
        }
    }
    
    func addNaviRightBtn(systemImage: String, callback: NaviCallback? = nil) {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: systemImage), for: .normal)
        btn.tintColor = .white
        btn.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
        addNaviRightBtn(btn: btn)
        
        if let callback = callback {
            btn.addTarget(callback.target, action: callback.handler, for: .touchUpInside)
        }
    }
    
    func addNaviLeftBtn(title: String, callback: NaviCallback? = nil) {
        let btn = UIButton()
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.textColor = .white
        addNaviLeftBtn(btn: btn)
        
        if let callback = callback {
            btn.addTarget(callback.target, action: callback.handler, for: .touchUpInside)
        }
    }
    
    func addLeftTitle(title: String) {
        let titleLabel = UILabel()
        _utils.setText(bold: .regular, size: 17, text: title, color: .white, label: titleLabel)
        leftStack.addArrangedSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
    }
    
    func hideBackBtn(hidden: Bool) {
        back.isHidden = hidden
    }
}

// MARK: - Actions
extension MyNavi {
    @IBAction func onBack(_ sender: UIButton) {
        delegate?.onBack?()
    }
}

// MARK: - UITextFieldDelegate
extension MyNavi: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.onTextfieldEditingBegin?()
    }
}
