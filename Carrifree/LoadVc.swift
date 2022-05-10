//
//  ViewController.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2020/12/28.
//

import UIKit

class LoadVc: UIViewController {
    
    @IBOutlet weak var loadingBar: LoadingBar!
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadingBar.animationDuration = 2
        self.loadingBar.cornerRadius = self.loadingBar.frame.height / 2
        loadingBar.delegate = self
        
        // 업데이트 확인
        _cas.general.getUpdateInfo() { (needUpdate) in
            if needUpdate {
                let vc = NeedUpdateVc()
                vc.modalPresentationStyle = .fullScreen
                _utils.topViewController()?.present(vc, animated: true, completion: nil)
                
            } else {
                if _user.signIn { self.loadScene(); return }
                
                // fcm registration
                CarryPush.shared.delegate = self
                CarryPush.shared.setRegistrationToken()
            }
        }
    }
    
    func configure() {
        requestLogin()
    }
    
    // login
    func requestLogin() {
        /*
        // test!
        vm.testLogin() { (success, msg) in
            if success {
                self.loadScene()
            } else {
                self.mainRequestFailed()
            }
        }
        */
        
        let userId = UserDefaults.standard.string(forKey: _identifiers[.keyUserId]) ?? ""
        let userPw = UserDefaults.standard.string(forKey: _identifiers[.keyUserPw]) ?? ""
        if userId.isEmpty || userPw.isEmpty { signinFailed(); return }
        
//        let enpw = _utils.decrypt(encoded: userPw)
        if userPw.isEmpty { signinFailed(); return }
         
        _cas.signin.signin(id: userId, pw: userPw) { (success, json) in
            if success {
                _user.saveData(userId: userId, userPw: userPw, json: json)
                _cas.signin.sendDeviceInfo(userSeq: _user.seq, url: json?["resUrl"].stringValue ?? "", userName: _user.name) { (success, json) in
                    if success {
                        self.loadScene()
                    }
                    else {
                        self.signinFailed()
                    }
                }
            }
            else { self.signinFailed() }
        }
    }
    
    func loadScene() {
        self.loadingBar.value = self.loadingBar.max
    }
    
    func moveScene(destination: UIViewController?) {
        guard let vc = destination else { return }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func signinFailed() {
        let signInVc = SigninVc()
        let naviController = UINavigationController(rootViewController: signInVc)
        naviController.modalPresentationStyle = .fullScreen
        self.present(naviController, animated: true)
    }
    
    func moveToStart() {
        let vc = StartVc()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func moveToSignin() {
        let signinVc = SigninVc()
        let naviController = UINavigationController(rootViewController: signinVc)
        naviController.modalPresentationStyle = .fullScreen
        self.present(naviController, animated: true)
    }
    
    func moveToMain() {
        let vc = MainVc()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

// MARK:- CarryPushDelegate
extension LoadVc: CarryPushDelegate {
    func getTokenComplete() {
        configure()
    }
}

extension LoadVc: LoadingBarDelegate {
    func animationEnd(bar: LoadingBar) {
        if bar.isMax { moveToMain() }
    }
}
