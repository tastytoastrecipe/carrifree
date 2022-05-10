//
//  MainVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/06.
//

import UIKit
import PhotosUI

class MainVc: NaviVc {

    // tab
    lazy var myTabBar: MyTabBar = {
        let tabBarHeight: CGFloat = 100
        let tabBarFrame = CGRect(x: 0, y: self.view.frame.height - tabBarHeight, width: self.view.frame.width, height: tabBarHeight)
        let tempTabBar = MyTabBar(frame: tabBarFrame, itemSources: MyTab.allCases)
        tempTabBar.delegate = self
        return tempTabBar
    }()
    
    // [홈] 화면
    lazy var homeVc: HomeVc = {
        let tempHomeVc = HomeVc()
        tempHomeVc.delegate = self
        tempHomeVc.view.backgroundColor = .clear
        self.addChild(tempHomeVc)
        self.view.addSubview(tempHomeVc.view)
        tempHomeVc.didMove(toParent: self)
        
        tempHomeVc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tempHomeVc.view.topAnchor.constraint(equalTo: myNavi.bottomAnchor, constant: -108),
            tempHomeVc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            tempHomeVc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            tempHomeVc.view.bottomAnchor.constraint(equalTo: myTabBar.safeAreaLayoutGuide.topAnchor, constant: 0)
        ])
        return tempHomeVc
    }()
    
    // [보관 검색] 화면
    var storageMapVc: StorageMapVc?
    
    // [내정보] 화면
    var mypageVc: MyPageVc?
    
    // [운반 검색] 화면
    var carryVc: CarryNotReadyVc?
    
    // [내역] 화면
    var billsVc: BillsVc?
    
    var appeared: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createNavi()
        createTabBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _events.addDelegate(delegate: self)
        appeared = true
    }
    override func viewWillDisappear(_ animated: Bool) {
//        _events.removeDelegate(delegate: self)
        appeared = false
    }
    
    // [네이게이션] 생성
    func createNavi() {
        let noti = UIButton()
        noti.setImage(UIImage(systemName: "bell"), for: .normal)
        noti.tintColor = .white
        noti.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
        noti.addTarget(self, action: #selector(self.onNoti(_:)), for: .touchUpInside)
        createMyNavi(title: "댕댕이", naviCase: .long, btns: [noti], backHidden: true)
        NaviEditor.navi = myNavi
        myNavi.delegate = self
    }
    
    // [탭바] 생성
    func createTabBar() {
        // set tab bar
        self.view.addSubview(myTabBar)
        myTabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            myTabBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            myTabBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            myTabBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            myTabBar.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        myTabBar.select(index: 0)
    }

    // [검색] 화면 생성(show/hidden)
    func setStorageMapVcHidden(hidden: Bool, selectedStorageSeq: String = "", selectedStorageName: String = "") {
        if hidden {
            storageMapVc?.viewWillHide()
            storageMapVc?.view.isHidden = true
            return
        }
        
        guard nil == storageMapVc else {
            storageMapVc?.viewWillAppear()
            storageMapVc?.view.isHidden = false
            storageMapVc?.setSelectedStorage(storageSeq: selectedStorageSeq, storageName: selectedStorageName)
            return
        }
        
        let vc = StorageMapVc()
        vc.field = myNavi.field
        vc.selectedStorageSeq = selectedStorageSeq
        vc.selectedStorageName = selectedStorageName
        addChildVc(vc: vc)
        storageMapVc = vc
        self.view.bringSubviewToFront(myTabBar)
        storageMapVc?.viewWillAppear()
    }
    
    // [내정보] 화면 생성(show/hidden)
    func setMypageVcHidden(hidden: Bool) {
        if hidden {
            mypageVc?.view.isHidden = true
            return
        }
        
        guard nil == mypageVc else {
            mypageVc?.view.isHidden = false
            return
        }
        
        let vc = MyPageVc()
        addChildVc(vc: vc)
        mypageVc = vc
        
        self.view.bringSubviewToFront(myTabBar)
    }
    
    // [운반 검색] 화면 생성(show/hidden)
    func setCarryVcHidden(hidden: Bool) {
        if hidden {
            removeCarryVc()
            return
        }
        
        guard nil == carryVc else {
            carryVc?.view.isHidden = false
            return
        }
        
        let vc = CarryNotReadyVc()
        vc.delegate = self
        self.addChild(vc)
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            vc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            vc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            vc.view.bottomAnchor.constraint(equalTo: myTabBar.safeAreaLayoutGuide.topAnchor, constant: 0)
        ])
        carryVc = vc
        
        self.view.bringSubviewToFront(myTabBar)
    }
    
    // [내역] 화면 생성(show/hidden)
    func setbillsVcHidden(hidden: Bool) {
        if hidden {
            billsVc?.view.isHidden = true
            return
        }
        
        guard nil == billsVc else {
            billsVc?.viewWillAppear()
            billsVc?.view.isHidden = false
            return
        }
        
        let vc = BillsVc()
        addChildVc(vc: vc)
        billsVc = vc
        billsVc?.viewWillAppear()
        
        self.view.bringSubviewToFront(myTabBar)
    }
    
    func removeCarryVc() {
        if let carryVc = carryVc {
            carryVc.view.removeConstraints(carryVc.view.constraints)
            carryVc.view.removeFromSuperview()
            carryVc.removeFromParent()
            self.carryVc = nil
        }
    }
    
    // 전환될 뷰 컨트롤러의 constraint 설정, addChild
    func addChildVc(vc: UIViewController) {
        self.addChild(vc)
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: myNavi.bottomAnchor, constant: 0),
            vc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            vc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            vc.view.bottomAnchor.constraint(equalTo: myTabBar.safeAreaLayoutGuide.topAnchor, constant: 0)
        ])
    }
    
    // [네비게이션] 갱신
    func refreshNaviAndTab(tabIndex: Int) {
        if tabIndex == MyTab.home.rawValue {
            let naviCallback = NaviCallback(target: self, handler: #selector(self.onNoti(_:)))
            NaviEditor.navi = myNavi
            NaviEditor.editNavi(scene: .main, callbacks: [naviCallback])
            self.view.bringSubviewToFront(homeVc.view)
            homeVc.willAppear()
        }
        else if tabIndex == MyTab.storage.rawValue {
            NaviEditor.navi = myNavi
            NaviEditor.editNavi(scene: .map, callbacks: [])
        } else if tabIndex == MyTab.mypage.rawValue {
            NaviEditor.navi = myNavi
            let naviCallback = NaviCallback(target: self, handler: #selector(self.onSaveMyInfo(_:)))
            NaviEditor.editNavi(scene: .mypage, callbacks: [naviCallback])
        } else if tabIndex == MyTab.bills.rawValue {
            NaviEditor.navi = myNavi
            NaviEditor.editNavi(scene: .history, callbacks: [])
        }
        
        homeVc.view.isHidden = !(tabIndex == MyTab.home.rawValue)
        
        let lookupVcHidden = !(tabIndex == MyTab.storage.rawValue)
        setStorageMapVcHidden(hidden: lookupVcHidden)
        
        let mypageVcHidden = !(tabIndex == MyTab.mypage.rawValue)
        setMypageVcHidden(hidden: mypageVcHidden)
        
        let carryVcHidden = !(tabIndex == MyTab.carry.rawValue)
        setCarryVcHidden(hidden: carryVcHidden)
        
        let billsVcHidden = !(tabIndex == MyTab.bills.rawValue)
        setbillsVcHidden(hidden: billsVcHidden)
        
        self.view.bringSubviewToFront(myTabBar)
    }
}

// MARK: - Actions
extension MainVc {
    @objc func onNoti(_ sender: UIButton) {
        let alert = _utils.createSimpleAlert(title: "알림", message: "알림 서비스는 현재 준비중입니다.", buttonTitle: _strings[.ok])
        self.present(alert, animated: true)
    }
    
    @objc func onSaveMyInfo(_ sender: UIButton) {
        mypageVc?.onSave()
    }
}


// MARK: - MyTabBarDelegate
extension MainVc: MyTabBarDelegate {
    func itemSelected(index: Int) {
        refreshNaviAndTab(tabIndex: index)
    }
}

// MARK: - HomeVcDelegate
extension MainVc: HomeVcDelegate {
    func onMap() {
        myTabBar.select(index: MyTab.storage.rawValue)
    }
    
    func onStorageItemSelected(item: StorageItem) {
//        changeNaviCase(naviCase: .search)
        setStorageMapVcHidden(hidden: false, selectedStorageSeq: item.data.seq)
        myTabBar.select(index: MyTab.storage.rawValue)
        homeVc.view.isHidden = true
        self.view.bringSubviewToFront(myTabBar)
    }
}

// MARK: - CarryNotReadyVcDelegate
extension MainVc: CarryNotReadyVcDelegate {
    func carryVcDismissed() {
        // carryVc 제거
        removeCarryVc()
        
        // 메인 화면으로 이동
        myTabBar.select(index: NaviEditor.Scene.main.index)
        
        NaviEditor.navi = myNavi
        NaviEditor.editNavi(scene: .main, callbacks: [(target: self, handler: #selector(self.onNoti(_:)))])
    }
}

// MARK: - MyNaviDelegate
extension MainVc: MyNaviDelegate {
    func onTextfieldEditingBegin() {
        // 메인 화면으로 이동
        myTabBar.select(index: NaviEditor.Scene.map.index)
    }
}

// MARK: - MyEventsDelegate
extension MainVc: MyEventsDelegate {
    func showStorage(storageSeq: String, storageName: String) {
        if storageSeq.isEmpty { return }
        myTabBar.select(index: MyTab.storage.rawValue)
        storageMapVc?.setSelectedStorage(storageSeq: storageSeq, storageName: storageName)
        homeVc.view.isHidden = true
        self.view.bringSubviewToFront(myTabBar)
    }
    
    func storageItemSelected(storageSeq: String, storageName: String) {
        showStorage(storageSeq: storageSeq, storageName: storageName)
    }
    
    func storageSelectedInReview(storageSeq: String, storageName: String) {
        showStorage(storageSeq: storageSeq, storageName: storageName)
    }
    
    func purchaseDone(seeBills: Bool) {
        if seeBills {
            myTabBar.select(index: MyTab.bills.rawValue)
        } else {
            myTabBar.select(index: MyTab.home.rawValue)
        }
    }
    
    func moveToMap() {
        myTabBar.select(index: MyTab.storage.rawValue)
    }
    
}
