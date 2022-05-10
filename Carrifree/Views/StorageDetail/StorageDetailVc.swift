//
//  StorageDetailVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/17.
//

import UIKit

class StorageDetailVc: UIViewController {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var viewTopHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var cardview: StorageCardView!
    
    @IBOutlet weak var storageStatusTitle: UILabel!
    @IBOutlet weak var storageStatusDesc: UILabel!
    @IBOutlet weak var storageCostTitle: UILabel!
    @IBOutlet weak var storageCostDesc: UILabel!
    @IBOutlet weak var costview: CostBoard!
    
    @IBOutlet weak var reviewLine: UIView!
    @IBOutlet weak var reviews: ReviewSimpleList!
    @IBOutlet weak var orderView: UIView!
    @IBOutlet weak var order: UIButton!
    
    @IBOutlet var lines: [UIView]!
    
    var vm: StorageDetailVm!
    var storageSeq: String = ""
    var lat: Double = 0
    var lng: Double = 0
    var originTopHeight: CGFloat = 0
    let maxTopHeight: CGFloat = 400
    let minTopHeight: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originTopHeight = viewTopHeight.constant
        img.image = UIImage(named: "img-default-store")
        img.contentMode = .scaleAspectFill
        img.isUserInteractionEnabled = true
        img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onImg(_:))))
        scrollview.delegate = self
        _utils.setText(bold: .regular, size: 14, text: "보관상태: ", label: storageStatusTitle)
        _utils.setText(bold: .bold, size: 14, text: "", label: storageStatusDesc)
        _utils.setText(bold: .regular, size: 14, text: "보관가격: ", label: storageCostTitle)
        _utils.setText(bold: .bold, size: 14, text: "아래 요금표를 확인하세요.", label: storageCostDesc)
        _utils.setText(bold: .bold, size: 18, text: "보관진행", color: .white, button: order)
        order.addTarget(self, action: #selector(self.onOrder(_:)), for: .touchUpInside)
        orderView.layer.shadowOffset = CGSize(width: 0, height: -3)
        orderView.layer.shadowRadius = 2
        orderView.layer.shadowOpacity = 0.06
        vm = StorageDetailVm(storageSeq: storageSeq, lat: lat, lng: lng, delegate: self)
        if false == _utils.createIndicator() { return }
    }
    
    override func viewWillAppear(_ animated: Bool) { _events.addDelegate(delegate: self) }
    override func viewWillDisappear(_ animated: Bool) { _events.removeDelegate(delegate: self) }
    
    func configure() {
        guard let data = vm.data else { return }
        
        // image
        if data.imgUrls.count > 0 {
            img.loadImage(url: data.imgUrls[0])
        }
        
        // cardview
        cardview.configure(data: data, heightCnst: "cardViewHeight")
        
        // costview
//        storageStatusDesc.text = StorageCapacity(rawValue: vm.data.status)?.status ?? ""
        storageStatusDesc.text = vm.data.status
        let defaultCosts = vm.getCostStrings(costs: vm.data.defaultCosts)
        let extraCosts = vm.getCostStrings(costs: vm.data.extraCosts)
        let dayCosts = vm.getCostStrings(costs: vm.data.dayCosts)
        costview.configure(defaultCosts: defaultCosts, extraCosts: extraCosts, dayCosts: dayCosts)
        
        // lines
        for line in lines {
            let yCenter = line.frame.height / 2
            _utils.drawDottedLine(start: CGPoint(x: 0, y: yCenter), end: CGPoint(x: line.frame.maxX, y: yCenter), view: line, pattern: (6, 4))
        }
        
        // reviews
        reviews.configure(title: "사용자 후기", datas: vm.data.reviews, reviewsInPage: 3)
        reviews.delegate = self
        /*
        if vm.data.reviews.count > 0 {
            reviews.configure(title: "사용자 후기", menuTitles: [AlignNearReview.recent.name, AlignNearReview.avg.name], datas: vm.data.reviews, reviewsInPage: 3)
            reviews.delegate = self
        } else {
            reviews.removeFromSuperview()
            
            if lines.count > 0 {
                if let sublayers = lines[lines.count - 1].layer.sublayers {
                    for sublayer in sublayers { sublayer.removeFromSuperlayer() }
                }
            }
        }
        */
    }
}

// MARK: - StorageDetailVmDelegate
extension StorageDetailVc: StorageDetailVmDelegate {
    func ready() {
        _utils.removeIndicator()
        configure()
        vm.getStoragePictures()
    }
    
    func notReady(msg: String) {
        _utils.removeIndicator()
        let alert = _utils.createSimpleAlert(title: "보관소 상세정보", message: msg, buttonTitle: _strings[.ok]) { (_) in
            self.dismiss(animated: true)
        }
        self.present(alert, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension StorageDetailVc: UIScrollViewDelegate {
    
    // 스크롤 위치에 따라 최상단의 뷰 높이 조절
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //현재 스크롤의 위치 (최상단 = 0)
        let y: CGFloat = scrollview.contentOffset.y
        
        //변경될 최상단 뷰의 높이
        let modifiedTopHeight: CGFloat = viewTopHeight.constant - y
        
        // *** 변경될 높이가 최댓값을 초과함
        if(modifiedTopHeight > maxTopHeight)
        {
            //현재 최상단뷰의 높이를 최댓값(250)으로 설정
            viewTopHeight.constant = maxTopHeight
        }// *** 변경될 높이가 최솟값 미만임
        else if(modifiedTopHeight < minTopHeight)
        {
            //현재 최상단뷰의 높이를 최솟값(50+상태바높이)으로 설정
            viewTopHeight.constant = minTopHeight
        }// *** 변경될 높이가 최솟값(50+상태바높이)과 최댓값(250) 사이임
        else
        {
            //현재 최상단 뷰 높이를 변경함
            viewTopHeight.constant = modifiedTopHeight
            scrollView.contentOffset.y = 0
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //현재 스크롤의 위치 (최상단 = 0)
        let y: CGFloat = scrollview.contentOffset.y
        
        //변경될 최상단 뷰의 높이
        let modifiedTopHeight: CGFloat = viewTopHeight.constant - y
        
        if(modifiedTopHeight > originTopHeight)
        {
            self.viewTopHeight.constant = self.originTopHeight
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                scrollView.contentOffset.y = 0
                self.view.layoutIfNeeded()
            })
        }
        
    }
}

// MARK: - Actions
extension StorageDetailVc {
    @objc func onImg(_ sender: UIGestureRecognizer) {
        let vc = FullScreenImgWithThumbsVc()
        for imgUrl in vm.data.imgUrls { vc.imgUrls.append(imgUrl) }
        
//        vc.imgDatas.append(UIImage(named: "img-test-storage-0")?.jpegData(compressionQuality: 0.7))
//        vc.imgDatas.append(UIImage(named: "img-test-storage-1")?.jpegData(compressionQuality: 0.7))
//        vc.imgDatas.append(UIImage(named: "img-test-storage-2")?.jpegData(compressionQuality: 0.7))
//        vc.imgDatas.append(UIImage(named: "img-test-storage-3")?.jpegData(compressionQuality: 0.7))
//        vc.imgDatas.append(UIImage(named: "img-test-storage-4")?.jpegData(compressionQuality: 0.7))
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false)
    }
    
    @objc func onOrder(_ sender: UIButton) {
        let vc = StorageConditionsVc()
        vc.modalPresentationStyle = .overFullScreen
        vc.vm = vm
        self.present(vc, animated: false)
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onExit(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

// MARK: - ReviewListDelegate
extension StorageDetailVc: ReviewListDelegate {
    func onMore() {
        let vc = ReviewsVc()
        vc.categories = ["최신순", "평점순"]
        vc.storageVm = vm
        vc.modalPresentationStyle = .fullScreen

        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.present(vc, animated: false, completion: nil)
    }
}

// MARK: - MyEventsDelegate
extension StorageDetailVc: MyEventsDelegate {
    func purchaseDone(seeBills: Bool) {
//         self.dismiss(animated: true)
        _events.removeDelegate(delegate: self)
        self.presentingViewController?.dismiss(animated: true)
    }
}
