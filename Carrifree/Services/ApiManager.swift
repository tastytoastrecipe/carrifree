//
//  APIManger.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/31.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias AttachForm = [(name: String, data: [Data?])]

struct ByteEncoder: ParameterEncoder {
    func encode<Parameters>(_ parameters: Parameters?, into request: URLRequest) throws -> URLRequest where Parameters : Encodable {
        var request = request
        request.httpBody = data
        return request
    }
    
  private let data: Data

  init(data: Data) {
    self.data = data
  }
}

class ApiManager {
    
    var api: ApiType
    
    private let amazonSession: Session = {
        // 아마존 업로드 경로의 신뢰를 설정함
        let manager = ServerTrustManager(evaluators: ["com.carrifree.timg.s3.ap-northeast-2.amazonaws.com": DisabledTrustEvaluator(),
                                                      "com.carrifree.tfile.s3.ap-northeast-2.amazonaws.com": DisabledTrustEvaluator(),
                                                      "com.carrifree.img.s3.ap-northeast-2.amazonaws.com": DisabledTrustEvaluator(),
                                                      "*.s3.ap-northeast-2.amazonaws.com": DisabledTrustEvaluator()])
        let configuration = URLSessionConfiguration.af.default
        configuration.requestCachePolicy = .reloadIgnoringCacheData

        return Session(configuration: configuration, serverTrustManager: manager)
    }()
    
    init() {
        api = .none
    }
    
    func request(api: ApiType, url: String, parameters: Parameters, timeoutInterval: TimeInterval = 30, completion: ResponseJson = nil) {
        self.api = api
        
        AF.request(url, method: .post, parameters: parameters) { $0.timeoutInterval = timeoutInterval }.validate().responseJSON { (response) in
            
            self.response(title: api.title, responseData: response, completion: completion)
        }
    }
    
    func request(api: ApiType, url: String, headers: HTTPHeaders, parameters: Parameters, timeoutInterval: TimeInterval = 30, completion: ResponseJson = nil) {
        self.api = api
        
        AF.request(url, method: .post, parameters: parameters, headers: headers) { $0.timeoutInterval = timeoutInterval }.validate().responseJSON { (response) in
            
            self.response(title: api.title, responseData: response, completion: completion)
        }
    }
    
    func requestSimpleGetString(api: ApiType, url: String, timeoutInterval: TimeInterval = 30, completion: ResponseString = nil) {
        self.api = api
        
        AF.request(url, method: .post) { $0.timeoutInterval = timeoutInterval }.validate().ResponseString { (response) in
            
            self.responseString(title: api.title, ResponseString: response, completion: completion)
        }
    }
    
    func requestSimpleGetJson(api: ApiType, url: String, timeoutInterval: TimeInterval = 30, completion: ResponseJson = nil) {
        self.api = api
        
        AF.request(url, method: .post) { $0.timeoutInterval = timeoutInterval }.validate().responseJSON { (response) in
            
            self.response(title: api.title, responseData: response, completion: completion)
        }
    }
    
    /// MultiPart 형식으로 파일 전송
    func requestAttach(api: ApiType, url: String, headers: HTTPHeaders, parameters: [String: String], attaches: AttachForm, timeoutInterval: TimeInterval = 60, completion: ResponseJson = nil) {
        self.api = api
        
        AF.upload(multipartFormData: { multipartFormData in
            
            // multipart 데이터 생성 (parameters)
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            
            // multipart 데이터 생성 (images)
            for attach in attaches {
                for (index, data) in attach.data.enumerated() {
                    guard let imgData = data else { continue }
                    multipartFormData.append(imgData, withName: "fileList", fileName: "\(index).jpg", mimeType: "image/jpeg")
                    multipartFormData.append(attach.name.data(using: .utf8)!, withName: "ATTACH_TYPE")
                }
            }
        }, to: url, method: .post, headers: headers) { $0.timeoutInterval = 10 }.validate().responseJSON { (response) in
            
            //_utils.removeIndicator()
            self.response(title: api.title, responseData: response, completion: completion)
        }
    }
    
    /// Data 형식으로 파일 전송
    func requestUpload(isPrivate: Bool, data: Data, url: String, timeoutInterval: TimeInterval = 60, completion: ResponseString = nil) {
        let headers: HTTPHeaders = [
            "Content-Type": "image/jpeg"
        ]
        
        amazonSession.upload(data, to: url, method: .put, headers: headers).validate().responseJSON { (response) in
            guard let httpResponse = response.response else {
                _log.logWithArrow("Upload image failed", "can not binding http response..")
                completion?(false, "서버로부터 잘못된 응답을 받았습니다.")
                return
            }
            
            switch response.result {
                case .success(_): break
                case .failure(let error):
                    switch error {
                    case .sessionTaskFailed(URLError.timedOut):
                        completion?(false, "요청시간이 초과 되었습니다.")
                        return
                    default: break
                    }
                }
            
            let statusCode = httpResponse.statusCode
            if statusCode == 200 {
                _log.log("😁 Upload image success! 😁")
//                self.response(title: ApiType.uploadData.title, responseData: response, completion: completion)
                completion?(true, "")
            } else {
                let errLog = "status code == \(statusCode)"
                _log.logWithArrow("Upload image failed", "status code == \(statusCode)")
                completion?(false, errLog)
//                completion?(true, "status code == \(statusCode)")
            }
        }
        return
    }
    
    func response(title: String, responseData: AFDataResponse<Any>, showLog: Bool = true, completion: ResponseJson = nil) {
        if showLog { printRequestInfo(requestTitle: title, response: responseData) }
        
        switch responseData.result {
        case .success(let value):
            let jsonValue = JSON(value)
            let msg = jsonValue["resMsg"].stringValue
            guard jsonValue["resCd"].stringValue == "0000" else {
                _log.logWithArrow("\(title) failed", msg)
                completion?(false, jsonValue)
                return
            }
            
            _log.log("\(title) success")
            completion?(true, jsonValue)
            
        case .failure(let error):
            _log.logWithArrow("\(title) 실패", error.localizedDescription)
            if let data = responseData.data { completion?(false, JSON(data)) }
            else { completion?(false, nil) }
        }
        
        self.api = .none
    }
    
    func responseString(title: String, ResponseString: DataResponse<String, AFError>, completion: ResponseString = nil) {
        printRequestInfo(requestTitle: title, responseString: ResponseString)
        
        switch ResponseString.result {
        case .success(let str):
            completion?(true, str)
        case .failure(let error):
            _log.logWithArrow("\(title) 실패", error.localizedDescription)
            completion?(false, ResponseString.data?.debugDescription ?? "")
        }
        
        self.api = .none
    }
    
    // 내가 요청한 스펙을 logging
    func printRequestInfo(requestTitle: String, response: AFDataResponse<Any>) {
        _log.logWithArrow("\(requestTitle) response", response.debugDescription)
        
        if let data = response.request?.httpBody {
            let bodyStr = String(data: data, encoding: .utf8) ?? ""
            let bodyArr = bodyStr.split(separator: "&").map { (value) -> String in
                return String(value)
            }
            
            _log.logWithArrow("\(requestTitle) request body", "\n")
            for body in bodyArr {
                print("\t\(body)")
            }
            
            print("\n")
        }
    }

    func printRequestInfo(requestTitle: String, responseString: DataResponse<String, AFError>) {
        _log.logWithArrow("\(requestTitle) response", responseString.debugDescription)

        if let data = responseString.request?.httpBody {
            let bodyStr = String(data: data, encoding: .utf8) ?? ""
            let bodyArr = bodyStr.split(separator: "&").map { (value) -> String in
                return String(value)
            }

            _log.logWithArrow("\(requestTitle) request body", "\n")
            for body in bodyArr {
                print("\t\(body)")
            }

            print("\n")
        }
    }
    
    static func getFailedMsg(defaultMsg: String, json: JSON?) -> String {
        guard let json = json else { return defaultMsg }
        
        var msg = defaultMsg
        let errMsg = json["resMsg"].stringValue
        if errMsg.count > 0 { msg += "\n(\(errMsg))" }
        else { return msg }
        
        return msg
    }
}
