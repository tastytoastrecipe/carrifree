//
//  RegStoragePhotoCell.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/09/15.
//

import UIKit
import Photos
import Mantis
import PhotosUI

@objc protocol RegStoragePictureCellDelegate {
    @objc optional func deleted(seq: String)
    @objc optional func didCrop(croppedImg: UIImage)
    @objc optional func selectedMultipleImage(imgs: [UIImage])
    @objc optional func selectedImage(img: UIImage)
}

class RegStoragePictureCell: UIView {
    
    let emptyPhoto: String = "img-empty-picture"
    
    var imgView: UIImageView!
    var deleteBtn: UIView!
    var mainLab: UILabel!
    
    var isEmpty: Bool = true
    var isMain: Bool = false
    var registered: Bool = false                // 이미지가 새로 등록되었는지 여부
    var seq: String = ""                        // 사진 seq
    var cropRectRatio: Double = 16.0 / 10.0     // crop rect 가로 x 세로 설정 (ex. 16:9 비율이면 16.0 / 9.0)
    var multipleSelection: Bool = false
    var phConfiguration: PHPickerConfiguration!
    var delegate: RegStoragePictureCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:))))
        
        imgView = UIImageView(image: UIImage(named: emptyPhoto))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        imgView.tintColor = .systemGray5
        self.addSubview(imgView)
        NSLayoutConstraint.activate([
            imgView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            imgView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            imgView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            imgView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
        ])
        
        let deleteBtnWidth: CGFloat = 22
        deleteBtn = UIView()
        deleteBtn.translatesAutoresizingMaskIntoConstraints = false
        deleteBtn.backgroundColor = .white
        deleteBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onDelete(_:))))
        self.addSubview(deleteBtn)
        NSLayoutConstraint.activate([
            deleteBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
            deleteBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1),
            deleteBtn.widthAnchor.constraint(equalToConstant: deleteBtnWidth),
            deleteBtn.heightAnchor.constraint(equalToConstant: deleteBtnWidth)
        ])
        deleteBtn.layer.cornerRadius = deleteBtnWidth / 2
        
        let deleteBtnImgSpace: CGFloat = 1
        let deleteBtnImgWidth: CGFloat = deleteBtnWidth - (deleteBtnImgSpace * 2)
        let deleteBtnImg = UIImageView(frame: CGRect(x: deleteBtnImgSpace, y: deleteBtnImgSpace, width: deleteBtnImgWidth, height: deleteBtnImgWidth))
        deleteBtnImg.image = UIImage(systemName: "minus.circle.fill")
        deleteBtnImg.contentMode = .scaleAspectFill
        deleteBtnImg.tintColor = .systemGray
        deleteBtn.addSubview(deleteBtnImg)
        
        deleteBtn.isHidden = true
        self.clipsToBounds = true
        self.layer.cornerRadius = 8
    }
    
    func configure(isMain: Bool, seq: String = "") {
        configure()
        setMain(isMain: isMain)
    }
    
    func setMain(isMain: Bool) {
        self.isMain = isMain
        updateMainStatus(isMain: isMain)
    }
    
    // '메인' UI 표시 상태 설정
    func updateMainStatus(isMain: Bool) {
        if isMain {
            if nil == mainLab {
                mainLab = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width - 16, height: 30))
                mainLab.translatesAutoresizingMaskIntoConstraints = false
                mainLab.backgroundColor = UIColor(red: 161/255, green: 232/255, blue: 165/255, alpha: 1)
                mainLab.text = "  대표  "
                mainLab.textColor = .white
                mainLab.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                mainLab.layer.cornerRadius = 10
                mainLab.clipsToBounds = true
                self.addSubview(mainLab)
                NSLayoutConstraint.activate([
                    mainLab.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
                    mainLab.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
                    mainLab.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),
                    mainLab.heightAnchor.constraint(equalToConstant: 24)
                ])
            }
        } else {
            if nil != mainLab { mainLab.isHidden = true }
        }
        
        if nil != mainLab { mainLab.isHidden = !isMain }
    }
    
    func setImageWithUrl(url: String, registered: Bool, seq: String, deleteBtnHidden: Bool = false) {
        self.seq = seq
        
        imgView.loadImage(url: url) {
            DispatchQueue.main.async {
                if self.imgView.image == nil {
                    self.delete()
                } else {
                    self.setEmptyStatus(empty: false)
                    self.deleteBtn.isHidden = deleteBtnHidden
                }
            }
        }
        self.registered = registered
    }
    
    func setImageWithData(imgData: Data?, registered: Bool, seq: String, deleteBtnHidden: Bool = false) {
        guard let imgData = imgData else { delete(); return }
        
        self.seq = seq
        imgView.image = UIImage(data: imgData)
        setEmptyStatus(empty: false)
        deleteBtn.isHidden = deleteBtnHidden
        self.registered = registered
    }
    
    func setImageWithImage(image: UIImage?, registered: Bool, seq: String, deleteBtnHidden: Bool = false) {
        self.seq = seq
        imgView.image = image
        setEmptyStatus(empty: false)
        deleteBtn.isHidden = deleteBtnHidden
        self.registered = registered
    }
    
    func setEmptyStatus(empty: Bool) {
        isEmpty = empty
        if nil != deleteBtn { deleteBtn.isHidden = empty }
        
        if empty {
            imgView.image = UIImage(named: emptyPhoto)
            imgView.contentMode = .scaleAspectFill
            imgView.tintColor = .systemGray5
        } else {
            imgView.contentMode = .scaleAspectFill
            self.layer.borderWidth = 0
        }

    }
    
    func delete() {
        setEmptyStatus(empty: true)
    }
    
    func getImageData() -> Data? {
        return imgView.image?.jpegData(compressionQuality: 0.7)
    }
    
    /// 서버 주소를 적용한 url 반환
    func getRequestUrl(body: String) -> String {
        var server: String = ""
        if releaseMode {
            server = _identifiers[.liveServer]
        } else {
            server = _identifiers[.devServer]
        }
        
        return "\(server)\(body)"
    }
}

// MAKR:- Actions
extension RegStoragePictureCell {
    @objc private func onDelete(_ sender: UIGestureRecognizer) {
        if isEmpty { return }
        setEmptyStatus(empty: true)
        delegate?.deleted?(seq: seq)
    }
    
    @objc func onTap(_ sender: UIGestureRecognizer) {
        if multipleSelection {
            if nil == phConfiguration {
                phConfiguration = PHPickerConfiguration()
                phConfiguration.filter = .images
                phConfiguration.selectionLimit = 10
            }
            accessGallery(alertController: nil)
            
        } else {
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
        
    }
}


// MARK:- UIImagePickerControllerDelegate
extension RegStoragePictureCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCamera() {
        DispatchQueue.main.async {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            _utils.topViewController()?.present(picker, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        DispatchQueue.main.async {
            if self.multipleSelection {
                let phPickerVc = PHPickerViewController(configuration: self.phConfiguration)
                phPickerVc.delegate = self
                _utils.topViewController()?.present(phPickerVc, animated: true)
            } else {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .photoLibrary
                _utils.topViewController()?.present(picker, animated: true, completion: nil)
            }
        }
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

// MARK:- CropViewControllerDelegate
extension RegStoragePictureCell: CropViewControllerDelegate {
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {}
    
    func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {}
    
    func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {}
    
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        cropViewController.dismiss(animated: true, completion: nil)
//        setImageWithImage(image: cropped)
        delegate?.didCrop?(croppedImg: cropped)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension RegStoragePictureCell: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // dismiss picker
        picker.dismiss(animated: true)
        
        // 선택된 이미지 delegate로 전달
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                guard let image = object as? UIImage else { _log.log("picture err 01"); return }
                guard let lowQualityData = image.jpegData(compressionQuality: 0.7) else { _log.log("picture err 02"); return }
                guard let lowQualityImg = UIImage(data: lowQualityData) else { _log.log("picture err 03"); return }
                
                DispatchQueue.main.async {
                    self.delegate?.selectedImage?(img: lowQualityImg)
                }
            })
        }
        
    }
}
