//
//  StorageBillVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/02/10.
//
//
//  💬 StorageBillVc
//  주문의 상세 내역 화면
//

import UIKit

protocol StorageBillDocVcDelegate {
    func cancelDone()
}

class StorageBillDocVc: NaviVc {
    
    @IBOutlet weak var board: UIView!
    @IBOutlet weak var scrollview: UIScrollView!
    
    // title
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var vcDesc: UILabel!
    @IBOutlet weak var line: UIView!
    
    // storage
    @IBOutlet weak var orderNoTitle: UILabel!
    @IBOutlet weak var orderNo: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var bizName: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var locale: UIButton!
    @IBOutlet weak var worktime: UILabel!
    @IBOutlet weak var dayoff: UILabel!
    @IBOutlet weak var statusImg: UIImageView!
    
    // schedule
    @IBOutlet weak var scheduleTitle: UILabel!
    @IBOutlet weak var scheduleStart: BillScheduleCell!
    @IBOutlet weak var scheduleEnd: BillScheduleCell!
    @IBOutlet weak var scheduleDesc: UILabel!
    
    // luggages
    @IBOutlet weak var luggagesTitle: UILabel!
    @IBOutlet weak var luggageS: BillLugCell!
    @IBOutlet weak var luggageM: BillLugCell!
    @IBOutlet weak var luggageL: BillLugCell!
    @IBOutlet weak var luggageXL: BillLugCell!
    
    // pictures
    @IBOutlet weak var pictureTitle: UILabel!
    @IBOutlet weak var pictureStack: UIStackView!
    @IBOutlet weak var pictureCount: UILabel!
    
    // comment
    @IBOutlet weak var commentTitle: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    // confirm
    @IBOutlet weak var confirm: StorageBillConfirmView!

    var delegate: StorageBillDocVcDelegate?
    var vm: BilldocVm!
    var orderSeq: String = ""
    var boardOriginY: CGFloat = 0
    var needUpdate: Bool = false            // 주문상태가 변경되었는지 여부 (전역 이벤트 호출할지 결정함)
    let pictureCellWidth: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollview.isHidden = true
        setNavi()
        setDefault()
        
        vm = BilldocVm()
        vm.getBilldoc(orderSeq: orderSeq) { (success, msg) in
            var message: String = ""
            if false == success { message = msg }
            
            self.vm.getDayoff() {
                self.vm.getLuggagePictures() { (success, msg) in
                    guard success else {
                        message = msg
                        let alert = _utils.createSimpleAlert(title: "주문 내역", message: message, buttonTitle: _strings[.ok]) { (_) in
                            self.dismiss(animated: true)
                        }
                        self.present(alert, animated: true)
                        return
                    }
                    
                    self.configure()
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if needUpdate { _events.orderStatusChanged() }
    }
    
    // navigation
    func setNavi() {
        createMyNavi(title: "주문 내역", naviCase: .normal, btns: [], backHidden: false)
        myNavi.delegate = self
        setBoard()
    }
    
    // ui defaults
    func setDefault() {
        boardOriginY = boardTopCnst.constant
        
        board.clipsToBounds = true
        board.roundCorners(cornerRadius: 16, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        
        _utils.setText(bold: .extraBold, size: 30, text: "", color: _symbolColor, label: vcTitle)
        _utils.setText(bold: .regular, size: 16, text: "", color: .systemGray, label: vcDesc)
        _utils.drawDottedLine(start: CGPoint(x: 0, y: 0), end: CGPoint(x: line.frame.maxX, y: 0), view: line)
        _utils.setText(bold: .regular, size: 12, text: "주문번호", color: .systemGray, label: orderNoTitle)
        _utils.setText(bold: .bold, size: 16, text: "", label: orderNo)
        _utils.setText(bold: .regular, size: 13, text: "", color: .systemGray3, label: orderDate)
        _utils.setText(bold: .regular, size: 15, text: "", color: .systemGray, label: category)
        _utils.setText(bold: .bold, size: 30, text: "", label: bizName)
        _utils.setText(bold: .regular, size: 12, text: "", color: .systemGray, label: address)
        _utils.setText(bold: .bold, size: 17, text: "위치보기", color: _symbolColor, button: locale)
        locale.layer.cornerRadius = locale.frame.height / 2
        locale.layer.borderWidth = 1
        locale.layer.borderColor = _symbolColor.cgColor
        locale.layer.shadowOffset = CGSize(width: 2, height: 2)
        locale.layer.shadowRadius = 1
        locale.layer.shadowOpacity = 0.2
        
        _utils.setText(bold: .bold, size: 20, text: "보관시간", label: scheduleTitle)
        _utils.setText(bold: .regular, size: 14, text: "보관이 완료되면 실제 ‘보관시간’ 시간과 ’보관종료’ 시간으로 변경됩니다.", label: scheduleDesc)
        _utils.setText(bold: .bold, size: 20, text: "짐개수", label: luggagesTitle)
        _utils.setText(bold: .bold, size: 18, text: "짐사진", label: pictureTitle)
        _utils.setText(bold: .regular, size: 14, text: "0/10", label: pictureCount)
        _utils.setText(bold: .bold, size: 18, text: "요청사항", label: commentTitle)
        _utils.setText(bold: .regular, size: 17, text: "", color: UIColor.systemGray, label: comment)
        
        pictureStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onPictures(_:))))
    }
    
    func configure() {
        scrollview.isHidden = false
        let orderStatus = OrderStatus(rawValue: vm.data.orderStatus) ?? .none
        vcTitle.text = orderStatus.storageBillTitle
        _utils.setText(bold: .regular, size: 16, text: orderStatus.storageBillDesc, color: .systemGray, label: vcDesc)
        scheduleDesc.text = orderStatus.storageScheduleDesc
        orderNo.text = vm.data.orderNo
        orderDate.text = vm.data.orderDate
        category.text = StorageCategory(rawValue: vm.data.category)?.name
        bizName.text = vm.data.bizName
        address.text = vm.data.address
        luggageS.configure(title: LuggageType.s.luggageName, desc: "(\(LuggageType.s.longName))", ea: vm.data.luggages.s)
        luggageM.configure(title: LuggageType.m.luggageName, desc: "(\(LuggageType.m.longName))", ea: vm.data.luggages.m)
        luggageL.configure(title: LuggageType.l.luggageName, desc: "(\(LuggageType.l.longName))", ea: vm.data.luggages.l)
        luggageXL.configure(title: LuggageType.xl.luggageName, desc: "(\(LuggageType.xl.longName))", ea: vm.data.luggages.xl)
        comment.text = vm.data.comment
        if vm.data.comment.isEmpty { comment.text = "없음" }
        
        
        // schedule
        var startDesc: String = "이후"
        if orderStatus == .entrust || orderStatus == .take { startDesc = ""}
        scheduleStart.configure(title: "보관시작", schedule: vm.data.schedule.start, desc: startDesc)
        
        var endDesc: String = "이전"
        if orderStatus == .take { endDesc = ""}
        scheduleEnd.configure(title: "보관종료", schedule: vm.data.schedule.end, desc: endDesc)
        
        
        // ---------------------------- 운영시간 문자열 설정 ---------------------------- //
        
        // 사용할 폰트
        let worktimeFontBold = UIFont(name: "NanumSquareB", size: 17)
        let worktimeFontRegular = UIFont(name: "NanumSquareR", size: 17)
        
        // "운영시간: 08:00 - 16:00" 문자열 생성
        let worktimeStr01 = "운영시간: "
        let worktimeStr02 = "\(vm.data.worktime)"
        var totalTitle = "\(worktimeStr01) \(worktimeStr02)"
        let attString01 = NSMutableAttributedString(string: totalTitle, attributes: [
          .font: worktimeFontRegular!,
          .foregroundColor: _symbolColor
        ])
        
        // "08:00 - 16:00" 폰트 설정
        attString01.addAttributes([
          .font: worktimeFontBold!,
          .foregroundColor: UIColor.label
        ], range: NSRange(location: worktimeStr01.count + 1, length: worktimeStr02.count))
        
        worktime.attributedText = attString01
        
        // ------------------------------------------------------------------------- //
        
        
        
        // ---------------------------- 휴무일 문자열 설정 ---------------------------- //
        
        // "휴무일: 토, 일, 국경일" 문자열 생성
        let dayoffStr01 = "휴무일: "
        
        var dayoffWeekStr = ""
        
        if vm.data.dayoff.isEmpty {
            dayoffWeekStr = "없음"
        } else {
            for (i, dayoff) in vm.data.dayoff.enumerated() {
                let dayoffStr = Weekday(rawValue: dayoff)?.name ?? ""
                if i == vm.data.dayoff.count - 1 {
                    dayoffWeekStr += dayoffStr
                } else {
                    dayoffWeekStr += (dayoffStr + ", ")
                }
            }
        }
        
        
        /*
        let holidayStr = "국경일"
        var dayoffStr02 = ""
        if vm.data.holiday {
            dayoffStr02 = "\(dayoffWeekStr), \(holidayStr)"
        } else {
            dayoffStr02 = dayoffWeekStr
        }
        */
        
//        totalTitle = "\(dayoffStr01) \(dayoffStr02)"
        totalTitle = "\(dayoffStr01) \(dayoffWeekStr)"
        let attString02 = NSMutableAttributedString(string: totalTitle, attributes: [
          .font: worktimeFontRegular!,
          .foregroundColor: _symbolColor
        ])
        
        // "토, 일, 국경일" 폰트 설정
        attString02.addAttributes([
          .font: worktimeFontBold!,
          .foregroundColor: UIColor.label
        ], range: NSRange(location: dayoffStr01.count + 1, length: dayoffWeekStr.count))
//        ], range: NSRange(location: dayoffStr01.count + 1, length: dayoffStr02.count))
        
        dayoff.attributedText = attString02
        
        // ------------------------------------------------------------------------- //
        
        
        // create picture cell
        let imgUrls = vm.data.imgUrls
        for i in 0 ..< vm.maxPictureCount {
            let pictureCell = RegStoragePictureCell()
            let isMain = (i == 0)
            pictureCell.configure(isMain: isMain)
            pictureCell.updateMainStatus(isMain: false)
            pictureCell.isUserInteractionEnabled = false
            pictureStack.addArrangedSubview(pictureCell)
            pictureCell.widthAnchor.constraint(equalToConstant: pictureCellWidth).isActive = true
            
            if i < imgUrls.count {
                pictureCell.setImageWithUrl(url: imgUrls[i], registered: true, seq: "", deleteBtnHidden: true)
            } else {
                pictureCell.setImageWithImage(image: UIImage(named: "img-empty-picture"), registered: false, seq: "", deleteBtnHidden: true)
            }
        }
        
        pictureCount.text = "\(vm.data.imgUrls.count)/10"
        
        // confirm view
        confirm.configure(data: vm.data)
        confirm.delegate = self
        
        // status img
        if orderStatus == .canceled {
            statusImg.image = UIImage(named: "img-order-cancel")
        } else if orderStatus == .take {
            statusImg.image = UIImage(named: "img-order-complete")
        } else {
            statusImg.isHidden = true
        }
        
    }
    
    func requestOrderCancel() {
        if false == _utils.createIndicator() { return }
        
        vm.requestCancel() { (success, msg) in
            _utils.removeIndicator()
            
            guard success else {
                let alert = _utils.createSimpleAlert(title: "주문 취소", message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
                return
            }
            
            self.needUpdate = true
            
            let alert = _utils.createSimpleAlert(title: "주문 취소", message: "주문이 취소되었습니다.", buttonTitle: _strings[.ok]) { (_) in
                self.dismiss(animated: true)
            }
            self.present(alert, animated: true)
        }
    }
}

// MARK: - MyNaviDelegate
extension StorageBillDocVc: MyNaviDelegate {
    func onBack() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false)
    }
    
    @IBAction func onExit(_ sender: UIButton) {
        onBack()
    }
    
    @IBAction func onLocale(_ sender: UIButton) {
        if vm.data.lat == 0 && vm.data.lng == 0 { return }
        let vc = LocaleVc()
        vc.locale = (lat: vm.data.lat, lng: vm.data.lng)
        vc.localeName = vm.data.bizName
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @objc func onPictures(_ sender: UIGestureRecognizer) {
        let imgUrls = vm.data.imgUrls
        if imgUrls.isEmpty { return }
        let vc = FullScreenImgWithThumbsVc()
        vc.imgUrls = imgUrls
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

// MARK: - StorageBillConfirmViewDelegate
extension StorageBillDocVc: StorageBillConfirmViewDelegate {
    func orderCancel() {
        let no = _utils.createAlertAction(title: _strings[.no])
        let yes = _utils.createAlertAction(title: "네, 취소할게요", titleColor: .systemRed) { (_) in self.requestOrderCancel() }
        let alert = _utils.createAlert(title: "주문 취소", message: "이 주문을 취소하시겠습니까?", handlers: [yes, no] , style: .alert, addCancel: false)
        self.present(alert, animated: true)
    }
    
    func startStorging() {
        let vc = BillConfirmVc()
        vc.modalPresentationStyle = .overFullScreen
        vc.vm = vm
        vc.delegate = self
        self.present(vc, animated: false)
    }
}

// MARK: - BillConfirmVcDelegate
extension StorageBillDocVc: BillConfirmVcDelegate {
    func onContinue() {
        
    }
    
    func onExit(confirmed: Bool) {
        if confirmed {
            needUpdate = true
            onBack()
//            let orderStatus = OrderStatus(rawValue: self.vm.data.orderStatus) ?? .none
//            self.vcTitle.text = orderStatus.storageBillTitle
//            self.vcDesc.text = orderStatus.storageBillDesc
//            self.confirm.setStatus(data: self.vm.data)
        }
    }
}


