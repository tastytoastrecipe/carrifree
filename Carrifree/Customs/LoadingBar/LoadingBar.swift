//
//  LoadingBar.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/10/19.
//

import UIKit

@objc protocol LoadingBarDelegate {
    @objc optional func animationEnd(bar: LoadingBar)
}

class LoadingBar: UIView {
    
    @IBOutlet weak var board: UIView!
    @IBOutlet weak var progress: UIView!
    
    @IBInspectable var max: Float = 1
    @IBInspectable var value: Float = 0 {
        didSet {
            if value > max { value = max }
            if isAnimating { isUpdateRequired = true; return }
            
            if value == 0 {
                progressAnimate()
            } else {
                changeProgress(value: value, duration: self.animationDuration)
            }
            
        }
    }
    
    var cornerRadius: CGFloat {
        get {
            if nil == board { return 0 }
            return board.layer.cornerRadius
        }
        
        set {
            if nil != board { board.layer.cornerRadius = newValue }
            if nil != progress { progress.layer.cornerRadius = newValue }
        }
    }
    
    var isMax: Bool {
        get { return value == max }
    }

    var delegate: LoadingBarDelegate?
    var loadCompletion: (() -> Void)?
    var animationDuration: TimeInterval = 0.2
    var isUpdateRequired: Bool = false          // 애니메이션 중에 value 값이 변경되어 애니메이션이 끝난 후 다시 애니메이션을 실행해야하는지 여부
    var isAnimating: Bool = false               // 애니메이션 중인지 여부
    var xibLoaded: Bool = false
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: LoadingBar.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        progress.frame = CGRect(x: 0, y: 0, width: 0, height: self.frame.height)
    }
    
    private func changeProgress(value: Float, duration: TimeInterval) {
        if progress.frame.size.height != board.frame.height { progress.frame.size.height = board.frame.height }
        
        UIView.animate(withDuration: duration, animations: progressAnimate) { _ in
            self.isAnimating = false
            self.delegate?.animationEnd?(bar: self)
            if self.value == self.max { self.loadCompletion?() }
            
            if self.isUpdateRequired {
                self.changeProgress(value: self.value, duration: self.animationDuration)
                self.isUpdateRequired = false
            }
        }
    }
    
    func progressAnimate() {
        //    10   :    2    =    210    :    ??
        //  valueMax  value     viewWidth    newWidth
        // newWidth = value * viewWidth / valueMax
        
        // 뷰의 최대 크기보다 커지지 않도록 함
        let viewWidth = board.frame.width
        var newWidth = CGFloat(self.value * Float(viewWidth) / self.max)
        if newWidth > viewWidth { newWidth = viewWidth }
        
        let progressWidth = progress.frame.size.width
        if progressWidth == newWidth { return }
        
        if value > 0 { isAnimating = true }
        progress.frame.size.width = newWidth
    }
}
