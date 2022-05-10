//
//  StorageConditions.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/27.
//
//
//  💬 StorageConditionsVc
//  보관 조건 입력 화면
//

import UIKit
import Photos
import PhotosUI
import Mantis

class StorageConditionsVc: NaviVc {
    
    // storage info
    @IBOutlet weak var board: UIView!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var bizName: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var ratingTitle: UILabel!
    @IBOutlet weak var ratingImg: UIImageView!
    @IBOutlet weak var ratingTxt: UILabel!
    @IBOutlet weak var workTime: UILabel!
    @IBOutlet weak var meritsBoard: UIView!

    // schedule
    @IBOutlet weak var scheduleTitle: UILabel!
    @IBOutlet weak var startDate: OrderDatePickerView!
    @IBOutlet weak var endDate: OrderDatePickerView!
    @IBOutlet weak var descBoard: UIView!
    
    // luggages
    @IBOutlet weak var lugTitle: UILabel!
    @IBOutlet weak var cost: UIButton!
    @IBOutlet weak var lugSmall: OrderLugPickerView!
    @IBOutlet weak var lugMedium: OrderLugPickerView!
    @IBOutlet weak var lugLarge: OrderLugPickerView!
    @IBOutlet weak var lugXLarge: OrderLugPickerView!
    
    // pictures
    @IBOutlet weak var pictureTitle: UILabel!
    @IBOutlet weak var pictureStack: UIStackView!
    @IBOutlet weak var pictureCount: UILabel!
    
    // comment
    @IBOutlet weak var commentTitle: UILabel!
    @IBOutlet weak var commentField: UITextField!
    
    @IBOutlet weak var go: UIButton!
    
    @IBOutlet var lines: [UIView]!

    let cropRectRatio: Double = 16.0 / 10.0     // crop rect 가로 x 세로 설정 (ex. 16:9 비율이면 16.0 / 9.0)
    let pictureCellWidth: CGFloat = 97
    
    var vm: StorageDetailVm!
    var boardOriginY: CGFloat = 0
    var pictureCells: [RegStoragePictureCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavi()
        setDefault()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) { self.configure() }
    }

    override func viewDidAppear(_ animated: Bool) {
        board.isHidden = false
        UIView.animate(withDuration: 0.48, animations: { () -> Void in
            self.boardTopCnst.constant = self.boardOriginY + 24
            self.view.layoutIfNeeded()
        })
    }
    
    // navigation
    func setNavi() {
        createMyNavi(title: "보관 주문서", naviCase: .normal, btns: [], backHidden: false)
        myNavi.delegate = self
        setBoard()
    }
    
    func setDefault() {
        boardOriginY = boardTopCnst.constant
        
        board.isHidden = true
        board.layer.cornerRadius = 16
        boardTopCnst.constant = board.frame.height - 100
        
        _utils.setText(bold: .regular, size: 13, text: "", label: category)
        _utils.setText(bold: .extraBold, size: 26, text: "", label: bizName)
        _utils.setText(bold: .regular, size: 12, text: "", label: address)
        _utils.setText(bold: .bold, size: 10, text: "", label: ratingTitle)
        _utils.setText(bold: .extraBold, size: 9, text: "", label: ratingTxt)
        _utils.setText(bold: .regular, size: 15, text: "", label: workTime)
    }
    
    func configure() {
        if vm == nil { return }
        let categoryName = StorageCategory(rawValue: vm.data.category)?.name ?? ""
        category.text = categoryName            // category
        bizName.text = vm.data.name             // title
        address.text = vm.data.address          // address
        ratingTitle.text = "사용자 총 평점"         // ratings
        ratingTxt.text = "\(vm.data.rating)"
        setWorktime()                           // worktime
        setMerits()                             // merits
        setSchedules()                          // schedule desc
        setLuggages()                           // luggages
        setPictures()                           // pictures
        setComment()                            // comment
        
        _utils.setText(bold: .bold, size: 20, text: "보관진행", color: .white, button: go)
        go.addTarget(self, action: #selector(self.onGo(_:)), for: .touchUpInside)
        
        // lines
        for line in lines {
            let yCenter = line.frame.height / 2
            _utils.drawDottedLine(start: CGPoint(x: 0, y: yCenter), end: CGPoint(x: line.frame.maxX, y: yCenter), view: line, pattern: (6, 4))
        }
    }
    
    // MARK: - worktime 문자열 생성
    func setWorktime() {
        let worktimeTitle = "운영시간"
        let dayoffTitle = "휴무일"
        let titleFont = UIFont(name: "NanumSquareR", size: 15)
        let descFont = UIFont(name: "NanumSquareB", size: 15)
        
        var dayoffDesc = ""
        for off in vm.data.dayoff {
            let dayoffName = Weekday(rawValue: off)?.name ?? ""
            dayoffDesc += "\(dayoffName),"
        }
        
        if vm.data.dayoff.isEmpty { dayoffDesc = "없음" }
        else { _ = dayoffDesc.popLast() }
        
        // "운영시간: 00:00 - 00:00 휴무일: 일, 월..." 형식의 문자열 생성
//        let totalWorktimeStr = "\(worktimeTitle): \(data.worktime)  \(dayoffTitle): \(dayoffDesc)"
        
        // "운영시간: 00:00 - 00:00" 형식의 문자열 생성
        let totalWorktimeStr = "\(worktimeTitle): \(vm.data.worktime)   \(dayoffTitle): \(dayoffDesc)"
        let workTimeAttString = NSMutableAttributedString(string: totalWorktimeStr, attributes: [
          .font: titleFont!,
          .foregroundColor: UIColor.gray
        ])
        
        // "oo시 ~ oo시" 폰트 설정
        let descColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
        workTimeAttString.addAttributes([
          .font: descFont!,
          .foregroundColor: descColor
        ], range: NSRange(location: worktimeTitle.count + 2, length: vm.data.worktime.count))
        
//        workTime.attributedText = workTimeAttString
        
        // "일, 월..." 폰트 설정
        let range = totalWorktimeStr.range(of: "\(dayoffTitle): ")
        if let index = range?.upperBound.utf16Offset(in: totalWorktimeStr) {
            workTimeAttString.addAttributes([
              .font: descFont!,
              .foregroundColor: descColor
            ], range: NSRange(location: index, length: dayoffDesc.count))
            
            workTime.attributedText = workTimeAttString
        }
        
        workTime.attributedText = workTimeAttString
    }
    
    // MARK: - merits
    func setMerits() {
        guard vm.data.merits.count > 0 else { return }
        meritsBoard.isHidden = false
        
        let leadingSpace: CGFloat = 0           // 처음 생성되는 버튼과 화면 왼쪽끝의 거리
        let wordHorizontalInset: CGFloat = 10   // 버튼의 좌우 inset
        let wordSpace: CGFloat = 8              // 버튼과 버튼 사이의 거리(가로)
        let lineSpace: CGFloat = 4              // 버튼과 버튼 사이의 거리(세로)
        let wordHeight: CGFloat = 26            // 버튼 높이
        var x: CGFloat = leadingSpace           // 버튼의 x값
        var y: CGFloat = 10                     // 버튼의 y값
        
        for merit in vm.data.merits {
            // 버튼 생성
            let keyword = UIButton()
            _utils.setText(bold: .regular, size: 14, text: merit, button: keyword)
            keyword.sizeToFit()
            keyword.contentEdgeInsets = UIEdgeInsets(top: 0, left: wordHorizontalInset, bottom: 0, right: wordHorizontalInset)
            
            // 현재 버튼 위치 계산
            let keywordWidth = keyword.frame.width + (wordHorizontalInset * 2)
            let keywordMaxX = (x + keywordWidth + wordSpace)
            if keywordMaxX > board.frame.width - leadingSpace {     // 화면 밖(오른쪽)을 넘어가면 아랫줄의 처음 위치로 이동
                y += (keyword.frame.height + lineSpace)
                x = leadingSpace
            }
            
            // 버튼 세부사항 설정
            let keywordFrame = CGRect(x: x, y: y, width: keyword.frame.width + (wordHorizontalInset * 2), height: wordHeight)
            keyword.frame = keywordFrame
            keyword.layer.cornerRadius = wordHeight / 2
            keyword.backgroundColor = UIColor(red: 242/255, green: 123/255, blue: 87/255, alpha: 1)
            keyword.setTitleColor(.white, for: .normal)
            keyword.contentHorizontalAlignment = .center
            
            // 버튼 표시
            meritsBoard.addSubview(keyword)

            // 다음 버튼이 표시될 위치 계산
            x += (keywordFrame.width + wordSpace)
        }
        
        for constraint in meritsBoard.constraints {
            if constraint.firstAttribute == .height { constraint.constant = y + wordHeight; break }
        }
    }
    
    // MARK: - schedule
    func setSchedules() {
        // set title
        _utils.setText(bold: .bold, size: 19, text: "스케쥴", label: scheduleTitle)
        
        // set date
        startDate.configure(title: "보관시작", desc: "이후", pickcase: .storageStart)
        startDate.delegate = self
        endDate.configure(title: "보관종료", desc: "이전", pickcase: .storageEnd)
        endDate.delegate = self
        
        // create desc
        let leadingSpace: CGFloat = 30
        let desc = UILabel(frame: CGRect(x: leadingSpace, y: 0, width: descBoard.bounds.width - (leadingSpace * 2), height: descBoard.bounds.height))
        desc.numberOfLines = 0
        desc.font = UIFont(name: "NanumSquareR", size: 14)
        desc.textColor = .systemGray
        desc.text = "대략적인 보관 예정 시간을 입력해주세요."
        desc.sizeToFit()
        desc.frame.origin = CGPoint(x: (descBoard.bounds.width / 2) - (desc.frame.width / 2) + 10, y: (descBoard.bounds.height / 2) - (desc.frame.height / 2))
        descBoard.addSubview(desc)
        
        let descImgWidth: CGFloat = 20
        let descImg = UIImageView(frame: CGRect(x: desc.frame.origin.x - (descImgWidth + 10), y: desc.frame.origin.y, width: descImgWidth, height: desc.frame.height))
        descImg.image = UIImage(systemName: "exclamationmark.circle.fill")
        descImg.tintColor = .label
        descImg.contentMode = .scaleAspectFit
        descBoard.addSubview(descImg)
    }

    // MARK: - luggages
    func setLuggages() {
        
        _utils.setText(bold: .bold, size: 19, text: "짐정보", label: lugTitle)
        lugSmall.configure(title: "작은짐", desc: "(Small)")
        lugMedium.configure(title: "중간짐", desc: "(Medium)")
        lugLarge.configure(title: "큰짐", desc: "(Large)")
        lugXLarge.configure(title: "대형짐", desc: "(Extra Large)")
        
        _utils.setText(bold: .regular, size: 14, text: "요금확인", color: .white, button: cost)
        cost.backgroundColor = UIColor(red: 242/255, green: 123/255, blue: 87/255, alpha: 1)
        cost.layer.cornerRadius = cost.frame.height / 2
        cost.titleLabel?.textColor = .white
        cost.tintColor = .white
        cost.addTarget(self, action: #selector(self.onCost(_:)), for: .touchUpInside)
    }
    
    // MARK: - pictures
    func setPictures() {
        _utils.setText(bold: .regular, size: 14, text: "보관 할 짐 사진을 등록해 주세요. (사고 방지를 위해 필수 등록)", label: pictureTitle)
        
        // create picture cell
        for i in 0 ..< vm.maxPictureCount {
            let pictureCell = RegStoragePictureCell()
            let isMain = (i == 0)
            pictureCell.configure(isMain: isMain)
            pictureCell.updateMainStatus(isMain: false)
            pictureStack.addArrangedSubview(pictureCell)
            pictureCell.widthAnchor.constraint(equalToConstant: pictureCellWidth).isActive = true
            pictureCell.delegate = self
//            pictureCell.multipleSelection = true
            pictureCells.append(pictureCell)
        }
        
        // load pictures
        for (i, pictureData) in vm.pictures.enumerated() {
            if i >= pictureCells.count { continue }
            pictureCells[i].setImageWithUrl(url: pictureData.url, registered: false, seq: pictureData.seq)
        }
        
        // set picture count
        pictureCount.text = "\(vm.pictures.count) / \(vm.maxPictureCount)"
    }
    
    func insertPicture(img: UIImage) {
        // 비어있는 cell 중 첫번째에 사진을 추가함
        for cell in pictureCells {
            if cell.isEmpty {
                cell.setImageWithImage(image: img, registered: true, seq: cell.seq)
                break
            }
        }
        
        updatePictureCount()
    }
    
    // 사진 개수 text 갱신
    func updatePictureCount() {
        
        var currentPictureCount: Int = 0
        for cell in pictureCells {
            if false == cell.isEmpty { currentPictureCount += 1 }
        }
        
        pictureCount.text = "\(currentPictureCount) / \(vm.maxPictureCount)"
    }
    
    /// 짐 보관 시간이 유효한지 확인
    func checkStorageTime() -> Bool {
        var storageTime = vm.data.worktime
        storageTime = storageTime.components(separatedBy: ["."]).joined()
    
        let workTimeArr = storageTime.split(separator: "~").map { (value) -> String in
            return String(value)
        }
        
        var workStartTime = ""
        if workTimeArr.count > 0 { workStartTime = workTimeArr[0] }
        workStartTime = workStartTime.components(separatedBy: [":"]).joined()
        
        var workEndTime = ""
        if workEndTime.count > 1 { workEndTime = workTimeArr[1] }
        workEndTime = workEndTime.components(separatedBy: [":"]).joined()
        
        var storageStartTime = startDate.getTimeString()
        storageStartTime = storageStartTime.components(separatedBy: [":"]).joined()
        var storageEndTime = endDate.getTimeString()
        storageEndTime = storageEndTime.components(separatedBy: [":"]).joined()
        
        let workStart: Int = Int(workStartTime) ?? 00
        let workEnd: Int = Int(workEndTime) ?? 00
        let storageStart: Int = Int(storageStartTime) ?? 00
        let storageEnd: Int = Int(storageEndTime) ?? 00
        
        if storageStart < workStart { return false }        // [짐 맡기는 시간]이 [영업 시작 시간] 이전이면 맡길 수 없음
        if storageEnd > workEnd { return false }            // [짐 찾는 시간]이 [영업 종료 시간] 이후면 맡길 수 없음
        return true
    }
    
    /// 짐 보관 날짜가 유효한지 확인
    func checkStorageDate() {
        
    }
    
    func createSimpleAlert(msg: String) {
        let alert = _utils.createSimpleAlert(title: "주문서 확인", message: msg, buttonTitle: _strings[.ok])
        self.present(alert, animated: true)
    }
    
    // MARK: - comment & keyboard
    func setComment() {
        _utils.setText(bold: .bold, size: 16, text: "요청사항", label: commentTitle)
        _utils.setText(bold: .regular, size: 14, text: "", field: commentField)
        commentField.placeholder = "잘 보관해주세요."
        commentField.delegate = self
    }
    
    @objc func keyboardWillShow() {
        if self.board.frame.origin.y < 0 { return }
        board.translatesAutoresizingMaskIntoConstraints = true
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.board.frame.origin.y -= 250
        })
    }

    @objc func keyboardWillHide() {
        board.translatesAutoresizingMaskIntoConstraints = false
        UIView.animate(withDuration: 0.30, animations: { () -> Void in
            self.board.frame.origin.y += 250
        })
    }
}

// MARK: - Actions
extension StorageConditionsVc {
    @objc func onCost(_ sender: UIButton) {
        let vc = StorageCostVc()
        vc.vm = vm
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
    
    @IBAction func onAddPicture(_ sender: UIGestureRecognizer) {
        let itemCamera = MyUtils.AlertHandler(title: _strings[.camera], handler: self.accessCamera)
        let itemAlbum = MyUtils.AlertHandler(title: _strings[.photoAlbum], handler: self.accessGallery)
        let alert = _utils.createAlert(title: "", message: _strings[.alertNeedHorizontalPicture], handlers: [itemCamera, itemAlbum], style: .actionSheet)
        
        if let topVc = _utils.topViewController() {
            if UIDevice.current.userInterfaceIdiom == .pad { //디바이스 타입이 iPad일때
                if let popoverController = alert.popoverPresentationController { // ActionSheet가 표현되는 위치를 저장해줍니다.
                    popoverController.sourceView = topVc.view
                    popoverController.sourceRect = CGRect(x: topVc.view.bounds.midX, y: topVc.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                    topVc.present(alert, animated: true, completion: nil)
                }
            } else {
                topVc.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func onGo(_ sender: UIButton) {
        
        // 날짜 입력 확인
        if startDate.needEnter || endDate.needEnter { createSimpleAlert(msg: "스케쥴을 입력해주세요."); return }
        let startDateStr = "\(startDate.getFullString())"
        let endDateStr = "\(endDate.getFullString())"
        
        // 보관 시간 유효성 확인
//        let availableTime = checkStorageTime()
//        guard availableTime else { createSimpleAlert(msg: "짐 맡기는 시간을 보관소의 영업시간 내로 설정해야합니다."); return }
        
        // 짐 개수 입력 확인
        let s: Int = lugSmall.getCount()
        let m: Int = lugMedium.getCount()
        let l: Int = lugLarge.getCount()
        let xl: Int = lugXLarge.getCount()
        if s + m + l + xl <= 0 { createSimpleAlert(msg: "짐 정보를 입력해주세요."); return }
        
        // 사진 등록 확인
        var imgDatas: [Data] = []
        for cell in pictureCells {
            guard cell.registered else { continue }
            guard let imgData = cell.getImageData() else { continue }
            imgDatas.append(imgData)
        }
        
        if imgDatas.count == 0 { createSimpleAlert(msg: "최소 1개의 짐 사진을 등록해주세요."); return }
            
        // 가격
        let cost = vm.getCost(startDate: startDateStr, endDate: endDateStr, luggages: (s, m, l, xl))
        if cost.isEmpty || cost == "0" { createSimpleAlert(msg: "올바른 가격이 아닙니다. 다시 시도해주세요."); return }
        
        var purchasingData = PurchasingData(masterSeq: vm.data.masterSeq,
                                            driverSeq: "0",
                                            storageSeq: vm.data.seq,
                                            userSeq: _user.seq,
                                            vehicleType: "001",
                                            orderKind: OrderCase.storage.type,
                                            usingStorage: UsingStorageCase.all.rawValue,
                                            payMethod: "001",
                                            startAddr: vm.data.address,
                                            startDate: startDateStr,
                                            startTime: "\(startDate.getTimeString())",
                                            endAddr: vm.data.address,
                                            endDate: endDateStr,
                                            endTime: "\(endDate.getTimeString())",
                                            userName: _user.name,
                                            userPhone: _user.contact,
                                            comment: commentField.text ?? "",
                                            startLat: vm.data.lat,
                                            startLng: vm.data.lng,
                                            endLat: vm.data.lat,
                                            endLng: vm.data.lng,
                                            luggages: (s, m, l, xl),
                                            luggagePictures: imgDatas,
                                            cost: cost)
        
        purchasingData.bizName = vm.data.name
        
        // 결제 데이터(PurchasingData) 생성 후 주문 화면으로 전달
        let vc = StorageOrderVc()
        vc.purchasingData = purchasingData
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

// MARK: - MyNaviDelegate
extension StorageConditionsVc: MyNaviDelegate {
    func onBack() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false)
    }
}

// MARK: - OrderDatePickerViewDelegate
extension StorageConditionsVc: OrderDatePickerViewDelegate {
    func onMinimumDateSelected(minimumDate: Date?) {
        endDate.setMinimunDate(minimumDate: minimumDate)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension StorageConditionsVc: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        _utils.topViewController()?.present(picker, animated: true, completion: nil)
    }
    
    func openGallery() {
//        if mulitpleSelection {
//            let phPickerVc = PHPickerViewController(configuration: phConfiguration)
//            phPickerVc.delegate = self
//            _utils.topViewController()?.present(phPickerVc, animated: true)
//        } else {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            _utils.topViewController()?.present(picker, animated: true, completion: nil)
//        }
    }
    
    // Camera 접근권한 확인
    func accessCamera(alertController: UIAlertController) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { status in
            if status {
                DispatchQueue.main.async { self.openCamera() }
            } else {}
        }
    }
        
    // Gallery 접근권한 확인
    func accessGallery(alertController: UIAlertController!) {
        let accessLevel: PHAccessLevel = .readWrite
        let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: accessLevel)
        switch authorizationStatus {
        case.authorized, .limited: openGallery()
        default:
            PHPhotoLibrary.requestAuthorization(for: accessLevel) { authorizationStatus in
                switch authorizationStatus {
                case .limited, .authorized: self.openGallery()
                default:
                    DispatchQueue.main.async {
                        let alert = _utils.createSimpleAlert(title: _strings[.photo], message: _strings[.needPhotoAccessPermission], buttonTitle: _strings[.ok])
                        _utils.topViewController()?.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var tempThumb: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            tempThumb = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            tempThumb = originalImage
        }
        
        guard let thumb = tempThumb else { return }
        picker.dismiss(animated: false, completion: { () -> Void in
            
            var cropVc: CropViewController!
            if self.cropRectRatio > 0 {
                var config = Mantis.Config()
                config.ratioOptions = [.custom]
                config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: self.cropRectRatio)
                cropVc = Mantis.cropViewController(image: thumb, config: config)
            } else {
                cropVc = Mantis.cropViewController(image: thumb)
            }
            
            cropVc.delegate = self
            cropVc.modalPresentationStyle = .fullScreen
            _utils.topViewController()?.present(cropVc, animated: true)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - CropViewControllerDelegate
extension StorageConditionsVc: CropViewControllerDelegate {
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {}
    
    func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {}
    
    func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {}
    
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        cropViewController.dismiss(animated: true, completion: nil)
        insertPicture(img: cropped)
//        delegate?.didCrop?(croppedImg: cropped)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - RegStoragePictureCellDelegate
extension StorageConditionsVc: RegStoragePictureCellDelegate {
    func didCrop(croppedImg: UIImage) {
        insertPicture(img: croppedImg)
    }
    
    func deleted(seq: String) {
        vm.deletePicture(seq: seq)
        updatePictureCount()
    }
    
    func selectedMultipleImage(imgs: [UIImage]) {
        for img in imgs {
            insertPicture(img: img)
        }
    }
    
    func selectedImage(img: UIImage) {
        insertPicture(img: img)
    }
}

// MARK: - UITextFieldDelegate
extension StorageConditionsVc: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        keyboardWillShow()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        keyboardWillHide()
    }
}
