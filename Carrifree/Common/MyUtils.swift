//
//  MyUtils.swift
//  CarrifreeUser
//
//  Created by orca on 2020/10/11.
//  Copyright © 2020 plattics. All rights reserved.
//

//import Foundation
import UIKit
import MapKit
import SafariServices
//import CryptoSwift
import CryptoKit
import EventKit

var _utils: MyUtils = {
    return MyUtils.shared
}()

class MyUtils: NSObject {
    
    class AlertHandler {
        typealias ParamAlertController = ((UIAlertController) -> Void)?
        var title: String = ""
        var titleColor: UIColor = .systemBlue
        var handler: ParamAlertController = nil
        
        init(title: String, titleColor: UIColor = UIColor.systemBlue, handler: ParamAlertController = nil) {
            self.title = title
            self.titleColor = titleColor
            self.handler = handler
        }
    }
    
    static let shared: MyUtils = MyUtils()
    
    var animatedObject: UIView! = nil
    var animatedObjectOriginalPos: CGPoint = CGPoint.zero
    var animatedConstraint: NSLayoutConstraint! = nil
    var animatedContraintOriginalConstant: CGFloat = 0
    
    var indicator: UIActivityIndicatorView! = nil
    
    private override init() {
    }
    
    // MARK: - Home button
    var existHomeButton: Bool {
        if #available(iOS 11.0, *), let keyWindow = appKeyWindow, keyWindow.safeAreaInsets.bottom > 0 {
            return false
        }
        return true
    }
    
    // MARK: - Get Keywindow
    var appKeyWindow: UIWindow? {
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    }
    
    // MARK: - Get Current Locale
    var currentLocail: Locale {
        let locale = Locale(identifier: NSLocale.preferredLanguages[0])
        return locale
    }
    
    // MARK: - Remove Delimiter From String
    func removeDelimiter(str: String?) -> String {
        guard var string = str else { return str ?? "" }
        string.removeAll(where: { $0 == "," })
        return string
    }
    
    // MARK: - Get Delimiter String
    func getDelimiter(str: String?) -> String {
        guard var string = str else { return str ?? "" }
        
        string.removeAll(where: { $0 == "," })
        let int = Int(string) ?? 0
        return int.delimiter
    }
    
    // MARK: - Get Number From Delimiter
    func getIntFromDelimiter(str: String?) -> Int {
        guard var string = str else { return 0 }
        
        string.removeAll(where: { $0 == "," })
        let value = Int(string) ?? 0
        return value
    }
    
    func getFloatFromDelimiter(str: String?) -> Float {
        guard var string = str else { return 0 }
        
        string.removeAll(where: { $0 == "," })
        let value = Float(string) ?? 0
        return value
    }
    
    func getStringFromDelemiter(str: String?) -> String {
        guard var string = str else { return "" }
        
        string.removeAll(where: { $0 == "," })
        return string
    }
    
    // MARK: - Draw dotted line
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView, thickness: CGFloat = 1, pattern: (dash: NSNumber, gap: NSNumber) = (4, 2), color: UIColor = UIColor.systemGray4) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = thickness
        shapeLayer.lineDashPattern = [pattern.dash, pattern.gap] // 4 is the length of dash, 2 is length of the gap.
        
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }
    
    // MARK: - Alert
    // Alert 생성
    func createAlert(title: String = "", message: String = "", handlers: [AlertHandler], style: UIAlertController.Style, addCancel: Bool = true) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.title = title.isEmpty ? nil : title
        alert.message = message.isEmpty ? nil : message
        
        for item in handlers {
            let action = UIAlertAction(title: item.title, style: .default, handler: { _ in item.handler?(alert) })
            action.setValue(item.titleColor, forKey: "titleTextColor")
            alert.addAction(action)
        }
        
        if addCancel {
            let cancel = UIAlertAction(title: _strings[.cancel], style: .cancel, handler: nil)
            alert.addAction(cancel)
        }

        return alert
    }
    
    // AlertAction 생성
    func createAlertAction(title: String, titleColor: UIColor = UIColor.systemBlue, handler: ((UIAlertController) -> Void)? = nil) -> AlertHandler {
        let action = AlertHandler(title: title, titleColor: titleColor, handler: handler)
        return action
    }
    
    // 간단한 Alert 생성 (버튼 1개만 있는)
    func createSimpleAlert(title: String, message: String, buttonTitle: String, handler: ((UIAlertController) -> Void)? = nil)  -> UIAlertController {
        let action = createAlertAction(title: buttonTitle, handler: handler)
        let alert = createAlert(title: title, message: message, handlers: [action], style: .alert, addCancel: false)
        return alert
    }
    
    
    // MARK: - Go to Carrifree Settings
    func goToSettingsCarrifree() {
        // 캐리프리앱 설정 화면으로 이동
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) }
    }
    
    // MARK: - Top ViewController
    func topViewController() -> UIViewController? {
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.topMostViewController()
    }
    
    // MARK: - 주소 parsing
    func parseAddress(pin: MKPlacemark, nameInclude: Bool = false) -> String {
        var name = ""
        if nameInclude {
            name = pin.name ?? ""
            if false == name.isEmpty {
                name = "  (\(name))"
            }
        }
        
        let admin = pin.administrativeArea ?? ""
        let locality = pin.locality ?? ""
        let thoroughfare = pin.thoroughfare ?? ""
        let subThoroughfare = pin.subThoroughfare ?? ""
        let countryCode = pin.countryCode ?? ""
        
        var address = ""
        if countryCode == "KR" {
            address = "\(admin) \(locality) \(thoroughfare) \(subThoroughfare)\(name)"
        } else {
            // US
            let firstSpace = (pin.subThoroughfare != nil &&  pin.thoroughfare != nil) ? " " : ""
            let comma = (pin.subThoroughfare != nil && pin.thoroughfare != nil) &&
                (pin.subAdministrativeArea != nil && pin.administrativeArea != nil) ? ", " : ""
            let secondSpace = (pin.subAdministrativeArea != nil && pin.administrativeArea != nil) ? ", " : ""
            address = String(format: "%@%@%@%@%@%@%@%@",
                                     subThoroughfare,
                                     firstSpace,
                                     thoroughfare,
                                     comma,
                                     locality,
                                     secondSpace,
                                     admin,
                                     name)
            
            // US 외의 다른 나라들은 그 나라의 주소 표기법에 따라 새로 구현해야함 ..
        }
        
        return address
    }
    
    
                             
    func presentSafari(presneingViewController vc: UIViewController, url urlString: String, animated: Bool, completion: (() -> Void)? = nil) {
        guard let url = URL(string: urlString) else { return }
        let safariViewController = SFSafariViewController(url: url)
        vc.present(safariViewController, animated: true, completion: completion)
    }
    
    // MARK: - Keyboard Animation
    // 애니메이션 옵저버 등록
    func registerForKeyboardNotifications(animatedObject: UIView? = nil) {
        if animatedObject == nil {
            self.animatedObject = topViewController()?.view
        } else {
            self.animatedObject = animatedObject
        }
        
        animatedObjectOriginalPos = self.animatedObject.frame.origin
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // 애니메이션 옵저버 등록 해제
    func unregisterForKeyboardNotifications() {
        animatedConstraint = nil
        animatedObject = nil
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // 키보드 높이만큼 특정 view 위치 이동
    @objc func keyboardWillShow(note: NSNotification) {
        guard animatedObject != nil else { return }
        
        if let keyboardRect = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let targetY = keyboardRect.minY - self.animatedObject.frame.height
            if self.animatedObject.frame.origin.y == targetY { return }
            
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                if (self.setConstraint(show: true, height: keyboardRect.height) == true) { return }
                self.animatedObject.frame.origin.y = targetY
            })
        }
    }

    // 키보드 사라질때 특정 view를 원래 위치로 이동
    @objc func keyboardWillHide(note: NSNotification) {
        guard animatedObject != nil else { return }
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            if (self.setConstraint(show: false) == true) { return }
            self.animatedObject.frame.origin = self.animatedObjectOriginalPos
        })
    }
    
    // constraint bottom이 있으면 그것의 간격을 늘림
    // (auto layout이 적용되어있으면 text 입력시 textField가 원위치로 돌아가기 때문에 view의 프레임을 바꾸지않고 constraint를 수정해야함)
    func setConstraint(show: Bool, height: CGFloat = 0) -> Bool {

        func setConstant() {
            if show {
                if animatedConstraint.constant == animatedContraintOriginalConstant { animatedConstraint.constant += height }
            } else {
                if animatedConstraint.constant != animatedContraintOriginalConstant { animatedConstraint.constant = self.animatedContraintOriginalConstant }
            }
        }
        
        if animatedConstraint != nil {
            setConstant()
            return true
        }
        
        for constraint in self.animatedObject.constraints {
            guard constraint.firstAttribute == .bottom else { continue }
            animatedConstraint = constraint
            animatedContraintOriginalConstant = constraint.constant
            setConstant()
            return true
        }

        return false
    }

    /*
    // MARK: - Encode to MD5
    func encodeToMD5(pw: String) -> String {
        let digest = Insecure.MD5.hash(data: pw.data(using: .utf8) ?? Data())
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    */
    
    // MARK: - Indicator
    // return value 'Bool' = anable to create
    func createIndicator(alpha: CGFloat = 0.1) -> Bool {
        
        if indicator != nil && indicator.isAnimating { return false }
        
        guard let vc = topViewController() else { return false }
        
        indicator = UIActivityIndicatorView(frame: vc.view.bounds)
        indicator.style = .large
        indicator.color = .white
        indicator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: alpha)
        indicator.hidesWhenStopped = true
        vc.view.addSubview(indicator)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) { vc.view.bringSubviewToFront(self.indicator) }
        indicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(30)) {
            self.indicator.stopAnimating()
        }
        
        return true
    }
    
    func removeIndicator() {
        if indicator == nil { return }
        indicator.stopAnimating()
    }
    
    
    // MARK: - Get Midnight
    func getPrevMidnight() -> Date {
        let prevMidNight = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        return prevMidNight
    }
    
    func getNextMidnight() -> Date {
        let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: getPrevMidnight())!
        return nextMidnight
    }
    
    // MARK: get gurrency string
    func getCurrencyString() -> String {
        var currencyString = Locale.current.currencySymbol!
        
        // 이거 안됨.. 이유는 모름
//        let langCode = Locale.current.languageCode
        
        // 이걸 쓰거나 regionCode 사용
//        let localeID = Locale.preferredLanguages.first
//        let langCode = (Locale(identifier: localeID!).languageCode)!
        
        let regionCode = Locale.current.regionCode
        if regionCode == "KR" { currencyString = "원" }
        return currencyString
    }
    
    // MARK: - 나눔 폰트 적용
    func setText(bold: BoldCase, size: CGFloat, text: String, color: UIColor = _tungsten, lineSpacing: CGFloat = -1, alignment: NSTextAlignment = .left, label: UILabel) {
//        label.font = UIFont(name: bold.name, size: size)
//        label.text = text
//        label.textColor = color
        
        let paragraphStyle = NSMutableParagraphStyle()
        if lineSpacing >= 0 {
            paragraphStyle.lineSpacing = lineSpacing
        } else {
            paragraphStyle.lineSpacing = size * 0.5
        }
        paragraphStyle.alignment = alignment
        
        let attributes: [NSAttributedString.Key : Any] = [
//            .font: UIFont(name: bold.name, size: size) ?? UIFont.systemFont(ofSize: size),
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle,
            ]
        
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.font = UIFont(name: bold.name, size: size)
    }
    
    func setText(bold: BoldCase, size: CGFloat, text: String, placeHolder: String = "", color: UIColor = _tungsten, field: UITextField) {
        field.font = UIFont(name: bold.name, size: size)
        field.text = text
        field.textColor = color
        field.placeholder = placeHolder
    }
    
    func setText(bold: BoldCase, size: CGFloat, text: String, color: UIColor = _tungsten, lineSpacing: CGFloat = -1, alignment: NSTextAlignment = .left, textview: UITextView) {
//        textview.font = UIFont(name: bold.name, size: size)
//        textview.text = text
//        textview.textColor = color
        
        let paragraphStyle = NSMutableParagraphStyle()
        if lineSpacing >= 0 {
            paragraphStyle.lineSpacing = lineSpacing
        } else {
            paragraphStyle.lineSpacing = size * 0.5
        }
        
        paragraphStyle.alignment = alignment
        
        let attributes: [NSAttributedString.Key : Any] = [
            .font: UIFont(name: bold.name, size: size) ?? UIFont.systemFont(ofSize: size),
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
            ]
        
        textview.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
    
    func setText(bold: BoldCase, size: CGFloat, text: String, color: UIColor = _tungsten, button: UIButton) {
        button.titleLabel?.font = UIFont(name: bold.name, size: size)
        button.setTitle(text, for: .normal)
        button.setTitleColor(color, for: .normal)
    }
    
    // MARK: - Request Url
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
    
    // MARK: - Get Date from String
    func getDateFromString(dateString: String, dateFormat: String) -> Date {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?

        let date = dateFormatter.date(from: dateString)!
        return date
    }
    
    // MARK: - Move Scene From TopViewController
    func moveScene(storyboardId: String, push: Bool, fullScreen: Bool = true) {
        guard let topVc = topViewController() else { _log.log("not found top view controller"); return }
        guard let destination = topVc.storyboard?.instantiateViewController(withIdentifier: storyboardId) else { _log.log("not found [\(storyboardId)] controller"); return }
        
        if push {
            guard let topNavi = topVc.navigationController else { _log.log("not found top navigation controller"); return }
            topNavi.pushViewController(destination, animated: true)
        } else {
            if fullScreen { destination.modalPresentationStyle = .fullScreen }
            else { destination.modalPresentationStyle = .pageSheet }
            
            topVc.present(destination, animated: true, completion: nil)
        }
    }
    
    // MARK: - 시간차이 Int
    func getTimeIntervalInt(start: Date?, end: Date?) -> Int {
        let startTimeInterval = start?.timeIntervalSince1970 ?? 0       // second
        let endTimeInterval = end?.timeIntervalSince1970 ?? 0
        if startTimeInterval == 0 || endTimeInterval == 0 { return 0 }
        
        let during = endTimeInterval - startTimeInterval
//        let oneDaySecond: Double = 60 * 60 * 24     // 하루(second)
        let oneHourSecond: Double = 60 * 60         // 1시간(second)
        
        var duringInt: Int = 0                      // 맡기는 시간
//        if during > oneDaySecond {
//            let remain = during.truncatingRemainder(dividingBy: oneDaySecond)
//            duringInt = Int(exactly: (during - remain) / oneDaySecond) ?? 0
//        }
//        else {
            let remain = during.truncatingRemainder(dividingBy: oneHourSecond)
            duringInt = Int(exactly: (during - remain) / oneHourSecond) ?? 0
//        }
        
        if duringInt == 0 && during > 0 { duringInt = 1 }
        
        return duringInt
    }
    
    // MARK: - Test
    func test01() {
        let date = Date()
        let nextDayStartTime = Calendar.current.nextDate(after: date, matching: DateComponents(hour: 10), matchingPolicy: .nextTime) ?? Date()           // 다음날 자정!!
        let nextDayEndTime = nextDayStartTime.addingTimeInterval(8 * 60 * 60)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        let currentLocale = Locale(identifier: NSLocale.preferredLanguages[0])
        formatter.locale = currentLocale
        
        let startDateString = formatter.string(from: nextDayStartTime)
        _log.logWithArrow("start time", startDateString)
        
        let endDateString = formatter.string(from: nextDayEndTime)
        _log.logWithArrow("end time", endDateString)
    }
}


// MARK: - Version
extension MyUtils {
    // 업데이트 가능 여부 확인
    // iTunes Connect에 업로드 후 구현할 예정..
    // 내번들ID에 앱의 번들ID 입력 (iTunes Connect > 나의 앱 > 확인하고 싶은 앱 클릭 > 앱정보 > 일반정보 > 번들ID)
    // (출처: https://zeddios.tistory.com/372)
    func isUpdateAvailable() -> Bool {
        let version = getAppVersion()
        guard let url = URL(string: "http://itunes.apple.com/lookup?bundleId=내번들ID"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              results.count > 0,
              let appStoreVersion = results[0]["version"] as? String
        else { return false }
        
        if !(version == appStoreVersion) { return true }
        
        return false
    }
    
    func getAppVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "?" }
        return version
    }
    
    func getAppVersionInt() -> Int {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return 0 }
        let versionStr = version.components(separatedBy: ["."]).joined()
        let versionInt = Int(versionStr) ?? 0
        return versionInt
    }
    
    func getAppVersionInt(version: String) -> Int {
        let versionStr = version.components(separatedBy: ["."]).joined()
        let versionInt = Int(versionStr) ?? 0
        return versionInt
    }
    
    func openAppStore(urlStr: String) {
        guard let url = URL(string: urlStr) else {
            _log.log("invalid app store url")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            _log.log("can't open app store url")
        }
    }
    
    func getServerInfo() -> String {
        var server: String = ""
        if releaseMode {
            server = "live"
        } else {
            server = "dev"
        }
        
        return server
    }
    
    func getAppType() -> String {
        let type = "storage(\(CarrifreeAppType.appUser.rawValue))"
        return type
    }
    
    func getAppInfo() -> String {
        let appInfo = "\(getServerInfo()) \(getAppType()) v\(getAppVersion())"
        return appInfo
    }
    
}

// MARK: - crypt
extension MyUtils {
    // encode to MD5
    func encodeToMD5(pw: String) -> String {
        let digest = Insecure.MD5.hash(data: pw.data(using: .utf8) ?? Data())
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
    /*
    func encrypt(string: String) -> String {
        guard !string.isEmpty else { return "" }
//        return try! getAESObject().encrypt(string.bytes).toBase64()
        
        var encode: [UInt8] = []
        do {
            try encode = getAESObject().encrypt(string.bytes)
        } catch {
            encode = Array(string.utf8)
        }
        
        return encode.toBase64()
    }
    
    func decrypt(encoded: String) -> String {
        let datas = Data(base64Encoded: encoded)
        
        guard datas != nil else {
            return ""
        }
        
        let bytes = datas!.bytes
        var decode: [UInt8] = []
        do {
            try decode = getAESObject().decrypt(bytes)
        } catch {
            decode = Array(encoded.utf8)
        }
        
        let decoded = String(bytes: decode, encoding: .utf8) ?? ""
        return decoded
    }
    
    func getAESObject() -> AES {
        let key: Array<UInt8> = Array("01234567890123450123456789012345".utf8)
        let iv = Array("0123456789012345".utf8)
        let aesObject = try! AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs5)
        return aesObject
    }
     */
}

