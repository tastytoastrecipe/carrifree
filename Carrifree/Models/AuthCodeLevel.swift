//
//  AuthCodeLevel.swift
//  Carrifree
//
//  Created by orca on 2022/03/03.
//  Copyright © 2022 plattics. All rights reserved.
//
//
//  💬 AuthCodeLevel
//  휴대폰 인증시
//  인증 코드 각 자릿수마다 부여되는 상태값
//

import Foundation

enum AuthCodeLevel {
    case empty
    case removed
    case filled
}
