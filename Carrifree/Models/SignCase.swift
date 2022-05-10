//
//  SignCase.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/12/17.
//

enum SignCase {
    case normal
    case kakao
    case facebook
    case naver
    case apple
    case google
    case carrifree
    
    var type: String {
        switch self {
        case .normal: return    "001"
        case .kakao: return     "002"
        case .facebook: return  "003"
        case .naver: return     "004"
        case .apple: return     "005"
        case .google: return    "006"
        case .carrifree: return "010"
        }
    }
    
    var name: String {
        switch self {
        case .normal: return ""
        case .kakao: return _strings[.platformKakao]
        case .facebook: return _strings[.platformFacebook]
        case .naver: return _strings[.platformNaver]
        case .apple: return _strings[.platformApple]
        case .google: return _strings[.platformGoogle]
        case .carrifree: return ""
        }
    }
}
