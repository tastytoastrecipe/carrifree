//
//  NaviEditor.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/21.
//
//
//  π¬ NaviEditor
//  νλ©΄μ΄ λ°λλλ§λ€ λ©μΈ MyNaviμ μνλ₯Ό λ³κ²½νλ λΈλ¦Ώμ§ ν΄λμ€
//

import Foundation

class NaviEditor {
    
    /// νλ©΄ κ΅¬λΆ
    enum Scene {
        case main
        case map
        case carry
        case history
        case mypage
        
        var index: Int {
            switch self {
            case .main: return 0
            case .map: return 1
            case .carry: return 2
            case .history: return 3
            case .mypage: return 4
            }
        }
        
        var name: String {
            switch self {
            case .main: return MainVc.name
            case .map: return StorageMapVc.name
            case .carry: return CarryNotReadyVc.name
            case .history: return BillsVc.name
            case .mypage: return MyPageVc.name
            }
        }
    }
    
    static var currentScene: Scene = .main
    static var navi: MyNavi?
    
    static func editNavi(scene: NaviEditor.Scene, callbacks: [NaviCallback]) {
        guard let navi = navi else { return }
        
        switch scene {
        case .main:
            navi.setNaviCase(naviCase: .long)
            navi.setTitle(title: "")
            
            if currentScene != scene {
                navi.removeRightBtns()
                
                if callbacks.isEmpty { navi.addNaviRightBtn(systemImage: "bell") }
                else                 { navi.addNaviRightBtn(systemImage: "bell", callback: callbacks[0]) }
            }
            
            navi.removeLeftBtns()
            
            var hello: String = ""
            if _user.name.isEmpty { hello = "  μλνμΈμ μΊλ¦¬νλ¦¬μλλ€." }
            else { hello = "  \(_user.name)λ μλνμΈμ!" }
            navi.addLeftTitle(title: hello)
            
        case .map:
            navi.setNaviCase(naviCase: .search)
            navi.setTitle(title: _strings[.lookupStorage])
            navi.removeRightBtns()
            navi.removeLeftBtns()
            
        case .carry:
            navi.setNaviCase(naviCase: .search)
            navi.setTitle(title: "")
            navi.addNaviRightBtn(systemImage: "bell")
           
        case .history:
            navi.setNaviCase(naviCase: .normal)
            navi.setTitle(title: "λ΄μ­")
            navi.removeRightBtns()
            navi.removeLeftBtns()
            
        case .mypage:
            navi.setNaviCase(naviCase: .normal)
            navi.setTitle(title: _strings[.settingsSection03])
            
            if currentScene != scene {
                navi.removeRightBtns()
                
                if callbacks.isEmpty { navi.addNaviRightBtn(title: _strings[.save]) }
                else                 { navi.addNaviRightBtn(title: _strings[.save], callback: callbacks[0]) }
            }
            
            navi.removeLeftBtns()
        }
        
        currentScene = scene
    }
}
