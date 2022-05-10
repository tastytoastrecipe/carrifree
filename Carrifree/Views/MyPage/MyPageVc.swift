//
//  MyPageVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/21.
//
//
//  💬 MyPageVc
//  내정보 화면
//


import UIKit
import Photos
import Mantis

class MyPageVc: UIViewController {

    @IBOutlet weak var profileTitle: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var contact: UILabel!
    @IBOutlet weak var auth: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var emailDesc: UILabel!
    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var giftTitle: UILabel!
    @IBOutlet weak var reviewsTitle: UILabel!
    @IBOutlet weak var settingsTitle: UILabel!
    @IBOutlet weak var notificationsTitle: UILabel!
    @IBOutlet weak var helpTitle: UILabel!
    @IBOutlet weak var versionTitle: UILabel!
    @IBOutlet weak var versionSimple: UILabel!
    @IBOutlet weak var versionDetail: UILabel!
    @IBOutlet weak var signoutTitle: UILabel!
    

    let cropRectRatio: Double = 1.0 / 1.0
    var vm: MyPageVm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefault()
        NaviEditor.editNavi(scene: .mypage, callbacks: [])
        vm = MyPageVm()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if false == _utils.createIndicator() { return }
        
        vm.getMyInfo() { (success, msg) in
            _utils.removeIndicator()
            guard success else {
                let alert = _utils.createSimpleAlert(title: "내 정보", message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
                return
            }
            
            self.configure()
        }
    }
    
    func setDefault() {
        profileImg.layer.cornerRadius = profileImg.frame.height / 2
        _utils.setText(bold: .regular, size: 20, text: "프로필 사진을 등록해주세요", label: profileTitle)
        _utils.setText(bold: .extraBold, size: 17, text: "", label: name)
        _utils.setText(bold: .extraBold, size: 17, text: "", label: id)
        _utils.setText(bold: .regular, size: 17, text: "", label: contact)
        _utils.setText(bold: .regular, size: 15, text: "재인증", color: _symbolColor, button: auth)
        auth.layer.borderColor = auth.titleLabel?.textColor.cgColor
        auth.layer.borderWidth = 1
        _utils.setText(bold: .regular, size: 15, text: "", field: email)
        email.placeholder = _strings[.alertNeedEmail]
        _utils.setText(bold: .regular, size: 14, text: "이메일을 등록하시면 휴대번호가 변경되어도 계정 정보를 쉽게 찾을 수 있고, 주문/결제 정보 메일이 발송 됩니다.", label: emailDesc)
        _utils.setText(bold: .regular, size: 17, text: "카드등록", label: cardTitle)
        _utils.setText(bold: .regular, size: 17, text: "선물함", label: giftTitle)
        _utils.setText(bold: .regular, size: 17, text: "나의 리뷰", label: reviewsTitle)
        _utils.setText(bold: .regular, size: 17, text: "환경설정", label: settingsTitle)
        _utils.setText(bold: .regular, size: 17, text: "알림", label: notificationsTitle)
        _utils.setText(bold: .regular, size: 17, text: "고객센터", label: helpTitle)
        _utils.setText(bold: .extraBold, size: 17, text: "버전정보", label: versionTitle)
        _utils.setText(bold: .regular, size: 17, text: "", label: versionSimple)
        _utils.setText(bold: .regular, size: 17, text: "", color: _symbolColor, label: versionDetail)
        _utils.setText(bold: .regular, size: 17, text: _strings[.signOut], label: signoutTitle)
    }
    
    func configure() {
        if nil == vm { return }
        name.text = vm.name
        id.text = vm.id
        contact.text = getPhoneText(phone: vm.contact)
        email.text = vm.email
        profileImg.loadImage(url: vm.profile)
        versionSimple.text = _utils.getAppVersion()
        versionDetail.text = _utils.getAppInfo()
    }
    
    /// 폰번호에 구분자 추가
    func getPhoneText(phone: String) -> String {
        var phone = phone
        
        // 폰번호가 10자리일 경우 '000-000-0000' 형식의 문자열을 만든다
        if phone.count == 10 {
            // - 표시
            let firstIndex = phone.index(phone.startIndex, offsetBy: 3)
            phone.insert("-", at: firstIndex)
            
            let secondIndex = phone.index(phone.startIndex, offsetBy: 7)
            phone.insert("-", at: secondIndex)
        }
        // 폰번호가 11자리 이상일 경우 '000-0000-0000' 형식의 문자열을 만든다
        else if phone.count > 10 {
            // - 표시
            let firstIndex = phone.index(phone.startIndex, offsetBy: 3)
            phone.insert("-", at: firstIndex)
            
            let secondIndex = phone.index(phone.startIndex, offsetBy: 8)
            phone.insert("-", at: secondIndex)
        }
        
        phone = "+82 \(phone)"
        return phone
    }
   
}

// MARK: - Actions
extension MyPageVc {
    func onSave() {
        let emailStr = email.text ?? ""
        vm.setMyinfo(email: emailStr) { (_, msg) in
            let alert = _utils.createSimpleAlert(title: "내 정보", message: msg, buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension MyPageVc: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        _utils.topViewController()?.present(picker, animated: true, completion: nil)
    }
    
    func openGallery() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        _utils.topViewController()?.present(picker, animated: true, completion: nil)
    }
    
    // Camera 접근권한 확인
    func accessCamera(alertController: UIAlertController) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { status in
            if status {
                DispatchQueue.main.async { self.openCamera() }
            } else {
                DispatchQueue.main.async {
                    let ok = _utils.createAlertAction(title: _strings[.ok]) { (_) in _utils.goToSettingsCarrifree() }
                    let alert2 = _utils.createAlert(title: _strings[.photo], message: _strings[.needCameraAccessPermission], handlers: [ok], style: .alert, addCancel: true)
                    self.present(alert2, animated: true)
                }
            }
        }
    }
        
    // Gallery 접근권한 확인
    func accessGallery(alertController: UIAlertController) {
        // ios 14+
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
                        let ok = _utils.createAlertAction(title: _strings[.ok]) { (_) in _utils.goToSettingsCarrifree() }
                        let alert2 = _utils.createAlert(title: _strings[.photo], message: _strings[.needPhotoAccessPermission], handlers: [ok], style: .alert, addCancel: true)
                        self.present(alert2, animated: true)
                    }
                }
            }
        }
        /*
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .authorized {
            openGallery()
        } else {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    DispatchQueue.main.async { self.openGallery() }
                } else {
                    
                }
            })
        }
        */
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
    
    func moveScene(_ destination: UIViewController) {
        destination.modalPresentationStyle = .fullScreen

        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.present(destination, animated: false, completion: nil)
    }
}

// MARK: - Actions
extension MyPageVc {
    @IBAction func onProfile(_ sender: UIGestureRecognizer) {
        _log.log("onProfile")
        let itemCamera = MyUtils.AlertHandler(title: MyStrings.camera.rawValue, handler: self.accessCamera)
        let itemAlbum = MyUtils.AlertHandler(title: MyStrings.photoAlbum.rawValue, handler: self.accessGallery)
        let alert = MyUtils.shared.createAlert(handlers: [itemCamera, itemAlbum], style: .actionSheet)
        
        if let topVc = MyUtils.shared.topViewController() {
            if UIDevice.current.userInterfaceIdiom == .pad {                        //디바이스 타입이 iPad일때
                if let popoverController = alert.popoverPresentationController {    // ActionSheet가 표현되는 위치를 저장해줍니다.
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
    
    @IBAction func onAuth(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            let vc = ImpVerificationVc()
            vc.delegate = self
            vc.modalPresentationStyle = .popover
            self.present(vc, animated: true)
        }
        _log.log("onAuth")
    }
    
    @IBAction func onCard(_ sender: UIGestureRecognizer) {
        _log.log("onCard")
        
        let alert = _utils.createSimpleAlert(title: "준비중", message: "'카드등록' 서비스는 현재 준비중입니다.", buttonTitle: _strings[.ok])
        self.present(alert, animated: true)
    }
    
    @IBAction func onGift(_ sender: UIGestureRecognizer) {
        _log.log("onGift")
        
        let alert = _utils.createSimpleAlert(title: "준비중", message: "'선물함' 서비스는 현재 준비중입니다.", buttonTitle: _strings[.ok])
        self.present(alert, animated: true)
    }
    
    @IBAction func onReviews(_ sender: UIGestureRecognizer) {
        _log.log("onReviews")
        
        let alert = _utils.createSimpleAlert(title: "준비중", message: "'나의 리뷰' 서비스는 현재 준비중입니다.", buttonTitle: _strings[.ok])
        self.present(alert, animated: true)
    }
    
    @IBAction func onSettings(_ sender: UIGestureRecognizer) {
        _log.log("onSettings")
        moveScene(SettingsVc())
    }
    
    @IBAction func onNotification(_ sender: UIGestureRecognizer) {
        _log.log("onNotification")
        moveScene(NotificationsVc())
    }
    
    @IBAction func onHelp(_ sender: UIGestureRecognizer) {
        _log.log("onHelp")
        moveScene(HelpVc())
    }
    
    @IBAction func onVersion(_ sender: UIGestureRecognizer) {
        _log.log("onVersion")
    }
    
    @IBAction func onSignout(_ sender: UIGestureRecognizer) {
        vm.signout() { (success, msg) in
            if success {
                let alert = _utils.createSimpleAlert(title: _strings[.signOut], message: msg, buttonTitle: _strings[.ok], handler: { (_) in
                    _user.removeData()
                    self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                })
                self.present(alert, animated: true)
            } else {
                let alert = _utils.createSimpleAlert(title: _strings[.signOut], message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
            }
        }
    }
}

// MARK:- CropViewControllerDelegate
extension MyPageVc: CropViewControllerDelegate {
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {}
    
    func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {}
    
    func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {}
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        cropViewController.dismiss(animated: true) {
            guard let imgData = cropped.jpegData(compressionQuality: 0.7) else { return }
            
            if false == _utils.createIndicator() { return }
            
            self.vm.uploadProfileImage(imgData: imgData) { (success, msg) in
                _utils.removeIndicator()
                if success { self.profileImg.image = cropped }
                else {
                    let alert = _utils.createSimpleAlert(title: "내 정보", message: msg, buttonTitle: _strings[.ok])
                    self.present(alert, animated: true)
                }
            }
        }
        
        
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - ImpVerificationDelegate
extension MyPageVc: ImpVerificationDelegate {
    func disappear() {
        let phone = ImpRequest.shared.phone
        guard phone.count > 0 else { return }
        contact.text = getPhoneText(phone: phone)
        
        // 폰번호 저장
        vm.setPhone(phone: phone) { (success, msg) in
            guard success else {
                let alert = _utils.createSimpleAlert(title: "내 정보", message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
                return
            }
        }
    }
}
