//
//  ImpPurchasingVc.swift
//  Carrifree
//
//  Created by orca on 2022/03/24.
//  Copyright © 2022 plattics. All rights reserved.
//

import UIKit
import WebKit
import SwiftyIamport

protocol ImpPurchasingVcDelegate {
    func purchasingDone(impUid: String)
}

class ImpPurchasingVc: UIViewController, WKUIDelegate {
    
    let purchaseSuccessMethod: String = "purchasingSuccess"
    let purchaseFailedMethod: String = "purchasingFailed"
    
    var webView: WKWebView!
    var purchasingData: PurchasingData!
    var delegate: ImpPurchasingVcDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setWebView()
        setIamport()
        callIamportPage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.purchasingDone(impUid: purchasingData.impUid)
    }
    
    func setWebView() {
        // 브릿지 설정
        let contentController = WKUserContentController()
        contentController.add(self, name: purchaseSuccessMethod)
        contentController.add(self, name: purchaseFailedMethod)
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        // 웹뷰 생성
        webView = WKWebView(frame: self.view.bounds, configuration: config)
        webView.uiDelegate = self
        
        webView.backgroundColor = UIColor.clear
        webView.navigationDelegate = self
        
        self.view.addSubview(webView)
    }
    
    // iamport 설정
    func setIamport() {
        
        IAMPortPay.sharedInstance.configure(scheme: _identifiers.scheme.rawValue,                           // 이 앱의 scheme (카드앱 결제후 돌아오기위해)
                                            storeIdentifier: _identifiers.iamportCompanyId.rawValue)        // iamport 에서 부여받은 가맹점 식별코드
        
        IAMPortPay.sharedInstance
            .setPGType(.danal_tpay)                 // PG사 타입
            .setIdName(nil)                         // 상점아이디 ({PG사명}.{상점아이디}으로 생성시 사용)
            .setPayMethod(.card)                    // 결제 형식
            .setWKWebView(self.webView)             // 현재 Controller에 있는 WebView 지정
            .setRedirectUrl(nil)                    // m_redirect_url 주소
        
        /*
        var cost: Int? = nil
        if CarrySearch.service == .store {
            cost = CarryDatas.shared.currentSearchData.storage?.cost
        } else if CarrySearch.service == .delivery {
            cost = CarryDatas.shared.currentSearchData.driver?.cost
        }
        
        if nil == cost {
            let ok = CarryUtils.shared.createAlertAction(title: "ok")
            let alert = CarryUtils.shared.createAlert(title: CarryStrings.alertCostInfoNotExist.rawValue, message: "", handlers: [ok], style: .alert, addCancel: false)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let date = Date()
        var timeStr = date.toString().replacingOccurrences(of: " ", with: "/")
        timeStr = "\(timeStr)/\(Int.random(in: 0...100000)))"
        
        let serviceDetail = CarryDatas.shared.currentSearchData.serviceDetail.name
        if serviceDetail.isEmpty { return }
        
        let endDateString = date.toString()
        CarryLog.log(endDateString)
        let endDateStringArr = endDateString.split(separator: " ").map { (value) -> String in
            return String(value)
        }
        
        let endDateStr = endDateStringArr[0].replacingOccurrences(of: "-", with: "")
        let name = "\(serviceDetail)(\(endDateStr))"
        */
        
        // 결제 정보 데이터
        let timestamp = Date().localDate.timestamp
        let parameters: IAMPortParameters = [
            "pg": "danal_tpay",     // 이거 반드시 설정해줘야함.. 안하면 웹으로 넘어갈때나 앱으로 다시 돌아올때 엄청 느리고 crash도 많이 발생함
            "imp_key": _identifiers.iamportKey.rawValue,
            "imp_secret": _identifiers.iamportSecret.rawValue,
            "merchant_uid": "merchant-\(_user.seq)-\(timestamp)",
            "name": "item-\(_user.seq)-\(timestamp)",
            "amount": purchasingData.cost,
            "buyer_email": "",
            "buyer_name": _user.name,
            "buyer_tel": _user.contact,
            "buyer_addr": "-",
            "buyer_postcode": "-",
            "app_scheme": _identifiers.scheme.rawValue
        ]
        IAMPortPay.sharedInstance.setParameters(parameters).commit()
    }
    
    // 결제 웹페이지(Local) 파일 호출
    func callIamportPage() {
        
        if let url = IAMPortPay.sharedInstance.urlFromLocalHtmlFile() {
            let request = URLRequest(url: url)
            self.webView!.load(request)
        }
    }
    
    
    func moveToDone() {
        self.dismiss(animated: true) {
            let vc = StorageDoneVc()
            vc.purchasingData = self.purchasingData
            vc.modalPresentationStyle = .fullScreen
            _utils.topViewController()?.present(vc, animated: true)
        }
    }
}

// MARK: - WKScriptMessageHandler
extension ImpPurchasingVc: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        // iamport 결제 성공
        if message.name == purchaseSuccessMethod {
            let impUid = (message.body as? String) ?? ""
            purchasingData.impUid = impUid
            
            // 서버에 결제 완료 요청
            _cas.purchsing.finishPurchasing(data: purchasingData) { (success, json) in
                guard let json = json, true == success else {
                    let failedMsg = ApiManager.getFailedMsg(defaultMsg: "결제를 완료하지 못했습니다. 다시 시도해주시기 바랍니다.", json: json)
                    let alert = _utils.createSimpleAlert(title: "결제 오류", message: failedMsg, buttonTitle: _strings[.ok])
                    self.present(alert, animated: true)
                    return
                }
                
                let orderNo = json["DELIVERY_NO"].stringValue
                self.purchasingData.orderNo = orderNo
                self.moveToDone()
            }
        }
        // iamport 결제 실패
        else if message.name == purchaseFailedMethod {
            var failedMsg = "결제를 완료하지 못했습니다. 다시 시도해주시기 바랍니다."
            var failedReason = (message.body as? String) ?? ""
            if failedReason.isEmpty { failedReason = "unknown err" }
            failedMsg += "\n(\(failedReason))"
            
            let alert = _utils.createSimpleAlert(title: "결제 오류", message: failedMsg, buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
        }
    }
}

// MARK: - WKNavigationDelegate
extension ImpPurchasingVc: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        
        IAMPortPay.sharedInstance.requestRedirectUrl(for: request, parser: { (data, response, error) -> Any? in
            // Background Thread 처리
            var resultData: [String: Any]?
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                switch statusCode {
                case 200:
                    resultData = [
                        "isSuccess": "OK"
                    ]
                    break
                default:
                    break
                }
            }
            _log.logWithArrow("webView navigationAction requestRedirectUrl", "\(resultData?.debugDescription ?? "")")
            return resultData
        }) { (pasingData) in
            // Main Thread 처리
            _log.logWithArrow("webView navigationAction completion", "\(pasingData.debugDescription)")
        }
        
        let result = IAMPortPay.sharedInstance.requestAction(for: request)
        _log.logWithArrow("webView navigationAction result", "\(result)")
        decisionHandler(result ? .allow : .cancel)
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 결제 환경으로 설정에 의한 웹페이지(Local) 호출 결과
        IAMPortPay.sharedInstance.requestIAMPortPayWKWebViewDidFinishLoad(webView) { (error) in
            if error != nil {
                switch error! {
                case .custom(let reason):
                    _log.logWithArrow("webView didFinish", " error: \(reason)")
                    break
                }
            }else {
                _log.logWithArrow("webView didFinish", "OK")
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        _log.log("didFail")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        _log.log("didFailProvisionalNavigation \(error.localizedDescription)")
    }
    
}
