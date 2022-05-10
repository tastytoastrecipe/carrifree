//
//  ReviewBoardVc.swift
//  Carrifree
//
//  Created by orca on 2022/03/14.
//  Copyright © 2022 plattics. All rights reserved.
//

import UIKit

class ReviewDetailVc: UIViewController {
    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var board: UIView!
    
    @IBOutlet weak var boardBottom: NSLayoutConstraint!
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var pictureStack: UIStackView!
    @IBOutlet weak var line: UIView!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var reviewDate: UILabel!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var go: UIButton!

    var vm: ReviewDetailVm!
    var reviewSeq: String = ""
    var attachGrpSeq: String = ""
    
    let maxContentHeight: CGFloat = 380
    let minContentHeight: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if reviewSeq.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                self.notReady(msg: "잘못된 리뷰 데이터입니다. 다시 시도해주시기 바랍니다.")
            }
            return
        }
        boardBottom.constant = -(maxContentHeight + 200)
        
        _utils.setText(bold: .bold, size: 23, text: "", label: storeName)
        _utils.drawDottedLine(start: CGPoint(x: 0, y: 0), end: CGPoint(x: line.frame.maxX, y: 0), view: line)
        _utils.setText(bold: .bold, size: 12, text: "", color: _symbolColor, label: userName)
        _utils.setText(bold: .regular, size: 12, text: "", color: .systemGray3, label: reviewDate)
        _utils.setText(bold: .regular, size: 14, text: "", color: .systemGray, textview: content)
        content.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        _utils.setText(bold: .regular, size: 17, text: _strings[.goOrder], color: .white, button: go)
        go.addTarget(self, action: #selector(self.onGo(_:)), for: .touchUpInside)
        vm = ReviewDetailVm(reviewSeq: reviewSeq, delegate: self)
        vm.attachGrpSeq = attachGrpSeq
    }
    
    func animateBoard(appear: Bool, completion: (() -> Void)? = nil) {
        if appear {
            UIView.animate(withDuration: 0.3, animations: {
                self.boardBottom.constant = 0
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                completion?()
            })
        } else {
            self.bg.backgroundColor = .clear
            UIView.animate(withDuration: 0.25, animations: {
                self.boardBottom.constant = -(self.board.frame.height)
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                completion?()
            })
        }
        
    }

    func configure() {
        storeName.text = vm.storageName
        userName.text = "\(vm.userName)님의 작성후기"
        reviewDate.text = vm.reviewDate
        content.text = vm.reviewContent
        
        let contentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: content.frame.width, height: content.frame.height))
        contentLabel.numberOfLines = 0
        contentLabel.text = vm.reviewContent
        contentLabel.sizeToFit()
        let contentHeight: CGFloat = contentLabel.frame.height
        for cnst in content.constraints {
            if cnst.firstAttribute == .height {
                cnst.constant = contentHeight
                if cnst.constant > self.maxContentHeight {
                    cnst.constant = self.maxContentHeight
                } else if cnst.constant < self.minContentHeight {
                    cnst.constant = self.minContentHeight
                }
                break
            }
        }
        
        getPictures(attachGrpSeq: vm.attachGrpSeq)
        animateBoard(appear: true)
    }
    
    func getPictures(attachGrpSeq: String) {
        if attachGrpSeq.isEmpty { return }
        
        vm.getReviewPictures(attachGrpSeq: attachGrpSeq) { (_, _) in
            let urls = self.vm.imgUrls
            for (index, url) in urls.enumerated() {
                let img = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: self.pictureStack.frame.height))
                img.image = UIImage(named: "img-empty-picture")
                img.loadImage(url: url)
                img.contentMode = .scaleAspectFill
                img.tag = index
                img.isUserInteractionEnabled = true
                img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onPictures(_:))))
                self.pictureStack.addArrangedSubview(img)
                img.clipsToBounds = true
                img.widthAnchor.constraint(equalToConstant: 100).isActive = true
            }
        }
    }
}

// MARK: - Actions
extension ReviewDetailVc {
    @IBAction func onExit(_ sender: UIButton) {
        animateBoard(appear: false) { self.dismiss(animated: false) }
    }
    
    @objc func onPictures(_ sender: UIGestureRecognizer) {
        let vc = FullScreenImgWithThumbsVc()
        let selectedPictureTag = sender.view?.tag ?? 0
        vc.selectedImgIndex = selectedPictureTag
        
        for subview in self.pictureStack.arrangedSubviews {
            guard let imgview = subview as? UIImageView else { continue }
            let img = imgview.image
            vc.imgDatas.append(img?.jpegData(compressionQuality: 0.7))
        }
        self.present(vc, animated: true)
    }
    
    @objc func onGo(_ sender: UIButton) {
        if vm.lat == 0 && vm.lng == 0 {
            let alert = _utils.createSimpleAlert(title: "보관 진행", message: "보관소의 위치를 불러오지 못했습니다. 다시 시도해주시기 바랍니다.", buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
            return
            
        }
        
        self.dismiss(animated: true) {
            _events.storageSelectedInReview(storageSeq: self.vm.storageSeq, storageName: self.vm.storageName)
        }
        
        
        /*
        let vc = StorageDetailVc()
        vc.storageSeq = vm.storageSeq
        vc.lat = vm.lat
        vc.lng = vm.lng
        vc.modalPresentationStyle = .fullScreen
        _utils.topViewController()?.present(vc, animated: true)
        */
    }
}

// MARK: - ReviewDetailVmDelegate
extension ReviewDetailVc: ReviewDetailVmDelegate {
    func ready() {
        configure()
    }
    
    func notReady(msg: String) {
        let alert = _utils.createSimpleAlert(title: _strings[.review], message: msg, buttonTitle: _strings[.ok]) { (_) in
            self.dismiss(animated: true)
        }
        
        self.present(alert, animated: true)
    }
}
