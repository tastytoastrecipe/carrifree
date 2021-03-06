//
//  BillsVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/09.
//
//
//  π¬ BillsVc
//  μ£Όλ¬Έ λ΄μ­ νλ©΄
//

import UIKit

class BillsVc: UIViewController {
    
//    @IBOutlet weak var vcDesc: UILabel!
//    @IBOutlet weak var all: UIButton!
    @IBOutlet var menuBtns: [UIButton]!
    @IBOutlet weak var lookupBox: UIView!
    @IBOutlet weak var lookup: UITextField!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var noBillsTitle: UILabel!
    @IBOutlet weak var lookupStorage: UIButton!
    @IBOutlet weak var noBills: UIView!
    
    var selectedMenuIndex: Int = 0
    var vm: BillsVm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefault()
        vm = BillsVm()
//        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) { _events.addDelegate(delegate: self) }
    override func viewWillDisappear(_ animated: Bool) { _events.removeDelegate(delegate: self) }
    
    func viewWillAppear() {
        refresh()
    }
    
    // ui defaults
    func setDefault() {
//        _utils.setText(bold: .regular, size: 14, text: "λ΄μ­\nλ³΄κ΄ λ° μ΄λ° μμ½μ νμ΄νκ³ , μ§ν νν©μ νμν  μ μμ΅λλ€.", color: _symbolColor, label: vcDesc)
        
//        vcDesc.layer.shadowOffset = CGSize(width: 0, height: 2)
//        vcDesc.layer.shadowRadius = 1
//        vcDesc.layer.shadowOpacity = 0.2
        
        setLookupUI()
        
//        _utils.setText(bold: .regular, size: 15, text: "μ μ²΄", color: .systemGray, button: all)
//        setMenuBtn(btn: all)
        
        for btn in menuBtns { setMenuBtn(btn: btn) }
        if menuBtns.count > 0 { _utils.setText(bold: .regular, size: 15, text: _strings[.all], color: .systemGray, button: menuBtns[0]) }
        if menuBtns.count > 1 { _utils.setText(bold: .regular, size: 15, text: OrderStatus.reserved.storageStatusText, color: .systemGray, button: menuBtns[1]) }
        if menuBtns.count > 2 { _utils.setText(bold: .regular, size: 15, text: OrderStatus.entrust.storageStatusText, color: .systemGray, button: menuBtns[2]) }
        if menuBtns.count > 3 { _utils.setText(bold: .regular, size: 15, text: "\(OrderStatus.take.storageStatusText)/\(OrderStatus.canceled.storageStatusText)", color: .systemGray, button: menuBtns[3]) }
        
        _utils.setText(bold: .regular, size: 17, text: "μ΄μ©λ΄μ­μ΄ μμ΅λλ€.", alignment: .center, label: noBillsTitle)
        _utils.setText(bold: .bold, size: 17, text: "λ΄ μ£Όλ³ λ³΄κ΄μ κ²μ", color: .white, button: lookupStorage)
        lookupStorage.layer.cornerRadius = lookupStorage.frame.height / 2
        lookupStorage.layer.borderColor = UIColor.white.cgColor
        lookupStorage.layer.borderWidth = 1
        lookupStorage.addTarget(self, action: #selector(self.onLookupStorage(_:)), for: .touchUpInside)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.pullRefresh(_:)), for: .valueChanged)
        scroll.refreshControl = refreshControl
        scroll.delegate = self
    }
    
    func configure() {
        if vm == nil { return }
        noBills.isHidden = !vm.currentDatas.isEmpty
        if vm.currentDatas.isEmpty { return }
        
        for data in vm.currentDatas {
            let item = StorageBillContainer()
            stack.addArrangedSubview(item)
            item.heightAnchor.constraint(equalToConstant: 40).isActive = true
            item.configure(title: data.title, datas: data.bills)
            item.delegate = self
            
            if data.title == vm.currentDatas.first?.title { item.isSpreaded = true }
        }
        
        let emptyview = UIView()
        emptyview.backgroundColor = .white
        stack.addArrangedSubview(emptyview)
        emptyview.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
    // κ²μ UI μ€μ 
    func setLookupUI() {
        lookup.placeholder = "'ν€μλ'λ₯Ό μλ ₯νμΈμ"
        lookup.returnKeyType = .search
        lookupBox.layer.shadowOffset = CGSize(width: 3, height: 3)
        lookupBox.layer.shadowRadius = 2
        lookupBox.layer.shadowOpacity = 0.1
        lookupBox.layer.cornerRadius = 6
        lookupBox.layer.borderWidth = 1
        lookupBox.layer.borderColor = UIColor.systemGray3.cgColor
        lookupBox.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onLookup(_:))))
    }
    
    // λ©λ΄ λ²νΌ μ΄κΈ°ν
    private func setMenuBtn(btn: UIButton) {
        
        btn.layer.cornerRadius = btn.frame.height / 2
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.systemGray3.cgColor
        btn.tintColor = .clear
        btn.layer.shadowOffset = CGSize(width: 2, height: 2)
        btn.layer.shadowRadius = 2
        btn.layer.shadowOpacity = 0.1
        btn.layer.shadowColor = UIColor.darkGray.cgColor
         
        setMenuBtnSelected(selected: false, btn: btn)
    }
    
    // λ©λ΄ λ²νΌ μ ν/μ νν΄μ 
    func setMenuBtnSelected(selected: Bool, btn: UIButton) {
        btn.isSelected = selected
        
        if selected {
            btn.layer.borderWidth = 0
            btn.layer.shadowOpacity = 0
            btn.backgroundColor = _symbolColor
        } else {
            btn.layer.borderWidth = 1
            btn.layer.shadowOpacity = 0.2
            btn.backgroundColor = .white
        }
    }
    
    func refreshStack() {
        stack.arrangedSubviews.forEach({
            if noBills != $0 {
                $0.removeFromSuperview()
                NSLayoutConstraint.deactivate($0.constraints)
            }
        })
    }
    
    func redrawBills() {
        refreshStack()
        configure()
    }
    
    func reset() {
        refreshStack()
        vm.reset()
        for btn in menuBtns { if btn.isSelected { setMenuBtnSelected(selected: false, btn: btn) } }
    }
    
    func refresh() {
        reset()
        vm.getMonths(orderStatus: vm.currentOrderStatus) { (_, _) in
            guard self.vm.datas.count > 0 else { return }
            let firstData = self.vm.datas[0]
            self.vm.getBills(month: firstData.title, orderStatus: "") { (success, msg) in
                self.vm.currentDatas = self.vm.datas
                
                // μ²«λ²μ§Έ λ©λ΄ λ²νΌ μ ν
                if self.selectedMenuIndex < self.menuBtns.count {
                    self.onMenuBtn(self.menuBtns[self.selectedMenuIndex])
                }
            }
        }
    }
}

// MARK: - Actions
extension BillsVc {
    @objc func pullRefresh(_ sender: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            self.scroll.refreshControl?.endRefreshing()
            self.refresh()
        }
    }
    
    /// κ²μμ°½ ν°μΉμ νΈμΆλ¨
    @objc func onLookup(_ sender: UIGestureRecognizer) {
        lookup.becomeFirstResponder()
    }
    
    @IBAction func onMenuBtn(_ sender: UIButton) {
        
        // μ νλ λ²νΌμ λ μ νλμ§ μλλ‘ν¨
        if sender.isSelected { return }
        
        // μ΄μ μ μ νλμ΄μλ λ²νΌ μ ν ν΄μ 
//        if all.isSelected { setMenuBtnSelected(selected: false, btn: all) }
        for btn in menuBtns { if btn.isSelected { setMenuBtnSelected(selected: false, btn: btn) } }
        
        
        // μ νλ λ²νΌ μ ν μ²λ¦¬
        setMenuBtnSelected(selected: !sender.isSelected, btn: sender)
        
        // 'μ μ²΄' λ²νΌ μ ν
//        if sender == all {
//            vm.setCurrentDatas(orderStatus: "")
//        }
        
        // 'μ μ²΄' λ²νΌ μ ν
        if menuBtns.count > 0 && sender == menuBtns[0] {
            selectedMenuIndex = 0
            vm.setCurrentDatas(orderStatus: "")
        }
        // 'μμ½' λ²νΌ μ ν
        else if menuBtns.count > 1 && sender == menuBtns[1] {
            selectedMenuIndex = 1
            vm.setCurrentDatas(orderStatus: OrderStatus.reserved.rawValue)
        }
        // 'μ§ν' λ²νΌ μ ν
        else if menuBtns.count > 2 && sender == menuBtns[2] {
            selectedMenuIndex = 2
            vm.setCurrentDatas(orderStatus: OrderStatus.entrust.rawValue)
        }
        // 'μλ£/μ·¨μ' λ²νΌ μ ν
        else if menuBtns.count > 3 && sender == menuBtns[3] {
            selectedMenuIndex = 3
            vm.setCurrentDatas(orderStatus: OrderStatus.take.rawValue)
        }
        
        redrawBills()
    }
    
    @objc func onLookupStorage(_ sender: UIButton) {
        _events.moveToMap()
    }
}

// MARK: - UIScrollviewDelegate
extension BillsVc: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        if(velocity.y < -0.1) {
//            refresh()
//        }
    }
}

// MARK: - StorageBillContainerDelegate
extension BillsVc: StorageBillContainerDelegate {
    func onSpread(container: StorageBillContainer, month: String) {
        let orderStatus = vm.currentOrderStatus
        vm.getBills(month: month, orderStatus: orderStatus) { (success, msg) in
            let billDatas = self.vm.getMonthBills(month: month, orderStatus: orderStatus)
            container.configure(title: month, datas: billDatas)
            container.spread()
        }
    }
}

// MARK: - MyEventsDelegate
extension BillsVc: MyEventsDelegate {
    func orderStatusChanged() {
        refresh()
    }
}

// MARK: - BillsVmDelegate
/*
extension BillsVc: BillsVmDelegate {
    func ready() {
        configure()
        
    }
}
 */
