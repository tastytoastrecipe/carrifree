//
//  NeedUpdateController.swift
//  Carrifree
//
//  Created by plattics-kwon on 2021/05/17.
//  Copyright © 2021 plattics. All rights reserved.
//

import UIKit

class NeedUpdateVc: UIViewController {
    
    @IBOutlet weak var needUpdate: UILabel!
    @IBOutlet weak var moveToStore: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setDefault()
    }
    
    func setDefault() {
        needUpdate.text = _strings[.requiredAppUpdate]
        moveToStore.setTitle(_strings[.moveToStore], for: .normal)
    }
}

// MARK:- Actions
extension NeedUpdateVc {
    @IBAction func onMoveToStore(_ sender: UIButton) {
        _utils.openAppStore(urlStr: _identifiers[.appstoreUrl])
    }
}
