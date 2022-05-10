//
//  CarryRequest.swift
//  Carrifree
//
//  Created by orca on 2020/10/26.
//  Copyright © 2020 plattics. All rights reserved.
//

/*
import Foundation
import Alamofire
import SwiftyJSON

typealias ResponseString = ((Bool, String) -> Void)?
typealias ResponseJson = ((Bool, JSON) -> Void)?

// id 찾기 요청 후 응답 callback
typealias requestCallbackIdFindForm = (([IdFindData], String) -> Void)?

class CarryRequest {
    
    static let shared = CarryRequest()
    
    var addressPage = 1
    var currentKeyword = ""
    var server: String = ""
    private let timeoutInterval: Double = 60
    
    var driverListPage = 1          // 운송사업자 목록 요청시 페이지
    var driverTotalCount = 0        // 검색된 운송사업자 총 개수
    var driverCurrentCount = 0      // 현재까지 화면에 표시된 운송사업자 개수
    
    var storageListPage = 1         // 보관사업자 목록 요청시 페이지
    var storageTotalCount = 0       // 검색된 보관업자 총 개수
    var storageCurrentCount = 0     // 현재까지 화면에 표시된 보관사업자 개수
    
    var reviewPage = 1              // 리뷰 목록 요청시 페이지
    var reviewTotalCount = 0        // 리뷰 총 개수
    var reviewCurrentCount = 0      // 현재까지 화면에 표시된 리뷰 개수
    
    var binding: CarryBinding
    
    private init() {
        if releaseMode {
            server = MyIdentifiers.liveServer.rawValue
        } else {
            server = MyIdentifiers.devServer.rawValue
        }
        
        binding = CarryBinding()
    }
    
    func printRequestInfo(requestTitle: String, response: AFDataResponse<Any>) {
        if releaseMode { return }
        
        MyLog.logWithArrow("\(requestTitle) response", response.debugDescription)
        
        if let data = response.request?.httpBody {
            let bodyStr = String(data: data, encoding: .utf8) ?? ""
            
            
            let bodyArr = bodyStr.split(separator: "&").map { (value) -> String in
                return String(value)
            }
            
            MyLog.logWithArrow("\(requestTitle) request body", "\n")
            for body in bodyArr {
                print("\t\(body)")
            }
            
            print("\n")
        }
    }
    
    func removeReviewCache() {
        reviewPage = 1
        reviewTotalCount = 0
        reviewCurrentCount = 0
        CarryUser.reviews.removeAll()
    }
    
    func requestAddress(keyword: String) {
        if keyword.isEmpty { return }
        currentKeyword = keyword
        
        let headers: HTTPHeaders = [ "Authorization": "KakaoAK \(MyIdentifiers.keyKakaoRestApi.rawValue)"]
        let parameters: [String: Any] = ["query": keyword, "page": addressPage, "size": 20]
        var addressArr: [String] = []
        AF.request("https://dapi.kakao.com/v2/local/search/address.json",
                   method: .get,
                   parameters: parameters,
                   headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson(completionHandler: { response in
                    
                    guard let data = response.data else { return }
                    do {
                        let address = try JSONDecoder().decode(ResponseAddress.self, from: data)
                        guard let meta = address.meta else { return }
                        guard let docs = address.doc else { return }
                        for doc in docs {
                            addressArr.append(doc.address ?? "")
                        }
                        
                        if let isEnd = meta.isEnd, isEnd == true { self.addressPage = 0 }
                        
                    } catch {
                        MyLog.log("request address error: \(error)")
                    }
                    
                    CarryEvents.shared.callSearchDone(list: addressArr)
                   })
    }
    
    func requestAddressNextPage() {
        if addressPage <= 0 {
            MyLog.log("요청할 페이지 없음..")
            return
        } else {
            addressPage += 1
            requestAddress(keyword: currentKeyword)
        }
    }

    func getRequestUrl(body: String) -> String {
        return "\(server)\(body)"
    }
    
    
    // MARK:- 배너
    func requestBanner(completion: ResponseString = nil) {
        // -------------------------- Request -------------------------- //
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      LINK_URL                링크 주소
        //      BANNER_ATTACH_INFO      배너 사진 정보
        //      BOARD_TITLE             배너 제목(간단 설명)
        //
        // ------------------------------------------------------------- //
        
        let url = getRequestUrl(body: "/sys/contents/appMain/bannerList.do")
        
        AF.request(url, method: .post) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[배너 요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                self.binding.bindingBanner(json: JSON(value), completion: completion)
                
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // MARK:- ID 중복 확인
    func requestDuplicateCheck(id: String, completion: ((Bool, String) -> Void)?) {
        
        let param: Parameters = [
            "USER_ID": id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
//        let url = getRequestUrl(body: "/sys/member/app/duplicateMember.do?USER_ID=\(id)")
        let url = getRequestUrl(body: "/sys/member/app/duplicateMember.do")
        AF.request(url, method: .post, parameters: param) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            let requestTitle = "[ID 중복 확인]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                var msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    let isDuplicated = result != "0000"
                    if isDuplicated {
                        
                        if result == "9890" { msg = MyStrings.alertIdAlreadyJoined.rawValue }
                        MyLog.logWithArrow("\(requestTitle) failed", msg)
                        completion?(true, msg)
                    } else {
                        MyLog.logWithArrow("\(requestTitle) success", result)
                        completion?(false, "")
                    }
                    
                } else {
                    MyLog.logWithArrow("\(requestTitle) failed", msg)
                    completion?(true, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(true, error.localizedDescription)
            }
        }
    }
    
    // MARK:- 유저 정보 수정 요청 (폰번호)
    func requestUpdateInfo(os: String, completion: ResponseJson = nil) {
        
        //-------------------------- Request -------------------------- //
        //
        //         PLATFORM_TYPE            단말기 타입 (I: iOS, A: Android)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //          APP_VERSION             마지막 강제 업데이트 버전
        //          DATE_C                  마지막 강제 업데이트 날짜
        //
        //------------------------------------------------------------- //
        
//        let headers: HTTPHeaders = [
//            "USER_TOKEN": CarryDatas.shared.user.token,
//            "USER_ID": CarryDatas.shared.user.id
//        ]

        let param: [String: String] = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "PLATFORM_TYPE": os
        ]

        let url = getRequestUrl(body: "/sys/common/app/versionMng.do")
        AF.request(url, method: .post, parameters: param) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            let requestTitle = "[업데이트 정보 요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                completion?(false, JSON(value))
                
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, JSON(response))
            }
        }
    }
    
    // 회원가입 - 이메일 코드 발급
    func requestEmailVerificationCode(userId: String, joinType: String, email: String, name: String, pw: String, type: String = CarrifreeAppType.appUser.user, completion: ((Bool, String) -> Void)? = nil) {
        /*
         회원 ID      USER_ID      STRING    Email로 전달
         패스워드      USER_PWD     STRING    MD5로 변환하여 전달(11111 >>> b0baee9d279d34fa1dfd71aadb908c3f)
         회원 이름     USER_NAME    STRING
         회원구분      USER_TYPE    STRING    001:일반회원, 002:보관사업자, 003:운송사업자
         회원 EMAIL   USER_EMAIL   STRING
         가입 방법 코드 JOIN_TYPE    STRING    001:EMAIL, 002:카카오톡, 003:구글, 004:네이버
         */
        
        let param: Parameters = [
            "USER_ID": userId,
            "USER_PWD": pw,
            "USER_NAME": name,
            "USER_TYPE": type,
            "USER_EMAIL": email,
            "JOIN_TYPE": joinType
        ]
        
//        let body = "/sys/member/app/sendAuthEmail.do?USER_ID=\(userId)&USER_PWD=\(pw)&USER_NAME=\(name)&USER_TYPE=\(type)&USER_EMAIL=\(email)&JOIN_TYPE=\(joinType)"
        let body = "/sys/member/app/sendAuthEmail.do"
        let encodedUrl = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""      // 한글 encoding
        let url = getRequestUrl(body: encodedUrl)
        
        AF.request(url, method: .post, parameters: param) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            let requestTitle = "[회원가입 - 이메일 코드 인증]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        MyLog.logWithArrow("\(requestTitle) success", result)
                        completion?(true, MyStrings.senfEmailVerificationCode.rawValue)
                    } else {
                        MyLog.logWithArrow("\(requestTitle) failed", msg)
                        completion?(false, msg)
                    }
                    
                    
                } else {
                    MyLog.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, jsonValue["resMsg"].stringValue)
                }
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // 회원가입 - 이메일 코드 인증
    func requestEmailVerificationComplete(userId: String, emailCode: String, completion: ((Bool, String) -> Void)? = nil) {
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_ID": userId,
            "AUTH_NO": emailCode
        ]
        
//        let url = getRequestUrl(body: "/sys/member/app/authJoinMember.do?USER_ID=\(userId)&AUTH_NO=\(emailCode)")
        let url = getRequestUrl(body: "/sys/member/app/authJoinMember.do")
        AF.request(url, method: .post, parameters: param) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            self.printRequestInfo(requestTitle: "[회원가입 - 이메일 코드 인증]", response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    
                    if result == "0000" {
                        MyLog.logWithArrow("[회원가입 - 이메일 코드 인증] success", result)
                        completion?(true, "")
                    } else {
                        MyLog.logWithArrow("[회원가입 - 이메일 코드 인증] failed", msg)
                        completion?(false, msg)
                    }
                    
                } else {
                    MyLog.logWithArrow("[회원가입 - 이메일 코드 인증] failed", msg)
                    completion?(false, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("[회원가입 - 이메일 코드 인증] failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    
    // 회원가입
    func requestSignUp(userId: String, pw: String, joinType: String, name: String, email: String, emailCode: String, memberInfoAgree: Bool, privateInfoAgree: Bool, marketingInfoAgree: Bool, type: String = CarrifreeAppType.appUser.user, completion: ((Bool, String) -> Void)? = nil) {
        
        if false == _utils.createIndicator() { return }
        
        MyLog.logWithArrow("Request sign-up parameters", "\nid: \(userId)\npw: \(pw)\njoinType: \(joinType)\nname: \(name)\nemail: \(email)\nemailCode: \(emailCode)\n")
        /*

         회원 ID       USER_ID           Email로 전달
         패스워드       USER_PWD
         사용자 이름     USER_NAME
         생년월일       USER_BIRTH
         핸드폰번호      USER_HP_NO
         이메일주소      USER_EMAIL
         사용자 구분     USER_TYPE        001:일반회원, 002:보관사업자, 003:운송사업자
         상호명         BIZ_NAME
         가입방법 코드    JOIN_TYPE        001:EMAIL, 002:카카오톡, 003:구글, 004:네이버
         회사 간편 주소   BIZ_SIMPLE_ADDR
         회사 상세 주소   BIZ_DETAIL_ADDR
         회사 전화번호    BIZ_TEL
         회사 구분       BIZ_GUBUN        01:개인회원, 02 :법인회원
         사업자번호      BIZ_CORP_NO
         은행코드        BANK_CD
         계좌번호        BANK_PRIVATE_NO
         약관동의        MSG_AGREE        "체크 하면 'Y' 안하면 'N'"
         정보동의        INFO_AGREE
         마케팅 동의      MAR_AGREE
         이메일 인증 번호     AUTH_NO
         첨부파일 전달 유무   ATTACH_YN        파일이 있을경우에는 Y전달
         첨부파일 객체       fileList
         저장 모듈          module        회원 가입 당시 : 1
         
         */
        
        let memberInfoAgreeStr = memberInfoAgree ? "Y" : "N"
        let privateInfoAgreeStr = privateInfoAgree ? "Y" : "N"
        let marketingInfoAgreeStr = marketingInfoAgree ? "Y" : "N"
        
        let param: Parameters = [
            "USER_ID": userId,
            "USER_PWD": pw,
            "USER_NAME": name,
            "USER_BIRTH": "",
            "USER_HP_NO": "",
            "USER_EMAIL": email,
            "USER_TYPE": type,
            "BIZ_NAME": "",
            "JOIN_TYPE": joinType,
            "BIZ_SIMPLE_ADDR": "",
            "BIZ_DETAIL_ADDR": "",
            "BIZ_TEL": "",
            "BIZ_GUBUN": "",
            "BIZ_CORP_NO": "",
            "BANK_CD": "",
            "BANK_PRIVATE_NO": "",
            "MSG_AGREE": memberInfoAgreeStr,
            "INFO_AGREE": privateInfoAgreeStr,
            "MAR_AGREE": marketingInfoAgreeStr,
            "AUTH_NO": emailCode,
            "ATTACH_YN": "N",
            "fileList": "",
            "module": "1"
        ]
        
        var urlBody = "/sys/member/app/generalJoinMember.do?"
        if joinType != "001" {
            urlBody = "/sys/member/app/simpleJoinMember.do?"
        }
        
        let url = getRequestUrl(body: urlBody).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        AF.request(url, method: .post, parameters: param) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            self.printRequestInfo(requestTitle: "[회원가입]", response: response)
            
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    
                    if result == "0000" {
                        MyLog.logWithArrow("[회원가입] success", result)
                        completion?(true, "")
                    } else {
                        MyLog.logWithArrow("[회원가입] failed", msg)
                        completion?(false, msg)
                    }
                    
                } else {
                    MyLog.logWithArrow("[회원가입] failed", msg)
                    completion?(false, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("[회원가입] failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // 로그인
    func requestSignIn(userId: String, pw: String, type: String, userType: String = CarrifreeAppType.appUser.user, name: String = "", completion: ((Bool, String) -> Void)? = nil) {
        
        if false == _utils.createIndicator() { return }
        
        /*
         회원 ID     USER_ID      STRING    Email로 전달
         로그인 타입   JOIN_TYPE    STRING    Email일 경우 001
         비밀번호     PWD          STRING    MD5로 변환하여 전달(11111 >>> b0baee9d279d34fa1dfd71aadb908c3f)
         유저 타입    USER_TYPE    STRING
         */
        
        let param: Parameters = [
            "USER_ID": userId,
            "PWD": pw,
            "JOIN_TYPE": type,
            "USER_TYPE": userType
        ]
        
        let url = getRequestUrl(body: "/sys/member/app/login.do")
        AF.request(url, method: .post, parameters: param) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            self.printRequestInfo(requestTitle: "[로그인]", response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    
                    if result == "0000" {
                        MyLog.logWithArrow("[로그인] success", result)
                        
                        let userShaToken = jsonValue["sha_token"].stringValue
                        let userSeq = jsonValue["memberInfo"]["user_SEQ"].stringValue
                        let userEmail = jsonValue["memberInfo"]["user_EMAIL"].stringValue
                        let userJoinType = jsonValue["memberInfo"]["join_TYPE"].stringValue
                        let phone = jsonValue["memberInfo"]["dec_USER_HP"].stringValue
                        let userName = jsonValue["memberInfo"]["user_NAME"].stringValue
                        
                        CarryDatas.shared.user.configure(signIn: true, id: userId, pw: pw, name: userName, seq: userSeq, token: userShaToken, email: userEmail, joinType: userJoinType, phone: phone)
                        CarryEvents.shared.callSignInSuccess()
                        self.sendDeviceInfo(userSeq:userSeq, url: jsonValue["resUrl"].stringValue, userName: userName) { (success, msg) in
                            completion?(success, msg)
//                            if success { _utils.getNearbyProvider() }
                        }
                        
                    } else {
                        MyLog.logWithArrow("[로그인] failed", msg)
                        CarryEvents.shared.callSignInFailed()
                        completion?(false, msg)
                    }
                    
                } else {
                    MyLog.logWithArrow("[로그인] failed", msg)
                    CarryEvents.shared.callSignInFailed()
                    completion?(false, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("[로그인] failed", error.localizedDescription)
                CarryEvents.shared.callSignInFailed()
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // 디바이스 정보 전송
    func sendDeviceInfo(userSeq: String, url: String, userName: String, completion: ((Bool, String) -> Void)? = nil) {
        if url.isEmpty {
            MyLog.log("Empty URL.. (Send device info)")
            return
        }
        
        /*
         회원 SEQ              MASTER_SEQ     STRING    회원 로그인 후 SERVER에서 전달 주었던 값 다시 리턴해 주면 됨
         단말기 명칭             DEVICE_NM      STRING
         단말기 버전             DEVICE_VER     STRING
         단말 PUSH_ID          PUSH_ID        STRING
         리액트로 개발된 앱 버전    APP_VER        STRING
         플랫폼 타입             CD_PLATFORM    STRING    A:안드로이드, I:IOS
         */
        
        
        
//        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let deviceName = _utils.deviceModelName()
        let osVersion = UIDevice.current.systemVersion
        let pushId = CarryPush.shared.fcmRegToken
        let appVersion = _utils.getAppVersion()
        let platform = "I"
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "MASTER_SEQ": userSeq,
            "DEVICE_NM": deviceName,
            "DEVICE_VER": osVersion,
            "PUSH_ID": pushId,
            "APP_VER": appVersion,
            "CD_PLATFORM": platform
        ]
        
        let finalUrl = getRequestUrl(body: "/sys/device/setDevice.do")
        
        AF.request(finalUrl, method: .post, parameters: param) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            self.printRequestInfo(requestTitle: "[디바이스 정보 전송]", response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        MyLog.logWithArrow("[디바이스 정보 전송] success", result)
                        completion?(true, userName)
                    } else {
                        MyLog.logWithArrow("[디바이스 정보 전송] failed", msg)
                        completion?(false, msg)
                    }
                    
                } else {
                    MyLog.logWithArrow("[디바이스 정보 전송] failed", msg)
                    completion?(false, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("[디바이스 정보 전송] failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // 메인
    func requestMain(userId: String, shaToken: String, lat: Double?, lng: Double?, completion: ((Bool, String) -> Void)? = nil) {
                
        //-------------------------- Request -------------------------- //
        //
        //      START_LAT               현재 내 위치 좌표
        //      START_LNG               현재 내 위치 좌표
        //      USER_SEQ                사용자 시퀀스
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (saverBizList)
        //      USER_SEQ                사용자 시퀀스
        //      USER_NAME               사용자 이름
        //      MAJOR_ATTACH_INFO       사진정보
        //      REVIEW_POINT_AVG        리뷰 평점
        //      REVIEW_POINT_CNT        리뷰 갯수
        //      DISTANCE                현 위치와의 거리
        //      BIZ_SIMPLE_ADDR         주소
        //      BIZ_DETAIL_ADDR         상세주소
        //
        //      (historyReserveList)
        //      ORDER_KIND_TXT          보관, 운송 텍스트 정보
        //      ORDER_KIND              보관, 운송 코드 정보
        //      SUBSTR_ENTRUST_ADDR     간단 시작 주소
        //      SUBSTR_TAKE_ADDR        간단 종료 주소
        //      ENTRUST_ADDR            시작 주소
        //      ENTRUST_LAT             시작 주소 좌표
        //      ENTRUST_LNG             시작 주소 좌표
        //      TAKE_ADDR               종료 주소
        //      TAKE_LAT                종료 주소 좌표
        //      TAKE_LNG                종료 주소 좌표
        //
        //------------------------------------------------------------- //
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": shaToken,
            "USER_ID": userId,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        var param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "START_LAT": String(describing: lat ?? 0),
            "START_LNG": String(describing: lng ?? 0)
        ]
        
        
        let userSeq = UserDefaults.standard.string(forKey: MyIdentifiers.keyUserSeq.rawValue) ?? ""
        if userSeq.isEmpty == false { param["USER_SEQ"] = userSeq }
        
//        let url = getRequestUrl(body: "/sys/basicMain/app/main.do")
        let url = getRequestUrl(body: "/sys/basicMain/app/mainV3.do")
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[메인]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                
                // 유저 정보 설정
                let userName = UserDefaults.standard.string(forKey: MyIdentifiers.keyUserName.rawValue) ?? ""
                let userSeq = UserDefaults.standard.string(forKey: MyIdentifiers.keyUserSeq.rawValue) ?? ""
                let userEmail = UserDefaults.standard.string(forKey: MyIdentifiers.keyUserEmail.rawValue) ?? ""
                let joinType = UserDefaults.standard.string(forKey: MyIdentifiers.keyUserJoinType.rawValue) ?? ""
                let phone = UserDefaults.standard.string(forKey: MyIdentifiers.keyUserPhone.rawValue) ?? ""
                let pw = UserDefaults.standard.string(forKey: MyIdentifiers.keyUserPw.rawValue) ?? ""
                CarryDatas.shared.user.configure(signIn: true, id: userId, pw: pw, name: userName, seq: userSeq, token: shaToken, email: userEmail, joinType: joinType, phone: phone)
                
                self.binding.bindingMain(json: JSON(value), completion: completion)
                CarryEvents.shared.callUserDataChanged()
                
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                CarryEvents.shared.callSignInFailed()
                completion?(false, error.localizedDescription)
            }
        }
        
    }
    
    // 운송 사업자 상세 (메인 화면의 운송사업자)
    func requestSearchDetailSimple(userSeq: String, driverSeq: String, lat: Double?, lng: Double?, completion: ((Bool, String) -> Void)? = nil) {
        if false == _utils.createIndicator() { return }
        /*      Request
         사용자 시퀀스    USER_SEQ
         운송사업자 시퀀스 DRIVER_USER_SEQ
         맡기는곳 경도    START_LNG
         맡기는곳 위도    START_LAT
         찾는곳 경도     END_LNG
         찾는곳 위도     END_LAT
         미니짐 갯수     S_TYPE
         작은짐 갯수     M_TYPE
         보통짐 갯수     L_TYPE
         큰짐 갯수      XL_TYPE
         
         */
        
        /*      Response
         getReviewList
         평가 시퀀스    REVIEW_SEQ
         평가 점수      REVIEW_POINT
         평가 내용      REVIEW_BODY
         평가 등록일     REVIEW_DATE
         getBoxList
         짐 시퀀스      ORDER_SEQ     1,001,미니짐,5
         짐 종류 코드    ITEM_KIND     2.003, 보통짐,2
         짐 종류 텍스트   ITEM_KIND_TXT
         짐 종료 수량    ITEM_QUANTITY
         */
        
        let startLatStr = String(describing: lat ?? 0)
        let startLngStr = String(describing: lng ?? 0)
        
        let url = getRequestUrl(body: "/sys/userBuy/app/getDriverDetail.do")
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ": userSeq,
            "DRIVER_USER_SEQ": driverSeq,
            "START_LNG": startLngStr,
            "START_LAT": startLatStr,
            "END_LNG": "",
            "END_LAT": "",
            "S_TYPE": "0",
            "M_TYPE": "0",
            "L_TYPE": "0",
            "XL_TYPE": "0",
        ]
        
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            let requestTitle = "[운송사업자(메인화면) 상세 정보]"
            self.printRequestInfo(requestTitle: "\(requestTitle)", response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                
                let jsonValue = JSON(value)
                
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        MyLog.logWithArrow("\(requestTitle) success", result)
                        
                        let oper = CarrySearch.driver
                        let detail = jsonValue["getReserveDriverDetail"]
                        
                        // 근무 시간
                        oper?.workStartTime = detail["WORK_STA_TIME"].stringValue
                        oper?.workStartTime = detail["WORK_OUT_TIME"].stringValue
                        
                        // 평점
                        oper?.rating = detail["REVIEW_POINT_AVG"].floatValue
                        
                        // 소개
                        oper?.pr = detail["CARRYING_ISSUE"].stringValue
                        
                        // 짐 정보
                        if let luggages = jsonValue["getBoxList"].array {
                            for luggage in luggages {
                                let itemType = luggage["ITEM_KIND"].stringValue
                                switch itemType {
                                case "001":
                                    oper?.mini = luggage["ITEM_QUANTITY"].intValue
                                case "002":
                                    oper?.small = luggage["ITEM_QUANTITY"].intValue
                                case "003":
                                    oper?.normal = luggage["ITEM_QUANTITY"].intValue
                                case "004":
                                    oper?.big = luggage["ITEM_QUANTITY"].intValue
                                default:
                                    break
                                }
                            }
                        }
                        
                        // 리뷰
                        if let reviews = jsonValue["getReviewList"].array {
                            if reviews.count > 0 { oper?.reviews.removeAll() }
                            for review in reviews {
                                let seq = review["REVIEW_SEQ"].stringValue
                                let rating = review["REVIEW_POINT"].floatValue
                                let content = review["REVIEW_BODY"].stringValue
                                let name = review["USER_NAME"].stringValue
                                let date = review["REVIEW_DATE"].doubleValue
                                let reviewObj = ReviewSimple(seq: seq, rating: rating, content: content, name: name, date: date)
                                
                                oper?.reviews.append(reviewObj)
                            }
                        }
                        
                        completion?(true, "")
                    } else {
                        MyLog.logWithArrow("\(requestTitle) failed", jsonValue["resMsg"].stringValue)
                        completion?(false, jsonValue["resMsg"].stringValue)
                    }
                    
                    
                } else {
                    MyLog.logWithArrow("\(requestTitle) failed", jsonValue["resMsg"].stringValue)
                    completion?(false, jsonValue["resMsg"].stringValue)
                }
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
        
        
    }
    
    
    // 이메일로 ID 찾기
    func requestFindIDByEmailSend(email: String, completion: ((Bool, String) -> Void)? = nil) {
        
        if false == _utils.createIndicator() { return }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "SEND_ID": email
        ]
        
//        let url = getRequestUrl(body: "/sys/member/app/sendEmailOfFindId.do?SEND_ID=\(email)")
        let url = getRequestUrl(body: "/sys/member/app/sendEmailOfFindId.do")
        AF.request(url, method: .post, parameters: param) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            self.printRequestInfo(requestTitle: "[이메일로 ID 찾기]", response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        MyLog.logWithArrow("[이메일로 ID 찾기] success", result)
                        completion?(true, MyStrings.senfEmailVerificationCode.rawValue)
                    } else {
                        MyLog.logWithArrow("[이메일로 ID 찾기] failed", msg)
                        completion?(false, msg)
                    }
                    
                    
                } else {
                    MyLog.logWithArrow("[이메일로 ID 찾기] failed", msg)
                    completion?(false, jsonValue["resMsg"].stringValue)
                }
            case .failure(let error):
                MyLog.logWithArrow("[이메일로 ID 찾기] failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // 이메일인증 - 코드확인
    func requestFindIDByEmailVerification(email: String, emailCode: String, completion: requestCallbackIdFindForm = nil) {
        if false == _utils.createIndicator() { return }
        //-------------------------- Request -------------------------- //
        //
        //      SEND_ID             이메일 주소
        //      AUTH_NO             인증 문자
        //      ACTION_TYPE         001로 전달
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      USER_TYPE           일반 회원
        //      DATE_C              가입 날짜
        //      JOIN_TYPE           회원 가입 방식
        //      JOIN_TYPE_CODE      회원 가입 방식(코드)
        //      SECRIT_USER_ID      아이디(특정 인덱스에 *표 처리)
        //      USER_ID             아이디
        //
        //------------------------------------------------------------- //
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "SEND_ID": email,
            "AUTH_NO": emailCode,
            "ACTION_TYPE": "001"
        ]
        
        let url = getRequestUrl(body: "/sys/member/app/actionEmailAuthOfFindId.do")
        AF.request(url, method: .post, parameters: param) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in

            self.printRequestInfo(requestTitle: "[이메일로 ID 찾기 - 코드확인]", response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        MyLog.logWithArrow("[이메일로 ID 찾기 - 코드확인] success", result)
                        
                        var idString = ""
                        guard let userIds = jsonValue["userId"].array else { return }
                        
                        var idForms: [IdFindData] = []
                        for userId in userIds {
                            let userType = userId["USER_TYPE"].stringValue
                            let id = userId["USER_ID"].stringValue
                            let date = userId["DATE_C"].stringValue
                            
                            idForms.append(IdFindData(userType: userType, id: id, date: date))
                            idString = id
                        }
                        
                        var message = ""
                        if idString.isEmpty { message = "\(email)으로 등록된 ID가 없습니다" }
                        else                { message = "\(email)으로 등록된 ID:\n\(idString)" }
                        
                        completion?(idForms, message)
                    } else {
                        MyLog.logWithArrow("[이메일로 ID 찾기 - 코드확인] failed", msg)
                        completion?([], msg)
                    }
                    
                    
                } else {
                    MyLog.logWithArrow("[이메일로 ID 찾기 - 코드확인] failed", msg)
                    completion?([], msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("[이메일로 ID 찾기 - 코드확인]", error.localizedDescription)
                completion?([], error.localizedDescription)
            }
        }
    }
    
    // 비밀번호 찾기
    func requestFindPWByEmailSend(userId: String, email: String, completion: ((Bool, String) -> Void)? = nil) {
        if false == _utils.createIndicator() { return }
        
        /*
         이메일 주소    SEND_ID
         사용자 ID    USER_ID
         */
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "SEND_ID": email,
            "USER_ID": userId
        ]
        
        // http://175.126.111.36:8070/sys/member/app/sendEmailOfFindPw.do?SEND_ID=platticskwon@gmail.com&USER_ID=kwon01
//        let url = getRequestUrl(body: "/sys/member/app/sendEmailOfFindPw.do?SEND_ID=\(email)&USER_ID=\(userId)")
        let url = getRequestUrl(body: "/sys/member/app/sendEmailOfFindPw.do")
        AF.request(url, method: .post, parameters: param) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in

            self.printRequestInfo(requestTitle: "[비밀번호 찾기]", response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        MyLog.logWithArrow("[비밀번호 찾기] success", "")
                        completion?(true, "")
                    } else {
                        MyLog.logWithArrow("[비밀번호 찾기] failed", msg)
                        completion?(false, msg)
                    }
                    
                } else {
                    MyLog.logWithArrow("[비밀번호 찾기] failed", msg)
                    completion?(false, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("[비밀번호 찾기] failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // 비밀번호 찾기 코드 인증
    func requestFindPWByEmailVerification(email: String, emailCode: String, type: String,  completion: ((Bool, String) -> Void)? = nil) {
        
        if false == _utils.createIndicator() { return }
        
        /*
         이메일 주소                  SEND_ID
         난수 번호                   AUTH_NO
         이메일인지 전화번호인지 구분값    ACTION_TYPE    001: ID찾기 , 002: 비밀번호 찾기
         */
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "SEND_ID": email,
            "AUTH_NO": emailCode,
            "ACTION_TYPE": type
        ]
        
//        let url = getRequestUrl(body: "/sys/member/app/actionEmailAuthOfFindPw.do?SEND_ID=\(email)&AUTH_NO=\(emailCode)&ACTION_TYPE=\(type)")
        let url = getRequestUrl(body: "/sys/member/app/actionEmailAuthOfFindPw.do")
        AF.request(url, method: .post, parameters: param) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            self.printRequestInfo(requestTitle: "[비밀번호 찾기 - 코드인증]", response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        completion?(true, "")
                    } else {
                        completion?(false, jsonValue["resMsg"].stringValue)
                    }
                    MyLog.logWithArrow("[비밀번호 찾기 - 코드인증] success", result)
                    
                } else {
                    MyLog.logWithArrow("[비밀번호 찾기 - 코드인증] failed", jsonValue["resMsg"].stringValue)
                    completion?(false, jsonValue["resMsg"].stringValue)
                }
            case .failure(let error):
                MyLog.logWithArrow("[비밀번호 찾기 - 코드인증] failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // 비밀번호 변경
    func requestChangePW(userId: String, pw: String, completion: ((Bool, String) -> Void)? = nil) {
        
        if false == _utils.createIndicator() { return }
        
        /*
         사용자 ID       USER_ID
         변경할 패스워드    PWD    MD5로 변환하여 전달(11111 >>> b0baee9d279d34fa1dfd71aadb908c3f)
         */
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_ID": userId,
            "PWD": pw
        ]
        
//        let url = getRequestUrl(body: "/sys/member/app/changePwd.do?USER_ID=\(userId)&PWD=\(pw)")
        let url = getRequestUrl(body: "/sys/member/app/changePwd.do")
        AF.request(url, method: .post, parameters: param) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            self.printRequestInfo(requestTitle: "[비밀번호 변경]", response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        MyLog.logWithArrow("[비밀번호 변경] sucess", result)
                        completion?(true, "")
                    } else {
                        completion?(false, jsonValue["resMsg"].stringValue)
                    }
                    
                    
                } else {
                    MyLog.logWithArrow("[비밀번호 변경] failed", jsonValue["resMsg"].stringValue)
                    completion?(false, jsonValue["resMsg"].stringValue)
                }
            case .failure(let error):
                MyLog.logWithArrow("[비밀번호 변경] failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    func requestReservationSearch(completion: ((Bool, String) -> Void)? = nil) {
        let data = CarryDatas.shared.currentSearchData
        requestReservationSearch(userSeq: CarryDatas.shared.user.seq,
                                          startLat: data.startPoint?.lat,
                                          startLng: data.startPoint?.lng,
                                          endLat: data.endPoint?.lat,
                                          endLng: data.endPoint?.lng,
                                          startDate: data.serviceDate.startDate,
                                          endDate:  data.serviceDate.endDate,
                                          vehicleType: data.serviceTrans.getRequestString(),
                                          sCount: data.serviceLuggage.mini,
                                          mCount: data.serviceLuggage.small,
                                          lCount: data.serviceLuggage.normal,
                                          xlCount: data.serviceLuggage.big) { (success, msg) in
                completion?(success, msg)
        }
    }
    
    // 운반사업자 검색 (예약)
    func requestReservationSearch(userSeq: String, startLat: Double?, startLng: Double?, endLat: Double?, endLng: Double?, startDate: Date?, endDate: Date?, vehicleType: String, sCount: Int, mCount: Int, lCount: Int, xlCount: Int, completion: ((Bool, String) -> Void)? = nil) {
        
        /*
         USER_SEQ
         START_LNG
         START_LAT
         END_LNG
         END_LAT
         START_TIME         10:00:00 타입으로 전달 초는 00으로 샛팅하여도 됨
         END_TIME
         START_DAY          20201201 8자리로 전달
         END_DAY
         VECHILE_TYPE       001 개인, 002 오토바이, 003 차량
         S_TYPE             갯수를 전달하는데 없을경우 0으로 전달
         M_TYPE
         L_TYPE
         XL_TYPE
         REVIEW_POINT_AVG
         page
         */
        
        
        if false == _utils.createIndicator() { return }
        
        // 검색된 사업자의 총 개수가 현재 화면에 보여지는 개수보다 적으면 페이지를 증가시키고 요청한다
        if self.driverTotalCount > self.driverCurrentCount {
            self.driverListPage += 1
        }
        // 검색된 사업자의 총 개수와 현재 화면에 보여지는 개수가 같으면 전부다 보여진 것이기 때문에 요청하지 않는다
        else if (self.driverTotalCount == self.driverCurrentCount) && self.driverCurrentCount > 0 {
            _utils.removeIndicator()
            return
        }
                
        
        let startLatStr = String(describing: startLat ?? 0)
        let startLngStr = String(describing: startLng ?? 0)
        let endLatStr = String(describing: endLat ?? 0)
        let endLngStr = String(describing: endLng ?? 0)

        // 출발 시간 string
        guard let startDate = startDate else {
            _utils.removeIndicator()
            return
        }
        let startDateString = startDate.toString()
        MyLog.log(startDateString)
        let startDateStringArr = startDateString.split(separator: " ").map { (value) -> String in
            return String(value)
        }

        let startDateStr = startDateStringArr[0].replacingOccurrences(of: "-", with: "")
        let startTimeStr = startDateStringArr[1]
        
        // 찾는 시간 string
        guard let endDate = endDate else {
            _utils.removeIndicator()
            return
        }
        
        let endDateString = endDate.toString()
        MyLog.log(endDateString)
        let endDateStringArr = endDateString.split(separator: " ").map { (value) -> String in
            return String(value)
        }
        
        
        
        let endDateStr = endDateStringArr[0].replacingOccurrences(of: "-", with: "")
        let endTimeStr = endDateStringArr[1]
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]

        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ": userSeq,
            "START_LNG": startLngStr,
            "START_LAT": startLatStr,
            "END_LNG": endLngStr,
            "END_LAT": endLatStr,
            "START_TIME": startTimeStr,
            "END_TIME": endTimeStr,
            "START_DAY": startDateStr,
            "END_DAY": endDateStr,
            "VECHILE_TYPE": vehicleType,
            "S_TYPE": String(sCount),
            "M_TYPE": String(mCount),
            "L_TYPE": String(lCount),
            "XL_TYPE": String(xlCount),
            "page": String(driverListPage)
        ]
        
        let url = getRequestUrl(body: "/sys/userBuy/app/getReserveSrcList.do")
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            self.printRequestInfo(requestTitle: "[운반사업자 검색 (예약)]", response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                
                let jsonValue = JSON(value)
                
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        
                        let count = jsonValue["totalCnt"].intValue
                        self.driverTotalCount = count
                        
                        guard let arr = jsonValue["gerReserveDriverList"].array else { return }
                        
                        self.setDriver(jsonArray: arr, removeCurrentDrivers: false)
                        
                        // 전체 목록 수(driverTotalCount)와 마지막 운송사업자의 rowNum(driverCurrentCount)이 일치하지 않을때가 있는데 이렇게 되면 무한루프에 빠진다
                        // 무한 루프에 빠지는 것을 방지하기 위해 값을 일치시킨다.
                        if arr.isEmpty && self.driverTotalCount != self.driverCurrentCount {
                            self.driverTotalCount = self.driverCurrentCount
                        }
                        
                        completion?(true, "")
                    } else {
                        completion?(false, jsonValue["resMsg"].stringValue)
                    }
                    MyLog.logWithArrow("Request email verification code success", result)
                    
                } else {
                    MyLog.logWithArrow("Request email verification code failed", jsonValue["resMsg"].stringValue)
                    completion?(false, jsonValue["resMsg"].stringValue)
                }
            case .failure(let error):
                MyLog.logWithArrow("Request email verification code failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    func setDriver(jsonArray: [SwiftyJSON.JSON], removeCurrentDrivers: Bool) {
        
        if removeCurrentDrivers { CarrySearch.drivers.removeAll() }
        
        for oper in jsonArray {
            let driver = Driver()
            driver.attachSeq = oper["ATTACH_SEQ"].stringValue
            driver.masterSeq = oper["MASTER_SEQ"].stringValue
            driver.userSeq = oper["USER_SEQ"].stringValue
            driver.possibleRate = oper["POSSIBLE_RATE"].intValue
            driver.cost = oper["PRO_PRICE"].intValue
            driver.rateType = oper["RATE_TYPE"].stringValue
            driver.name = oper["USER_NAME"].stringValue
            driver.vehicleType = oper["VECHILE_TYPE"].stringValue
            driver.vehicleTypeName = oper["VECHILE_TYPE_NAME"].stringValue
            driver.rating = oper["REVIEW_POINT_AVG"].floatValue
            driver.dealSeq = String(oper["DEAL_SEQ"].int ?? 0)
            
            let row = oper["row_num"].intValue
            driver.row = row
            driverCurrentCount = row
            
            var imgUrl = oper["ATTACH_INFO"].stringValue
            if imgUrl.isEmpty { imgUrl = oper["USER_ATTACH_INFO"].stringValue }
            if imgUrl.isEmpty == false {
                imgUrl = self.getRequestUrl(body: imgUrl)
                
                let url = URL(string: imgUrl)!
                
                do {
                    let data = try Data(contentsOf: url)
                    driver.img = data
                } catch {
                    MyLog.log("Delivery oper img download failed..")
                }
                
            }
            driver.imgUrl = imgUrl
            
            CarrySearch.drivers.append(driver)
        }
    }
    
    
    // 운송 사업자 상세
    func requestDriverDetail(userSeq: String, driverSeq: String, dealSeq: String, startDate: Date?, startLat: Double?, startLng: Double?, endDate: Date?, endLat: Double?, endLng: Double?, sCount: Int, mCount: Int, lCount: Int, xlCount: Int, completion: ((Bool, String) -> Void)? = nil) {
        if false == _utils.createIndicator() { return }
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            사용자 시퀀스
        //      DEAL_SEQ
        //      DRIVER_USER_SEQ     운송사업자 시퀀스
        //      DEAL_SEQ            딜 시퀀스
        //      START_LNG           맡기는곳 경도
        //      START_LAT           맡기는곳 위도
        //      END_LNG             찾는곳 경도
        //      END_LAT             찾는곳 위도
        //      S_TYPE              미니짐 갯수
        //      M_TYPE              작은짐 갯수
        //      L_TYPE              보통짐 갯수
        //      XL_TYPE             큰짐 갯수
        //
        // ------------------------------------------------------------- //
        //
        // -------------------------- Response -------------------------- //
        //
        //      (getReviewList)
        //      REVIEW_SEQ          평가 시퀀스
        //      REVIEW_POINT        평가 점수
        //      REVIEW_BODY         평가 내용
        //      REVIEW_DATE         평가 등록일
        //
        //      (getBoxList)
        //      ORDER_SEQ           짐 시퀀스       1,001, 미니짐,5
        //      ITEM_KIND           짐 종류 코드     2.003, 보통짐,2
        //      ITEM_KIND_TXT       짐 종류 텍스트
        //      ITEM_QUANTITY       짐 종료 수량
        //
        //      POSSIBLE_RATE       적재 가용비율
        //      USER_SEQ            사용자 시퀀스
        //      MASTER_SEQ          마스터 사용자 시퀀스
        //      USER_NAME           운송 사업자 명
        //      VECHILE_TYPE        운송 수단 코드
        //      VECHILE_TYPE_NAME   운송 수단 명
        //      PRO_PRICE           운송 비용
        //      ATTACH_INFO         운송 사용자 대표 사진
        //      CARRYING_ISSUE      비고(주가내용)
        //      WORK_STA_TIME       근무 시작시간
        //      WORK_OUT_TIME       근무 종료 시간
        //      REVIEW_POINT_AVG    평점
        //
        // -------------------------------------------------------------- //
        
        
        // 출발 시간 string
        guard let startDate = startDate else {
            _utils.removeIndicator()
            return
        }
        let startDateString = startDate.toString()
        MyLog.log(startDateString)
        let startDateStringArr = startDateString.split(separator: " ").map { (value) -> String in
            return String(value)
        }

        let startDateStr = startDateStringArr[0].replacingOccurrences(of: "-", with: "")
        let startTimeStr = startDateStringArr[1]
        
        // 찾는 시간 string
        guard let endDate = endDate else {
            _utils.removeIndicator()
            return
        }
        
        let endDateString = endDate.toString()
        MyLog.log(endDateString)
        let endDateStringArr = endDateString.split(separator: " ").map { (value) -> String in
            return String(value)
        }
        
        let endDateStr = endDateStringArr[0].replacingOccurrences(of: "-", with: "")
        let endTimeStr = endDateStringArr[1]
        
        
        
        let startLatStr = String(describing: startLat ?? 0)
        let startLngStr = String(describing: startLng ?? 0)
        let endLatStr = String(describing: endLat ?? 0)
        let endLngStr = String(describing: endLng ?? 0)
    
        
        let url = getRequestUrl(body: "/sys/userBuy/app/getReserveSrcDetail.do")
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ": userSeq,
            "DRIVER_USER_SEQ": driverSeq,
            "DEAL_SEQ": dealSeq,
            "START_LNG": startLngStr,
            "START_LAT": startLatStr,
            "END_LNG": endLngStr,
            "END_LAT": endLatStr,
            "START_TIME": startTimeStr,
            "START_DAY": startDateStr,
            "END_TIME": endTimeStr,
            "END_DAY": endDateStr,
            "S_TYPE": String(sCount),
            "M_TYPE": String(mCount),
            "L_TYPE": String(lCount),
            "XL_TYPE": String(xlCount)
        ]
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            self.printRequestInfo(requestTitle: "[운송사업자 상세 정보]", response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                self.binding.bindingDriverDetail(json: JSON(value), completion: completion)
                
            case .failure(let error):
                MyLog.logWithArrow("[운송사업자 상세 정보] failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    func requestPurchasing(driverMasterSeq: String, driverSeq: String, saverSeq: String, userSeq: String, vehicleType: String, orderKind: String, payMethod: String, startAddress: String, startDate: Date?, endAddress: String, endDate: Date?, buyerName: String, buyerPhone: String, buyerMemo: String, startLat: Double?, startLng: Double?, endLat: Double?, endLng: Double?, sCount: Int, mCount: Int, lCount: Int, xlCount: Int, cost: Int, imageDatas: [Data?], dealSeq: String, dealSeqOrder: String, paymentType: String, startPointSeq: String, endPointSeq: String, saverType: String = "", saverTime: String = "", attachGrpSeq: String = "", completion: ((Bool, String) -> Void)? = nil) {
        
        if false == _utils.createIndicator() { return }
        
        // -------------------------- Request -------------------------- //
        //
        //      DRIVER_MASTER_SEQ       운송사업자 마스터 시퀀스, 보관사업자 마스터 시퀀스
        //      DRIVER_USER_SEQ         운송사업자 시퀀스 (보관 사업자일 경우 0 전달)
        //      SAVER_USER_SEQ          보관사업자 시퀀스
        //      USER_SEQ                사용자 시퀀스
        //      VECHILE_TYPE            운송수단 타입
        //      ORDER_KIND              주문 유형
        //      PAY_METHOD              주문방식
        //      ENTRUST_ADDR            맡기는곳 주소
        //      ENTRUST_DATE            맡기는 날짜
        //      TAKE_ADDR               찾는곳 주소
        //      TAKE_DATE               찾는곳 날짜
        //      START_TIME
        //      END_TIME
        //      BUYER_NAME              주문자 이름
        //      BUYER_PHONE             주문자 전화번호
        //      BUYER_MEMO              주문시 유의사항
        //      START_LNG               맡기는곳 경도
        //      START_LAT               맡기는곳 위도
        //      END_LNG                 찾는곳 경도
        //      END_LAT                 찾는곳 위도
        //      S_TYPE                  미니짐 갯수
        //      M_TYPE                  작은짐 갯수
        //      L_TYPE                  보통짐 갯수
        //      XL_TYPE                 큰짐 갯수
        //      fileList
        //      module
        //      ATTACH_TYPE
        //      DEAL_SEQ                요청 시퀀스 (가격요청일 경우에만 DEAL_SEQ를 전달하고 나머지 경우는 0으로 전달한다)
        //      DEAL_SEQ_ORDER          요청 시퀀스 (예약일때에만 0 전달, 가격요청/오늘운송일 경우 DEAL_SEQ 전달)
        //      PRO_COST                결제 금액
        //
        //      PAYMENT_TYPE            결제 타입
        //      ENTRUST_BASE_SEQ        맡기는 캐리어베이스 사업자 코드
        //      TAKE_BASE_SEQ           찾는 캐리어베이스 사업자 코드
        //      SAVER_TYPE              결제 주문 시간 종류(보관일 경우)
        //      SAVER_TIME              결제 주문 시간(보관일 경우)
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        // ------------------------------------------------------------- //
        
        
        
        let startLatStr = String(describing: startLat ?? 0)
        let startLngStr = String(describing: startLng ?? 0)
        let endLatStr = String(describing: endLat ?? 0)
        let endLngStr = String(describing: endLng ?? 0)

        // 출발 시간 string
        guard let startDate = startDate else {
            _utils.removeIndicator()
            return
        }
        let startDateString = startDate.toString()
        MyLog.log(startDateString)
        let startDateStringArr = startDateString.split(separator: " ").map { (value) -> String in
            return String(value)
        }

        let startDateStr = startDateStringArr[0]//.replacingOccurrences(of: "-", with: "")
        let startTimeStr = startDateStringArr[1]
        let startTotalStr = "\(startDateStr) \(startTimeStr)"
        
        // 찾는 시간 string
        guard let endDate = endDate else {
            _utils.removeIndicator()
            return
        }
        let endDateString = endDate.toString()
        MyLog.log(endDateString)
        let endDateStringArr = endDateString.split(separator: " ").map { (value) -> String in
            return String(value)
        }
        
        let endDateStr = endDateStringArr[0]//.replacingOccurrences(of: "-", with: "")
        let endTimeStr = endDateStringArr[1]
        let endTotalStr = "\(endDateStr) \(endTimeStr)"
        
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        var param: [String: String] = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "DRIVER_MASTER_SEQ": driverMasterSeq,
            "DRIVER_USER_SEQ": driverSeq,
            "SAVER_USER_SEQ": saverSeq,
            "USER_SEQ": userSeq,
            "VECHILE_TYPE": vehicleType,
            "ORDER_KIND": orderKind,
            "PAY_METHOD": payMethod,
            "ENTRUST_ADDR": startAddress,
            "ENTRUST_DATE": startTotalStr,
            "TAKE_ADDR": endAddress,
            "TAKE_DATE": endTotalStr,
            "START_TIME": startTimeStr,
            "END_TIME": endTimeStr,
            "BUYER_NAME": buyerName,
            "BUYER_PHONE": buyerPhone,
            "BUYER_MEMO": buyerMemo,
            "START_LNG": startLngStr,
            "START_LAT": startLatStr,
            "END_LNG": endLngStr,
            "END_LAT": endLatStr,
            "S_TYPE": String(sCount),
            "M_TYPE": String(mCount),
            "L_TYPE": String(lCount),
            "XL_TYPE": String(xlCount),
            "DEAL_SEQ": dealSeq,
            "DEAL_SEQ_ORDER": dealSeqOrder,
            "PRO_COST": String(cost),
            "PAYMENT_TYPE": paymentType,
            "ENTRUST_BASE_SEQ": startPointSeq,
            "TAKE_BASE_SEQ": endPointSeq,
            "SAVER_TYPE": saverType,
            "SAVER_TIME": saverTime,
            "module": "3"
        ]
        
        if false == attachGrpSeq.isEmpty {
            param["ATTACH_GRP_SEQ"] = attachGrpSeq
        }
        
        /*
        MyLog.logWithArrow("[결제요청] request parameter", "")
        for pair in param {
            print("\(pair.key): \(pair.value)")
        }
        */
        
        
        let attach = "ATTACH_TYPE"
        let attachType = "009"
        let urlString = "/sys/payment/app/payMajorProcess.do"
        
        let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""      // 한글 encoding
        let url = getRequestUrl(body: encodedUrlString)
        
        // 요청
        AF.upload(multipartFormData: { multipartFormData in
            // multipart 데이터 생성 (parameters)
            for (key, value) in param {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            
            // multipart 데이터 생성 (images)
            for (index, data) in imageDatas.enumerated() {
                guard let imgData = data else { continue }
                multipartFormData.append(imgData, withName: "fileList", fileName: "\(index).jpg", mimeType: "image/jpeg")
                multipartFormData.append(attachType.data(using: .utf8)!, withName: attach)
            }
            
        }, to: url, method: .post, headers: headers)
         { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            self.printRequestInfo(requestTitle: "[결제요청]", response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                if let result = jsonValue["resCd"].string {
                    
                    if result == "0000" {
                        let oderSeq = jsonValue["resMsg"].stringValue
                        completion?(true, oderSeq)
                    } else {
                        completion?(false, jsonValue["resMsg"].stringValue)
                    }
                    
                    MyLog.logWithArrow("[결제요청] response", result)
                    
                } else {
                    MyLog.logWithArrow("[결제요청] response", jsonValue["resMsg"].stringValue)
                    completion?(false, jsonValue["resMsg"].stringValue)
                }
            case .failure(let error):
                MyLog.logWithArrow("[결제요청] failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
        
        
    }
    
    func removeSearchCache() {
        driverListPage = 1
        driverTotalCount = 0
        driverCurrentCount = 0
        
        storageListPage = 1
        storageTotalCount = 0
        storageCurrentCount = 0
        
        if false == CarrySearch.isLocal {
            CarrySearch.driver = nil
            CarrySearch.drivers.removeAll()
            CarrySearch.storage = nil
            CarrySearch.storages.removeAll()
        }
    }
    
    func requestSignOut(completion: ((Bool, String) -> Void)? = nil) {
        /*
         회원 토큰    USER_TOKEN
         회원 아이디    USER_ID
         */
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_TOKEN": CarryDatas.shared.user.token,
            "USER_ID": CarryDatas.shared.user.id
        ]
        
        let urlString = "/sys/member/app/logout.do"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            self.printRequestInfo(requestTitle: "[로그아웃]", response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        
                        CarryDatas.shared.user.removeData()
                        CarrySocial.shared.signOut()
                        CarryEvents.shared.callSignOutSuccess()
                        
                        completion?(true, MyStrings.signOutDone.rawValue)
                    } else {
                        completion?(false, jsonValue["resMsg"].stringValue)
                    }
                    MyLog.log("[로그아웃] 성공")
                    
                } else {
                    MyLog.logWithArrow("[로그아웃] 실패", jsonValue["resMsg"].stringValue)
                    completion?(false, jsonValue["resMsg"].stringValue)
                }
            case .failure(let error):
                MyLog.logWithArrow("[로그아웃] 실패", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
        
    }
    
    
    
    func requestFinishPurchasing(purchasingData: PurchasingData, completion: ((Bool, String) -> Void)? = nil) { //(userSeq: String, startLat: Double?, startLng: Double?, endLat: Double?, endLng: Double?, sCount: Int, mCount: Int, lCount: Int, xlCount: Int, completion: ((Bool, String) -> Void)? = nil) {
        
        if false == _utils.createIndicator() { return }
        
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            유저 시퀀스
        //      SAVER_USER_SEQ      보관사업자 시퀀스
        //      ORDER_KIND          주문 유형
        //      START_TIME          물건 맡기는 시간
        //      END_TIME            물건 찾는 시간
        //      SAVER_TIME          결제 주문 시간 (보관일 경우)
        //      SAVER_TYPE          결제 주문 시간 타입 (보관일 경우)
        //      DRIVER_USER_SEQ     결제 전문 번호?
        //      imp_uid             아임포트 uid
        //      START_LNG           맡기는곳 경도
        //      START_LAT           맡기는곳 위도
        //      END_LNG             찾는곳 경도
        //      END_LAT             찾는곳 위도
        //      S_TYPE              미니짐 갯수
        //      M_TYPE              작은짐 갯수
        //      L_TYPE              보통짐 갯수
        //      XL_TYPE             큰짐 갯수
        //      ORDER_SEQ           상품 결제 금액
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        // ------------------------------------------------------------- //
        
       
        let startLatStr = String(describing: purchasingData.startPointLat)
        let startLngStr = String(describing: purchasingData.startPointLng)
        let endLatStr = String(describing: purchasingData.endPointLat)
        let endLngStr = String(describing: purchasingData.endPointLng)
        
        var url = getRequestUrl(body: "/sys/payment/app/payFinishProcess.do")
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        // 보관 시간
        var storageRequestTime = ""
        if purchasingData.storageRequestTime > 0 { storageRequestTime = String(purchasingData.storageRequestTime) }
        
        // 맡기는 시간, 찾는 시간
        let startDateString = getDateAndTime(date: purchasingData.startDate, removeDash: false)
//        let startDate = startDateString[0]
        let startTime = startDateString[1]
        
        let endDateString = getDateAndTime(date: purchasingData.endDate, removeDash: false)
//        let endDate = endDateString[0]
        let endTime = endDateString[1]
        
        var param: Parameters = [:]
        
        if TEST_PURCHASING {
            param = [
                      "USER_TYPE": CarrifreeAppType.appUser.user,
                      "USER_SEQ": CarryUser.seq,
                      "ORDER_SEQ": purchasingData.orderSeq
            ]
        } else {
            param = [ "USER_TYPE": CarrifreeAppType.appUser.user,
                      "USER_SEQ": CarryUser.seq,
//                  "DEAL_SEQ": purchasingData.dealSeq,
                      "SAVER_USER_SEQ": purchasingData.storageSeq,
                      "ORDER_KIND": purchasingData.orderKind,
                      "SAVER_TIME": storageRequestTime,
                      "SAVER_TYPE": purchasingData.dayType,
                      "ORDER_SEQ": purchasingData.orderSeq,
                      "DRIVER_USER_SEQ": purchasingData.driverSeq,
                      "imp_uid": purchasingData.impUid,
                      "START_TIME": startTime,
                      "END_TIME": endTime,
                      "START_LNG": startLngStr,
                      "START_LAT": startLatStr,
                      "END_LNG": endLngStr,
                      "END_LAT": endLatStr,
                      "S_TYPE": purchasingData.mini,
                      "M_TYPE": purchasingData.small,
                      "L_TYPE": purchasingData.normal,
                      "XL_TYPE": purchasingData.big
            ]
        }
        
        if purchasingData.isDirectDelivery {
            url = getRequestUrl(body: "/sys/payment/app/directPayFinishProcess.do")     // 직영 운반사업자에대한 결제일 경우 해당 url로 변경
        } else {
            param["DEAL_SEQ"] = purchasingData.dealSeq                                  // 직영 운반사업자에대한 결제가 아니면 파라미터에 DEAL_SEQ 추가
        }
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[결제 완료 보고]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        MyLog.logWithArrow("\(requestTitle) success", result)
                        completion?(true, "")
                    } else {
                        MyLog.logWithArrow("\(requestTitle) failed", msg)
                        completion?(false, jsonValue["resMsg"].stringValue)
                    }
                    
                } else {
                    MyLog.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // 오늘운송(실시간) 의뢰
    func requestRealtimeSearch(completion: ((Bool, String) -> Void)? = nil) {
        let searchData = CarryDatas.shared.currentSearchData
        let operData = CarrySearch.driver
        
        var startPointSeq = CarrySearch.startBaseSeq
        if startPointSeq.isEmpty { startPointSeq = "0" }
        
        var endPointSeq = CarrySearch.endBaseSeq
        if endPointSeq.isEmpty { endPointSeq = "0" }
        
         CarryRequest.shared.requestRealtimeSearch(userSeq: CarryDatas.shared.user.seq,
                                                            vehicleType: searchData.serviceTrans.getRequestString(),
                                                            orderKind: searchData.serviceDetail.type,
                                                            startAddress: searchData.startPoint?.getRequestString() ?? "",
                                                            startDate: searchData.serviceDate.startDate,
                                                            endAddress: searchData.endPoint?.getRequestString() ?? "",
                                                            endDate: searchData.serviceDate.endDate,
                                                            startLat: searchData.startPoint?.lat,
                                                            startLng: searchData.startPoint?.lng,
                                                            endLat: searchData.endPoint?.lat,
                                                            endLng: searchData.endPoint?.lng,
                                                            sCount: searchData.serviceLuggage.mini,
                                                            mCount: searchData.serviceLuggage.small,
                                                            lCount: searchData.serviceLuggage.normal,
                                                            xlCount: searchData.serviceLuggage.big,
                                                            cost: operData?.cost ?? 0,
                                                            imageDatas: searchData.selectedImg,
                                                            buyerName: CarryUser.name,
                                                            buyerPhone: CarryUser.phone,
                                                            buyerMemo: CarrySearch.comment,
                                                            paymentType: CarrySearch.getPaymentType(),
                                                            startPointSeq: startPointSeq,
                                                            endPointSeq: endPointSeq) { (success, msg) in
                completion?(success, msg)
         }
    }
    
   
    // 오늘운송(실시간) 목록 요청
    func requestRealtimeSearch(userSeq: String, vehicleType: String, orderKind: String, startAddress: String, startDate: Date?, endAddress: String, endDate: Date?, startLat: Double?, startLng: Double?, endLat: Double?, endLng: Double?, sCount: Int, mCount: Int, lCount: Int, xlCount: Int, cost: Int, imageDatas: [Data?], buyerName: String, buyerPhone: String, buyerMemo: String, paymentType: String, startPointSeq: String, endPointSeq: String, completion: ((Bool, String) -> Void)? = nil) {
        
        if false == _utils.createIndicator() { return }
        
        /*
         USER_SEQ               사용자 시퀀스
         VECHILE_TYPE           운송수단 타입
         DEAL_KIND              주문 유형
         ENTRUST_ADDR           맡기는곳 주소
         ENTRUST_DATE           맡기는 날짜
         TAKE_ADDR              찾는곳 주소
         TAKE_DATE              찾는곳 날짜
         START_LNG              맡기는곳 경도
         START_LAT              맡기는곳 위도
         END_LNG                찾는곳 경도
         END_LAT                찾는곳 위도
         S_TYPE                 미니짐 갯수
         M_TYPE                 작은짐 갯수
         L_TYPE                 보통짐 갯수
         XL_TYPE                큰짐 갯수
         fileList
         module
         ATTACH_TYPE
         
         BUYER_NAME             주문자 이름
         BUYER_PHONE            주문자 전화번호
         BUYER_MEMO             주문시 유의사항
         PAYMENT_TYPE           결제 타입 ("001"   출발지점, 도착지점 모두 캐리어 베이스 아님
                                         "002"   출발지점, 도착지점 모두 캐리어 베이스
                                         "003"   출발지점만 캐리어 베이스
                                         "004"   도착지점만 캐리어 베이스)

         ENTRUST_BASE_SEQ       맡기는 캐리어베이스 사업자 코드
         TAKE_BASE_SEQ          찾는 캐리어베이스 사업자 코드
         
         
         */
        
        
        let startLatStr = String(describing: startLat ?? 0)
        let startLngStr = String(describing: startLng ?? 0)
        let endLatStr = String(describing: endLat ?? 0)
        let endLngStr = String(describing: endLng ?? 0)

        // 출발 시간 string
        guard let startDate = startDate else {
            _utils.removeIndicator()
            return
        }
        let startDateString = startDate.toString()
        MyLog.log(startDateString)
        let startDateStringArr = startDateString.split(separator: " ").map { (value) -> String in
            return String(value)
        }

        let startDateStr = startDateStringArr[0]//.replacingOccurrences(of: "-", with: "")
        let startTimeStr = startDateStringArr[1]
        let startTotalStr = "\(startDateStr) \(startTimeStr)"
        
        // 찾는 시간 string
        guard let endDate = endDate else {
            _utils.removeIndicator()
            return
        }
        let endDateString = endDate.toString()
        MyLog.log(endDateString)
        let endDateStringArr = endDateString.split(separator: " ").map { (value) -> String in
            return String(value)
        }
        
        let endDateStr = endDateStringArr[0]//.replacingOccurrences(of: "-", with: "")
        let endTimeStr = endDateStringArr[1]
        let endTotalStr = "\(endDateStr) \(endTimeStr)"
        
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: [String: String] = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ": userSeq,
            "VECHILE_TYPE": vehicleType,
            "DEAL_KIND": orderKind,
            "ENTRUST_ADDR": startAddress,
            "ENTRUST_DATE": startTotalStr,
            "TAKE_ADDR": endAddress,
            "TAKE_DATE": endTotalStr,
            "START_LNG": startLngStr,
            "START_LAT": startLatStr,
            "END_LNG": endLngStr,
            "END_LAT": endLatStr,
            "S_TYPE": String(sCount),
            "M_TYPE": String(mCount),
            "L_TYPE": String(lCount),
            "XL_TYPE": String(xlCount),
            "BUYER_NAME": buyerName,
            "BUYER_PHONE": buyerPhone,
            "BUYER_MEMO": buyerMemo,
            "PAYMENT_TYPE": paymentType,
            "ENTRUST_BASE_SEQ": startPointSeq,
            "TAKE_BASE_SEQ": endPointSeq,
            "module": "3"
        ]
        
        let attach = "ATTACH_TYPE"
        let attachType = "009"
        let urlString = "/sys/payment/app/todayTransProcess.do"
        let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""      // 한글 encoding
        let url = getRequestUrl(body: encodedUrlString)
        
        
        // 요청
        AF.upload(multipartFormData: { multipartFormData in
            
            // multipart 데이터 생성 (parameters)
            for (key, value) in param {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            
            // multipart 데이터 생성 (images)
            for (index, data) in imageDatas.enumerated() {
                guard let imgData = data else { continue }
                multipartFormData.append(imgData, withName: "fileList", fileName: "\(index).jpg", mimeType: "image/jpeg")
                multipartFormData.append(attachType.data(using: .utf8)!, withName: attach)
            }
            
        }, to: url, method: .post, headers: headers)
         { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[오늘배송 의뢰]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    
                    if result == "0000" {
                        MyLog.logWithArrow("\(requestTitle) success", "DEAL_SEQ: \(msg)")
                        CarryDatas.shared.user.requestDealSeq = msg
                        completion?(true, msg)
                    } else {
                        MyLog.logWithArrow("\(requestTitle) failed", msg)
                        completion?(false, msg)
                    }
                    
                } else {
                    MyLog.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
        
        
    }
    
    // 오늘운송 수락한 사업자 목록 조회
    //func requestRealTimeAcceptList(endTime: Date?, completion: ((Bool, String) -> Void)? = nil) {
    func requestRealtimeAcceptList(startDate: Date?, endDate: Date?, startLat: Double?, startLng: Double?, endLat: Double?, endLng: Double?, sCount: Int, mCount: Int, lCount: Int, xlCount: Int, completion: ((Bool, String) -> Void)? = nil) {
        if false == _utils.createIndicator() { return }
        
        /*      Request
         
        사용자 시퀀스    USER_BUYER_SEQ
        요청 시퀀스     DEAL_SEQ             todayTransProcess.do - resMsg에서 받은 seq
         
         
         
         USER_BUYER_SEQ         사용자 시퀀스
         DEAL_SEQ               딜 시퀀스
         ENTRUST_DATE           맡기는 날짜
         TAKE_DATE              찾는곳 날짜
         START_LNG              맡기는곳 경도
         START_LAT              맡기는곳 위도
         END_LNG                찾는곳 경도
         END_LAT                찾는곳 위도
         S_TYPE                 미니짐 갯수
         M_TYPE                 작은짐 갯수
         L_TYPE                 보통짐 갯수
         XL_TYPE                큰짐 갯수
        */
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        // 출발 시간 string
        let startDateTime = getDateAndTime(date: startDate, removeDash: false)
        let startDateStr = "\(startDateTime[0]) \(startDateTime[1])"
        
        
        // 찾는 시간 string
        let endDateTime = getDateAndTime(date: endDate, removeDash: false)
        let endDateStr = "\(endDateTime[0]) \(endDateTime[1])"
        
        // 좌표
        let startLat = String(describing: startLat ?? 0)
        let startLng = String(describing: startLng ?? 0)
        let endLat = String(describing: endLat ?? 0)
        let endLng = String(describing: endLng ?? 0)
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_BUYER_SEQ": CarryDatas.shared.user.seq,
            "DEAL_SEQ": "0",//CarryDatas.shared.user.requestDealSeq,
            "ENTRUST_DATE": startDateStr,
            "TAKE_DATE": endDateStr,
            "START_LNG": startLng,
            "START_LAT": startLat,
            "END_LNG": endLng,
            "END_LAT": endLat,
            "S_TYPE": sCount,
            "M_TYPE": mCount,
            "L_TYPE": lCount,
            "XL_TYPE": xlCount
        ]
        
        let urlString = "/sys/userBuy/app/getTodayAcceptList.do"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[오늘배송 수락한 사업자 목록 조회]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        MyLog.log("\(requestTitle) success")
                        guard let arr = jsonValue["gerReserveDriverList"].array else { return }
                        self.setDriver(jsonArray: arr, removeCurrentDrivers: true)
                        completion?(true, "")
                    } else {
                        MyLog.logWithArrow("\(requestTitle) failed", msg)
                        completion?(false, msg)
                    }
                    
                } else {
                    MyLog.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
        
    }
    
    // 신청내역(결제 완료 목록) 요청
    func requestHistory(completion: ((Bool, String) -> Void)? = nil) {
        
        if false == _utils.createIndicator() { return }
        
        
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ_BUYER          사용자 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      (운송 서비스 신청 목록)
        //      ORDER_SEQ               결제 시퀀스
        //      USER_NAME               운송사업자 명
        //      ORDER_DATE              결제 요청일
        //      ENTRUST_DATE            맡기고 찾는 희망 일자
        //      ENTRUST_ADDR            맡기는곳 장소
        //      TAKE_ADDR               찾는곳 장소
        //      ORDER_STATUS            결제 상태                           *ORDER_STATUS
        //      TOTAL_AMOUNT            총 결제 금액                         002 : 결제 완료(최초상태)
        //                                                                006 : 사용자가 짐을 맡기고 난후 처리 상태
        //                                                                004 : 운송사업자가 짐을 받아 배송중인 상태
        //                                                                005 : 운송사업자가 짐을 배송 완료한 상태
        //                                                                008 : 사용자가 짐을 찾아 업무가 종료된 상태
        //                                                                003 : 주문이 취소된 상태
        //
        //      (보관 서비스 신청 목록)
        //      ORDER_SEQ               결제 시퀀스
        //      ORDER_DATE              신청 내용(날짜)
        //      ENTRUST_DATE            보관일시
        //      BIZ_SIMPLE_ADDR         보관장소 간편 주소
        //      BIZ_DETAIL_ADDR         보관장소 상세 주소
        //      BIZ_LAT                 보관장소 좌표                        *ORDER_STATUS
        //      BIZ_LNG                 보관장소 좌표                         002 : 결제 완료(최초상태)
        //      ORDER_STATUS            결제 상태                            006 : 사용자가 짐을 맡기고 난후 처리 상태
        //      TOTAL_AMOUNT            의뢰 비용                            008 : 사용자가 짐을 찾아 업무가 종료된 상태
        //      CARRYING_DISTANCE       보관 시간                            007 : 운송사업자든 일반사용자든 짐을 찾기 위해 인증하는 상태
        //      AUTH_NO                 짐 찾기 위한 비밀번호
        //
        // ------------------------------------------------------------- //
        
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ_BUYER": CarryDatas.shared.user.seq
        ]
        
        let urlString = "/sys/payment/app/getAuthPaymentList.do"
//        let urlString = "/sys/payment/app/getAuthPaymentList.do?USER_SEQ_BUYER=\(CarryDatas.shared.user.seq)"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[신청내역 요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        
                        let paymentList = jsonValue["authPaymentList"].arrayValue
                        CarryDatas.shared.user.deliveryHistory.removeAll()
                        
                        for payment in paymentList {
                            let startPointAddress = payment["ENTRUST_ADDR"].stringValue
                            let dueDate = payment["ENTRUST_DATE"].stringValue
                            let requestDate = payment["ORDER_DATE"].stringValue
                            let orderSeq = payment["ORDER_SEQ"].stringValue
                            let orderStatus = payment["ORDER_STATUS"].stringValue
                            let endPointAddress = payment["TAKE_ADDR"].stringValue
                            let cost = payment["TOTAL_AMOUNT"].stringValue
                            let driverName = payment["USER_NAME"].stringValue
                            let pw = payment["AUTH_NO"].stringValue
                            let orderType = payment["BUSINESS_TYPE"].stringValue
                            let review = payment["REVIEW_BODY"].stringValue
                            let reviewSeq = payment["REVIEW_BODY_SEQ"].stringValue
                            let reply = payment["RE_REVIEW_BODY"].stringValue
                            let replySeq = payment["RE_REVIEW_BODY_SEQ"].stringValue
                            let phone = payment["DEC_USER_HP_NO"].stringValue
                            let rating = payment["REVIEW_POINT"].floatValue
                            let driverSeq = payment["USER_SEQ"].stringValue
                            
                            let history = DeliveryHistory(driverSeq: driverSeq, startPointAddress: startPointAddress, dueDate: dueDate, requestDate: requestDate, orderSeq: orderSeq, orderStatus: orderStatus, endPointAddress: endPointAddress, cost: cost, driverName: driverName, pw: pw, orderType: orderType, phone: phone, review: review, reviewSeq: reviewSeq, reply: reply, replySeq: replySeq, rating: rating)
                            
                            CarryUser.deliveryHistory.append(history)
                        }
                        
                        
                        let storagePaymentList = jsonValue["authSavePaymentList"].arrayValue
                        CarryDatas.shared.user.storageHistory.removeAll()
                        
                        for storagePayment in storagePaymentList {
                            let orderSeq = storagePayment["ORDER_SEQ"].stringValue
                            
                            // 운송과 일치하는 orderSeq는 보관 신청 내역에 포함하지 않는다
                            if let _ = CarryUser.deliveryHistory.filter({ $0.orderSeq == orderSeq }).first { continue }
                            
                            let requestDate = storagePayment["ORDER_DATE"].stringValue
                            let dueDate = storagePayment["ENTRUST_DATE"].stringValue
                            let address = storagePayment["BIZ_SIMPLE_ADDR"].stringValue
                            let addressDetail = storagePayment["BIZ_DETAIL_ADDR"].stringValue
                            let orderStatus = storagePayment["ORDER_STATUS"].stringValue
                            let lat = storagePayment["BIZ_LAT"].doubleValue
                            let lng = storagePayment["BIZ_LNG"].doubleValue
                            let cost = storagePayment["TOTAL_AMOUNT"].stringValue
//                            let dueTime = storagePayment["CARRYING_DISTANCE"].stringValue
                            let driverName = storagePayment["USER_NAME"].stringValue
                            let pw = storagePayment["AUTH_NO"].stringValue
                            let review = storagePayment["REVIEW_BODY"].stringValue
                            let reviewSeq = storagePayment["REVIEW_BODY_SEQ"].stringValue
                            let reply = storagePayment["RE_REVIEW_BODY"].stringValue
                            let replySeq = storagePayment["RE_REVIEW_BODY_SEQ"].stringValue
                            let phone = storagePayment["DEC_USER_HP_NO"].stringValue
                            let rating = storagePayment["REVIEW_POINT"].floatValue
                            let providerSeq = storagePayment["USER_SEQ"].stringValue
                            
                            let history = StorageHistory(providerSeq: providerSeq, address: "\(address) \(addressDetail)", dueDate: dueDate, requestDate: requestDate, orderSeq: orderSeq, orderStatus: orderStatus, cost: cost, storeName: driverName, lat: lat, lng: lng, pw: pw, phone: phone, review: review, reviewSeq: reviewSeq, reply: reply, replySeq: replySeq, rating: rating)
                            CarryUser.storageHistory.append(history)
                        }
                        
                        completion?(true, "")
                    } else {
                        MyLog.logWithArrow("\(requestTitle) failed", msg)
                        completion?(false, msg)
                    }
                    
                } else {
                    MyLog.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
        
        
    }
    
    
    // 요청 상태 변경 (운송)
    func requestChangeProcess(orderSeq: String, orderStatus: String, completion: ((Bool, String) -> Void)? = nil) {
        
        if false == _utils.createIndicator() { return }
        
        /*      Request
         
         사용자 시퀀스    USER_SEQ_BUYER
         결제 시퀀스    ORDER_SEQ
         운송사업자 명    ORDER_STATUS    (맡길때 006, 찾을때 008 보내면됨)
                                            002 : 결제 완료(최초상태)
                                            006 : 사용자가 짐을 맡기고 난후 처리 상태
                                            004 : 운송사업자가 짐을 받아 배송중인 상태
                                            005 : 운송사업자가 짐을 배송 완료한 상태
                                            008 : 사용자가 짐을 찾아 업무가 종료된 상태
                                            003 : 주문이 취소된 상태
         */
        
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ_BUYER": CarryDatas.shared.user.seq,
            "ORDER_SEQ": orderSeq,
            "ORDER_STATUS": orderStatus
        ]
        
        let urlString = "/sys/payment/app/setChangePaymentProcess.do"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[운송 상태 변경]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        MyLog.log("\(requestTitle) success")
                        // 기존의 데이터에 요청한 status 값 저장
                        if let storageHistory = CarryDatas.shared.user.storageHistory.filter({ $0.orderSeq == orderSeq }).first {
                            storageHistory.orderStatus = orderStatus
                        } else {
                            if let deliveryHistory = CarryDatas.shared.user.deliveryHistory.filter({ $0.orderSeq == orderSeq }).first {
                                deliveryHistory.orderStatus = orderStatus
                            }
                        }
                        
                        completion?(true, orderStatus)
                    } else {
                        MyLog.logWithArrow("\(requestTitle) failed", msg)
                        completion?(false, msg)
                    }
                    
                } else {
                    MyLog.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // 가격요청 의뢰
    func requestDeal(completion: ((Bool, String) -> Void)? = nil) {
        
        let searchData = CarryDatas.shared.currentSearchData
        let operData = CarrySearch.driver
        
        var startPointSeq = CarrySearch.startBaseSeq
        if startPointSeq.isEmpty { startPointSeq = "0" }
        
        var endPointSeq = CarrySearch.endBaseSeq
        if endPointSeq.isEmpty { endPointSeq = "0" }
        
         CarryRequest.shared.requestDeal(userSeq: CarryDatas.shared.user.seq,
                                         vehicleType: searchData.serviceTrans.getRequestString(),
                                         orderKind: searchData.serviceDetail.type,
                                         startAddress: searchData.startPoint?.getRequestString() ?? "",
                                         startDate: searchData.serviceDate.startDate,
                                         endAddress: searchData.endPoint?.getRequestString() ?? "",
                                         endDate: searchData.serviceDate.endDate,
                                         startLat: searchData.startPoint?.lat,
                                         startLng: searchData.startPoint?.lng,
                                         endLat: searchData.endPoint?.lat,
                                         endLng: searchData.endPoint?.lng,
                                         sCount: searchData.serviceLuggage.mini,
                                         mCount: searchData.serviceLuggage.small,
                                         lCount: searchData.serviceLuggage.normal,
                                         xlCount: searchData.serviceLuggage.big,
                                         cost: operData?.cost ?? 0,
                                         imageDatas: CarrySearch.selectedImg,
                                         rentalType: searchData.rentalType.type,
                                         otherHelpCount: searchData.otherHelpCount,
                                         buyerName: CarryUser.name,
                                         buyerPhone: CarryUser.phone,
                                         buyerMemo: CarrySearch.comment,
                                         paymentType: CarrySearch.getPaymentType(),
                                         startPointSeq: startPointSeq,
                                         endPointSeq: endPointSeq) { (success, msg) in
                completion?(success, msg)
         }
    }
    
    
    // 가격요청 의뢰
    func requestDeal(userSeq: String, vehicleType: String, orderKind: String, startAddress: String, startDate: Date?, endAddress: String, endDate: Date?, startLat: Double?, startLng: Double?, endLat: Double?, endLng: Double?, sCount: Int, mCount: Int, lCount: Int, xlCount: Int, cost: Int, imageDatas: [Data?], rentalType: String, otherHelpCount: Int, buyerName: String, buyerPhone: String, buyerMemo: String, paymentType: String, startPointSeq: String, endPointSeq: String, completion: ((Bool, String) -> Void)? = nil) {
        
        if false == _utils.createIndicator() { return }
        
        /*
         사용자 시퀀스     USER_SEQ
         운송수단 타입     VECHILE_TYPE
         주문 유형        DEAL_KIND
         맡기는곳 주소      ENTRUST_ADDR
         맡기는 날짜       ENTRUST_DATE
         찾는곳 주소       TAKE_ADDR
         찾는곳 날짜       TAKE_DATE
         맡기는곳 경도      START_LNG
         맡기는곳 위도      START_LAT
         찾는곳 경도       END_LNG
         찾는곳 위도       END_LAT
         미니짐 갯수       S_TYPE
         작은짐 갯수       M_TYPE
         보통짐 갯수       L_TYPE
         큰짐 갯수        XL_TYPE
                        fileList
                        module
                        ATTACH_TYPE
         상품 결제 금액    PRO_COST
                        CARRYING_CASE
                        CARRYING_ADD_STAFF
         
         */
        
        
        let startLatStr = String(describing: startLat ?? 0)
        let startLngStr = String(describing: startLng ?? 0)
        let endLatStr = String(describing: endLat ?? 0)
        let endLngStr = String(describing: endLng ?? 0)

        // 출발 시간 string
        guard let startDate = startDate else {
            _utils.removeIndicator()
            return
        }
        let startDateString = startDate.toString()
        MyLog.log(startDateString)
        let startDateStringArr = startDateString.split(separator: " ").map { (value) -> String in
            return String(value)
        }

        let startDateStr = startDateStringArr[0]//.replacingOccurrences(of: "-", with: "")
        let startTimeStr = startDateStringArr[1]
        let startTotalStr = "\(startDateStr) \(startTimeStr)"
        
        // 찾는 시간 string
        guard let endDate = endDate else {
            _utils.removeIndicator()
            return
        }
        let endDateString = endDate.toString()
        MyLog.log(endDateString)
        let endDateStringArr = endDateString.split(separator: " ").map { (value) -> String in
            return String(value)
        }
        
        let endDateStr = endDateStringArr[0]//.replacingOccurrences(of: "-", with: "")
        let endTimeStr = endDateStringArr[1]
        let endTotalStr = "\(endDateStr) \(endTimeStr)"
        
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: [String: String] = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ": userSeq,
            "VECHILE_TYPE": vehicleType,
            "DEAL_KIND": orderKind,
            "ENTRUST_ADDR": startAddress,
            "ENTRUST_DATE": startTotalStr,
            "TAKE_ADDR": endAddress,
            "TAKE_DATE": endTotalStr,
            "START_LNG": startLngStr,
            "START_LAT": startLatStr,
            "END_LNG": endLngStr,
            "END_LAT": endLatStr,
            "S_TYPE": String(sCount),
            "M_TYPE": String(mCount),
            "L_TYPE": String(lCount),
            "XL_TYPE": String(xlCount),
            "PRO_COST": String(cost),
            "CARRYING_CASE": rentalType,
            "CARRYING_ADD_STAFF": String(otherHelpCount),
            "BUYER_NAME": buyerName,
            "BUYER_PHONE": buyerPhone,
            "BUYER_MEMO": buyerMemo,
            "PAYMENT_TYPE": paymentType,
            "ENTRUST_BASE_SEQ": startPointSeq,
            "TAKE_BASE_SEQ": endPointSeq,
            "module": "3"
        ]
        
        let attach = "ATTACH_TYPE"
        let attachType = "009"
        let urlString = "/sys/userBuy/app/userRequestProcess.do"
        let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""      // 한글 encoding
        let url = getRequestUrl(body: encodedUrlString)
        
        // 요청
        AF.upload(multipartFormData: { multipartFormData in
            // multipart 데이터 생성 (parameters)
            for (key, value) in param {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            
            // multipart 데이터 생성 (images)
            for (index, data) in imageDatas.enumerated() {
                guard let imgData = data else { continue }
                multipartFormData.append(imgData, withName: "fileList", fileName: "\(index).jpg", mimeType: "image/jpeg")
                multipartFormData.append(attachType.data(using: .utf8)!, withName: attach)
            }
            
        }, to: url, method: .post, headers: headers)
         { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[가격요청 의뢰]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    
                    if result == "0000" {
                        MyLog.logWithArrow("\(requestTitle) success", "DEAL_SEQ: \(msg)")
                        CarryDatas.shared.user.requestDealSeq = msg
                        completion?(true, msg)
                    } else {
                        MyLog.logWithArrow("\(requestTitle) failed", msg)
                        completion?(false, msg)
                    }
                    
                } else {
                    MyLog.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
        
        
    }
    
    
    // 가격요청 목록 갱신
    func requestEstimateAcceptList(startDate: Date?, endDate: Date?, startLat: Double?, startLng: Double?, endLat: Double?, endLng: Double?, sCount: Int, mCount: Int, lCount: Int, xlCount: Int, completion: ((Bool, String) -> Void)? = nil) {
        
        if false == _utils.createIndicator() { return }
        
        // -------------------------- Request -------------------------- //
        //
        //      USER_BUYER_SEQ          사용자 시퀀스
        //      DEAL_SEQ                적재 가용비율
        //      ENTRUST_DATE            맡기는 날짜
        //      TAKE_DATE               찾는곳 날짜
        //      START_LNG               맡기는곳 경도
        //      START_LAT               맡기는곳 위도
        //      END_LNG                 찾는곳 경도
        //      END_LAT                 찾는곳 위도
        //      S_TYPE                  미니짐 갯수
        //      M_TYPE                  작은짐 갯수
        //      L_TYPE                  보통짐 갯수
        //      XL_TYPE                 큰짐 갯수
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      USER_SEQ                사용자 시퀀스
        //      MASTER_SEQ              마스터 사용자 시퀀스
        //      USER_NAME               운송 사업자 명
        //      VECHILE_TYPE            운송 수단 코드
        //      VECHILE_TYPE_NAME       운송 수단 명
        //      PRO_PRICE               운송 비용
        //      ATTACH_INFO             운송 사용자 대표 사진
        //      ATTACH_GRP_SEQ
        //      ATTACH_SEQ
        //      OVERTIME_REQ_RATE
        //      DEAL_PRICE
        //      END_LAT
        //      END_LNG
        //      START_LAT
        //      START_LNG
        //      PLAY_TYPE
        //      REVIEW_POINT_AVG
        //      CARRYING_RATE
        //      ING_RATE
        //      DRIVER_TYPE
        //
        // ------------------------------------------------------------- //
        
        // 출발 시간 string
        let startDateTime = getDateAndTime(date: startDate, removeDash: false)
        let startDateStr = "\(startDateTime[0]) \(startDateTime[1])"
        
        
        // 찾는 시간 string
        let endDateTime = getDateAndTime(date: endDate, removeDash: false)
        let endDateStr = "\(endDateTime[0]) \(endDateTime[1])"
        
        // 좌표
        let startLat = String(describing: startLat ?? 0)
        let startLng = String(describing: startLng ?? 0)
        let endLat = String(describing: endLat ?? 0)
        let endLng = String(describing: endLng ?? 0)
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_BUYER_SEQ": CarryDatas.shared.user.seq,
            "DEAL_SEQ": "0",//CarryDatas.shared.user.requestDealSeq,
            "ENTRUST_DATE": startDateStr,
            "TAKE_DATE": endDateStr,
            "START_LNG": startLng,
            "START_LAT": startLat,
            "END_LNG": endLng,
            "END_LAT": endLat,
            "S_TYPE": sCount,
            "M_TYPE": mCount,
            "L_TYPE": lCount,
            "XL_TYPE": xlCount,
        ]
        
        let urlString = "/sys/userBuy/app/getUserReqAcceptList.do"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[가격요청 의뢰 재요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        
                        guard let arr = jsonValue["gerReserveDriverList"].array else { return }
                        MyLog.log("\(requestTitle) success")
                        
                        self.setDriver(jsonArray: arr, removeCurrentDrivers: true)
                        completion?(true, "")
                    } else {
                        MyLog.logWithArrow("\(requestTitle) failed", msg)
                        completion?(false, msg)
                    }
                    
                } else {
                    MyLog.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
        
    }
    
    // MARK:- 리뷰 목록
    func requestReviews(firstRequest: Bool, completion: ((Bool, String) -> Void)? = nil) {
        
        //-------------------------- Request -------------------------- //
        //
        //          USER_BUYER_SEQ       리뷰 작성하는 사용자 시퀀스
        //          page                 페이지 번호
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //          ## 내가 작성한 리뷰 (getBuyerUserReviewList) ##
        //          ENTRUST_ADDR            맡기는곳 주소
        //          TAKE_ADDR               찾는곳 주소
        //          ORDER_DATE              결제 시작일
        //          PLAY_DATE               맡기고 찾는 일시
        //          USER_SEQ                운송 사업자 시퀀스
        //          USER_SEQ_BUYER          리뷰 작성한 사용자 시퀀스
        //          ORDER_SEQ               결제 시퀀스
        //          REVIEW_POINT            리뷰 점수
        //          REVIEW_BODY             리뷰 내용
        //          UPPER_REVIEW_SEQ        이 값이 REVIEW_SEQ와 같으면 하위의 댓글로 표현 바람
        //          REVIEW_SEQ
        //          ORDER_KIND              004: 보관 / 그외: 운송
        //          row_num
        //
        //          ## 리뷰 작성 대기중인 목록 (getBuyerUserOrderList) ##
        //          ENTRUST_ADDR            맡기는곳 주소
        //          TAKE_ADDR               찾는곳 주소
        //          ORDER_DATE              결제 시작일
        //          PLAY_DATE               맡기고 찾는 일시
        //          USER_SEQ                운송 사업자 시퀀스
        //          USER_SEQ_BUYER          리뷰 작성한 사용자 시퀀스
        //          ORDER_SEQ               결제 시퀀스
        //          ORDER_KIND              결제 종류
        //
        //------------------------------------------------------------- //
            
        
        if false == _utils.createIndicator() { return }
        
//        CarryUser.reviews.deliveryReviews.removeAll()
        
        // 리뷰의 총 개수가 현재 화면에 보여지는 개수보다 적으면 페이지를 증가시키고 요청한다
        if self.reviewTotalCount > self.reviewCurrentCount {
            self.reviewPage += 1
        }
        // 리뷰의 총 개수와 현재 화면에 보여지는 개수가 같으면 전부다 보여진 것이기 때문에 요청하지 않는다
        else if (self.reviewTotalCount == self.reviewCurrentCount) && self.reviewCurrentCount > 0 {
            _utils.removeIndicator()
            return
        }
        
        if firstRequest {
            reviewPage = 1
        }
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_BUYER_SEQ": CarryDatas.shared.user.seq,
            "page": reviewPage
        ]
        
        let urlString = "/sys/userBuy/app/getBuyerUserReviewList.do"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[리뷰 목록 요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        
//                        CarryUser.reviews.removeAll()
                        
                        // ---------------------------------------- 작성한 리뷰 목록 ---------------------------------------- //
                        let reiewArr = jsonValue["getBuyerUserReviewList"].arrayValue
                        for value in reiewArr {
                            let review = Review()
                            review.startAddress = value["ENTRUST_ADDR"].stringValue
                            review.endAddress = value["TAKE_ADDR"].stringValue
                            review.requestDateStr = value["ORDER_DATE"].stringValue
                            review.dueDateStr = value["PLAY_DATE"].stringValue
                            review.driverUserSeq = value["USER_SEQ"].stringValue
                            review.writerSeq = value["USER_SEQ_BUYER"].stringValue
                            review.orderSeq = value["ORDER_SEQ"].stringValue
                            review.rating = value["REVIEW_POINT"].stringValue
                            review.content = value["REVIEW_BODY"].stringValue
                            review.seq = value["REVIEW_SEQ"].stringValue
                            review.upperSeq = value["UPPER_REVIEW_SEQ"].stringValue
                            review.orderKind = value["ORDER_KIND"].stringValue
                            self.reviewCurrentCount = value["row_num"].intValue
                            
                            CarryUser.reviews.allReviews.append(review)
                        }
                        // ---------------------------------------------------------------------------------------------- //
                        
                        // 리뷰, 댓글 구분
                        if reiewArr.count > 0 { CarryUser.reviews.setReviews() }

                        // --------------------------------------- 작성 대기중인 목록 --------------------------------------- //
                        let allReviews = CarryUser.reviews.allReviews
                        let yets = jsonValue["getBuyerUserOrderList"].arrayValue
                        for value in yets {
                            let review = Review()
                            review.startAddress = value["ENTRUST_ADDR"].stringValue
                            review.endAddress = value["TAKE_ADDR"].stringValue
                            review.requestDateStr = value["ORDER_DATE"].stringValue
                            review.dueDateStr = value["PLAY_DATE"].stringValue
                            review.driverUserSeq = value["USER_SEQ"].stringValue
                            review.writerSeq = value["USER_SEQ_BUYER"].stringValue
                            review.orderSeq = value["ORDER_SEQ"].stringValue
                            review.orderKind = value["ORDER_KIND"].stringValue
                            
                            guard nil == allReviews.filter({ $0.orderSeq == review.orderSeq }).first else { continue }
                            
                            if review.orderKind == ServiceDetail.storage.type { CarryUser.reviews.storageReviews.insert(review, at: 0) }
                            else { CarryUser.reviews.deliveryReviews.insert(review, at: 0) }
                        }
                        
                        
                        // 리뷰 개수
                        let count = jsonValue["getBuyerUserReviewTotalCnt"].intValue
                        self.reviewTotalCount = count
                        
                        // --------------------------------------------------------------------------------------------- //
                        
                        MyLog.log("\(requestTitle) success")
                        completion?(true, "")
                    } else {
                        MyLog.logWithArrow("\(requestTitle) failed", msg)
                        completion?(false, msg)
                    }
                    
                } else {
                    MyLog.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
        
    }
    
    
    // MARK:- 리뷰 작성
    func requestWriteReview(driverUserSeq: String, orderSeq: String, reviewPoint: String, content: String, completion: ((Bool, String) -> Void)? = nil) {
        
        //-------------------------- Request -------------------------- //
        //
        //         USER_BUYER_SEQ       리뷰 작성하는 사용자 시퀀스
        //         USER_SEQ             사업자 시퀀스
        //         ORDER_SEQ            주문 시퀀스
        //         REVIEW_POINT         리뷰 점수
        //         REVIEW_BODY          리뷰 내용
        //
        //------------------------------------------------------------- //
     
        
        if false == _utils.createIndicator() { return }
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_BUYER_SEQ": CarryDatas.shared.user.seq,
            "USER_SEQ": driverUserSeq,
            "ORDER_SEQ": orderSeq,
            "REVIEW_POINT": reviewPoint,
            "REVIEW_BODY": content,
        ]
        
        let urlString = "/sys/userBuy/app/setBuyerUserReviewMng.do"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[리뷰 목록 요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        
                        MyLog.log("\(requestTitle) success")
                        completion?(true, "")
                    } else {
                        MyLog.logWithArrow("\(requestTitle) failed", msg)
                        completion?(false, msg)
                    }
                    
                } else {
                    MyLog.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
        
    }
    
    // MARK:- 대기중인 의뢰 목록
    func RequestMyRequestList(completion: ((Bool, String) -> Void)? = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_BUYER_SEQ          리뷰 작성하는 사용자 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [gerReserveDriverList]
        //      DEAL_SEQ                요청 시퀀스
        //      DEAL_KIND_TXT           요청 타이틀
        //      DEAL_KIND               요청 코드
        //      PLAY_DATE               의뢰 기간
        //      ENTRUST_DATE            맡기는 시간
        //      ENTRUST_LAT             맡기는 좌표의 위도
        //      ENTRUST_LNG             맡기는 좌표의 경도
        //      TAKE_DATE               찾는 시간
        //      TAKE_LAT                찾는 좌표의 위도
        //      TAKE_LNG                찾는 좌표의 경도
        //      USER_SEQ                안쓰임..
        //
        // ------------------------------------------------------------- //
        
        
        if false == _utils.createIndicator() { return }
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_BUYER_SEQ": CarryDatas.shared.user.seq
        ]
        
        let urlString = "/sys/userBuy/app/getUserRequestList.do"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[대기중인 의뢰 목록]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                self.binding.bindingMyRequestList(json: JSON(value), completion: completion)
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // 운송 맡긴 물건 수령시/도착시 사업자가 업로드한 이미지 요청
    func RequestLuggagePhoto(orderSeq: String, attachType: String, completion: ((Bool, String) -> Void)? = nil) {
        
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ_BUYER      사용자 시퀀스
        //      ORDER_SEQ           결제 시퀀스
        //      ATTACH_TYPE         확인하고자 하는 사진 타입 (010: 수령(이동중), 011: 도착)
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      PAYMENT_ATTACH_INFO  첨부파일 정보
        //
        // ------------------------------------------------------------- //
        
        
        if false == _utils.createIndicator() { return }
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ_BUYER": CarryDatas.shared.user.seq,
            "ORDER_SEQ": orderSeq,
            "ATTACH_TYPE": attachType
        ]
        
        let urlString = "/sys/payment/app/getAuthPictureList.do"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[업로드된 이미지 확인]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        MyLog.log("\(requestTitle) success")
                        
                        var imgUrls = ""
                        var separator = ""
                        let arr = jsonValue["authPaymentList"].arrayValue
                        for value in arr {
                            
                            if imgUrls.isEmpty { separator = "" }
                            else { separator = MyIdentifiers.imgUrlSeparator.rawValue }
                            
                            let imgUrl = value["PAYMENT_ATTACH_INFO"].stringValue
                            imgUrls = "\(imgUrls)\(separator)\(imgUrl)"
                        }
                        
                        completion?(true, imgUrls)
                    } else {
                        MyLog.logWithArrow("\(requestTitle) failed", msg)
                        completion?(false, msg)
                    }
                    
                } else {
                    MyLog.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // 보관사업자 목록 요청 (특정 지역 부근)
    func requestNearStorages(lat: Double?, lng: Double?, completion: ((Bool, String) -> Void)? = nil) {
        
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            사용자 시퀀스
        //      BIZ_LAT             위도
        //      BIZ_LNG             경도
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      BIZ_LAT             보관사업자 좌표(위도)
        //      BIZ_LNG             보관사업자 좌표(경도)
        //      BIZ_NAME            보관사업자 명
        //      BIZ_SIMPLE_ADDR     간단주소
        //      BIZ_DETAIL_ADDR     상세주소
        //      BIZ_TEL             전화번호
        //      USER_SEQ            보관사업자 시퀀스
        //
        // ------------------------------------------------------------- //
        
        
//        if false == _utils.createIndicator() { return }
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ": CarryDatas.shared.user.seq,
            "BIZ_LAT": String(describing: lat ?? 0),
            "BIZ_LNG": String(describing: lng ?? 0)
        ]
        
        let urlString = "/sys/wareHouseReq/app/getNearWareHouseList.do"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[보관사업자 목록 요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
//            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        let arr = jsonValue["reserveList"].arrayValue
                        if arr.count > 0 { CarrySearch.localBases.removeAll() }
                        
                        for value in arr {
                            let lat = value["BIZ_LAT"].doubleValue
                            let lng = value["BIZ_LNG"].doubleValue
                            let name = value["BIZ_NAME"].stringValue
                            let address = value["BIZ_SIMPLE_ADDR"].stringValue
                            let addressDetail = value["BIZ_DETAIL_ADDR"].stringValue
                            let contact = value["BIZ_TEL"].stringValue
                            let seq = value["USER_SEQ"].stringValue
                            
                            let storeOper = Storage()
                            storeOper.userSeq = seq; storeOper.lat = lat; storeOper.lng = lng; storeOper.name = name; storeOper.address = address; storeOper.addressDetail = addressDetail; storeOper.contact = contact
                            CarrySearch.localBases.append(storeOper)
                        }
                        
                        MyLog.log("\(requestTitle) success")
                        completion?(true, "")
                    } else {
                        MyLog.logWithArrow("\(requestTitle) failed", msg)
                        completion?(false, msg)
                    }
                    
                } else {
                    MyLog.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    func getDateAndTime(date: Date?, removeDash: Bool) -> [String] {
        guard let startDate = date else { return [] }
        
        let startDateString = startDate.toString()
        MyLog.log(startDateString)
        var startDateStringArr = startDateString.split(separator: " ").map { (value) -> String in
            return String(value)
        }

        if removeDash {
            startDateStringArr[0] = startDateStringArr[0].replacingOccurrences(of: "-", with: "")
        }
        return startDateStringArr
    }
    
    // 현재 정보로 보관사업자 목록 요청
    func requestSearchStorages(completion: ((Bool, String) -> Void)? = nil) {
        let startTimeInterval = CarrySearch.serviceDate.startDate?.timeIntervalSince1970 ?? 0       // second
        let endTimeInterval = CarrySearch.serviceDate.endDate?.timeIntervalSince1970 ?? 0
        let during = endTimeInterval - startTimeInterval
        
        let oneDaySecond: Double = 60 * 60 * 24     // 하루(second)
        let oneHourSecond: Double = 60 * 60         // 1시간(second)
        
        var duringInt: Int = 0                      // 맡기는 시간
        var dayOverType = StorageDayType.dayIn      // 맡기는 시간 타이
        
        if during > oneDaySecond {
            dayOverType = StorageDayType.dayOver
            
            let remain = during.truncatingRemainder(dividingBy: oneDaySecond)
            duringInt = Int(exactly: (during / oneDaySecond)) ?? 0
            if remain > 0 { duringInt += 1 }
        }
        else {
            let remain = during.truncatingRemainder(dividingBy: oneHourSecond)
            duringInt = Int(exactly: (during / oneHourSecond)) ?? 0
            if remain > 0 { duringInt += 1 }
        }
        
        CarrySearch.dayType = dayOverType
        CarrySearch.storageRequestTime = duringInt
        
        if CarrySearch.isLocal {
            let address = CarrySearch.storage?.address ?? ""
            let addressDetail = CarrySearch.storage?.addressDetail ?? ""
            CarrySearch.startPoint = ServiceLocale(lat: CarrySearch.storage?.lat ?? 0, lng: CarrySearch.storage?.lng ?? 0, address: address, addressDetail: addressDetail)
        }
        
        CarryRequest.shared.requestSearchStorages(lat: CarrySearch.startPoint?.lat, lng: CarrySearch.startPoint?.lng, dayOverType: dayOverType.rawValue, during: String(duringInt), startDate: CarrySearch.serviceDate.startDate, endDate: CarrySearch.serviceDate.endDate, sCount: CarrySearch.serviceLuggage.mini, mCount: CarrySearch.serviceLuggage.small, lCount: CarrySearch.serviceLuggage.normal, xlCount: CarrySearch.serviceLuggage.big, completion: completion)
    }
    
    // 보관사업자 목록 요청 (특정 지역 부근)
    func requestSearchStorages(lat: Double?, lng: Double?, dayOverType: String, during: String, startDate: Date?, endDate: Date?, sCount: Int, mCount: Int, lCount: Int, xlCount: Int, completion: ((Bool, String) -> Void)? = nil) {
        
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            사용자 시퀀스
        //      TARGET_LNG          맡기는곳 경도
        //      TARGET_LAT          맡기는곳 위도
        //      SAVER_TYPE          결제 시간 - 날짜 종류 (24시간이 지나면 001 / 24시간이 지나지 않으면 002)
        //      SAVER_TIME          결제 시간 - 날짜 값 (24시간이 지나면 24시간 단위로 1일 전달 값은 1,2 / 24시간이 지나지 않으면 시간 단위로 8,11)
        //      START_TIME          맡기는 시간  (10:00:00 형식으로 전달 초는 00으로 해도됨)
        //      END_TIME            찾는 시간   (10:00:00 형식으로 전달 초는 00으로 해도됨)
        //      START_DAY           맡기는 날짜  (20201201 8자리로 전달)
        //      END_DAY             찾는 날짜   (20201201 8자리로 전달)
        //      S_TYPE              미니짐 갯수
        //      M_TYPE              작은짐 갯수
        //      L_TYPE              보통짐 갯수
        //      XL_TYPE             큰짐 갯수
        //      page                페이지 번호
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      USER_SEQ            보관사업자 시퀀스
        //      BIZ_LAT             보관사업자 좌표(위도)
        //      BIZ_LNG             보관사업자 좌표(경도)
        //      BIZ_NAME            보관사업자 명
        //      BIZ_SIMPLE_ADDR     간단주소
        //      BIZ_DETAIL_ADDR     상세주소
        //
        //
        // ------------------------------------------------------------- //
        
        // 검색된 사업자의 총 개수가 현재 화면에 보여지는 개수보다 적으면 페이지를 증가시키고 요청한다
        if self.storageTotalCount > self.storageCurrentCount {
            self.storageListPage += 1
        }
        // 검색된 사업자의 총 개수와 현재 화면에 보여지는 개수가 같으면 전부다 보여진 것이기 때문에 요청하지 않는다
        else if (self.storageTotalCount == self.storageCurrentCount) && self.storageCurrentCount > 0 {
            return
        }
        
        // 출발 시간 string
        let startDateTime = getDateAndTime(date: startDate, removeDash: true)
        let startDateStr = startDateTime[0]
        let startTimeStr = startDateTime[1]
        
        // 찾는 시간 string
        
        let endDateTime = getDateAndTime(date: endDate, removeDash: true)
        var endDateStr = ""
        if endDateTime.count > 0 { endDateStr = endDateTime[0] }
        
        var endTimeStr = ""
        if endDateTime.count > 1 { endTimeStr = endDateTime[1] }
        
        guard let lat = lat else { return }
        guard let lng = lng else { return }
        
        if false == _utils.createIndicator() { return }
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ": CarryDatas.shared.user.seq,
            "TARGET_LNG": String(describing: lng),
            "TARGET_LAT": String(describing: lat),
            "SAVER_TYPE": dayOverType,
            "SAVER_TIME": during,
            "START_TIME": startTimeStr,
            "END_TIME": endTimeStr,
            "START_DAY": startDateStr,
            "END_DAY": endDateStr,
            "S_TYPE": String(sCount),
            "M_TYPE": String(mCount),
            "L_TYPE": String(lCount),
            "XL_TYPE": String(xlCount),
            "page": String(storageListPage)
        ]
        
        let urlString = "/sys/userBuy/app/getSaverSrcList.do"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[보관사업자 목록 요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        MyLog.log("\(requestTitle) success")
                        
                        let arr = jsonValue["gerReserveDriverList"].arrayValue
                        for value in arr {
                            let category = value["COM_NM"].stringValue
                            
                            let attachSeq = value["ATTACH_SEQ"].stringValue
                            let masterSeq = value["MASTER_SEQ"].stringValue
                            let attachInfo = value["USER_ATTACH_INFO"].stringValue
                            
                            let userSeq = value["USER_SEQ"].stringValue
                            let bizName = value["BIZ_NAME"].stringValue
                            
                            let possibleRate = value["POSSIBLE_RATE"].intValue
                            let rating = value["REVIEW_POINT_AVG"].floatValue
                            let cost = value["PRO_PRICE"].intValue
                            let timeType = value["RATE_TYPE"].stringValue
                            
                            let bizLat = value["BIZ_LAT"].doubleValue
                            let bizLng = value["BIZ_LNG"].doubleValue
                            let bizAddress = value["BIZ_SIMPLE_ADDR"].stringValue
                            let bizAddressDetail = value["BIZ_DETAIL_ADDR"].stringValue
                            
                            self.storageCurrentCount = value["row_num"].intValue
//                            let carryingRate = value["CARRYING_RATE"].stringValue
//                            let ingRate = value["ING_RATE"].stringValue
                            
                            let oper = Storage()
                            oper.category = category
                            oper.userSeq = userSeq
                            oper.name = bizName
                            oper.possibleRate = possibleRate
                            oper.lat = bizLat
                            oper.lng = bizLng
                            oper.address = bizAddress
                            oper.addressDetail = bizAddressDetail
                            oper.cost = cost
                            oper.rating = rating
                            oper.timeType = TimeType(rawValue: timeType) ?? .none
                            oper.masterSeq = masterSeq
                            oper.attachSeq = attachSeq
                            oper.imgUrl = attachInfo
                            
                            let imgUrl = self.getRequestUrl(body: oper.imgUrl)
                            oper.img = _utils.getImageFromUrl(url: imgUrl)
                            
                            CarrySearch.storages.append(oper)
                        }
                        
                        self.storageTotalCount = jsonValue["totalCnt"].intValue
                        
                        // 전체 목록 수(storageTotalCount)와 마지막 보관사업자의 rowNum(storageCurrentCount)이 일치하지 않을때가 있는데 이렇게 되면 무한루프에 빠진다
                        // 무한 루프에 빠지는 것을 방지하기 위해 값을 일치시킨다.
                        if arr.isEmpty && self.storageTotalCount != self.storageCurrentCount {
                            self.storageTotalCount = self.storageCurrentCount
                        }
                        
                        MyLog.log("\(requestTitle) success")
                        completion?(true, "")
                    } else {
                        MyLog.logWithArrow("\(requestTitle) failed", msg)
                        completion?(false, msg)
                    }
                    
                } else {
                    MyLog.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                }
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // 보관사업자 상세정보
    func requestStorageDetail(operSeq: String, masterSeq: String, dayOverType: String, during: String, sCount: Int, mCount: Int, lCount: Int, xlCount: Int, completion: ((Bool, String) -> Void)? = nil) {
        
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            사용자 시퀀스
        //      MASTER_SEQ          보관사업자 마스터 시퀀스
        //      SAVER_USER_SEQ      보관사업자 시퀀스
        //      SAVER_TYPE          결제 시간 - 날짜 종류 (24시간이 지나면 001 / 24시간이 지나지 않으면 002)
        //      SAVER_TIME          결제 시간 - 날짜 값 (24시간이 지나면 24시간 단위로 1일 전달 값은 1,2 / 24시간이 지나지 않으면 시간 단위로 8,11)
        //      S_TYPE              미니짐 갯수
        //      M_TYPE              작은짐 갯수
        //      L_TYPE              보통짐 갯수
        //      XL_TYPE             큰짐 갯수
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      (getReserveDriverDetail)
        //      POSSIBLE_RATE       적재 가용비율
        //      USER_SEQ            사용자 시퀀스
        //      MASTER_SEQ          마스터 사용자 시퀀스
        //      BIZ_NAME            보관 사업자 명
        //      COM_NM              보관 사업 종류
        //      REVIEW_POINT_AVG    평점
        //      CARRYING_ISSUE      소개글
        //
        //      (getReviewList)
        //      REVIEW_SEQ          평가 시퀀스
        //      REVIEW_POINT        평가 점수
        //      REVIEW_BODY         평가 내용
        //      REVIEW_DATE         평가 등록일
        //
        //      (basicPriceList)
        //      RATE_SEQ            기본 가격 시퀀스
        //      RATE_KIND           기본 가격 종류
        //      RATE_SECTION        기본 적용시간
        //      RATE_PRICE          기본 가격
        //
        //      (overPriceList)
        //      RATE_SEQ            할증 가격 시퀀스
        //      RATE_KIND           할증 가격 종류
        //      RATE_SECTION        할증 적용시간
        //      RATE_PRICE          할증 가격
        //
        //      (oneDayPriceList)
        //      RATE_SEQ            할증 가격 시퀀스
        //      RATE_KIND           할증 가격 종류
        //      RATE_SECTION        할증 적용시간
        //      RATE_PRICE          할증 가격
        //
        // ------------------------------------------------------------- //
        
        if false == _utils.createIndicator() { return }
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ": CarryDatas.shared.user.seq,
            "MASTER_SEQ": masterSeq,
            "SAVER_USER_SEQ": operSeq,
            "SAVER_TYPE": dayOverType,
            "SAVER_TIME": during,
            "S_TYPE": String(sCount),
            "M_TYPE": String(mCount),
            "L_TYPE": String(lCount),
            "XL_TYPE": String(xlCount),
        ]
        
        let urlString = "/sys/userBuy/app/getSaverSrcDetail.do"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[보관사업자 상세 정보 요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                self.binding.bindingStorageDetail(json: JSON(value), completion: completion)
                
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // 메인화면 운송사업자 상세 정보 요청
    func requestLocalDriverDetail(driverSeq: String, completion: ResponseString = nil) {
        
        if false == _utils.createIndicator() { return }
        
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ            유저 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      POSSIBLE_RATE           적재 가용비율
        //      USER_SEQ                사용자 시퀀스
        //      MASTER_SEQ              마스터 사용자 시퀀스
        //      USER_NAME               운송 사업자 명
        //      VECHILE_TYPE            운송 수단 코드
        //      VECHILE_TYPE_NAME       운송 수단 명
        //      PRO_PRICE               운송 비용
        //      ATTACH_INFO             운송 사용자 대표 사진
        //      CARRYING_ISSUE          비고(주가내용)
        //      WORK_STA_TIME           근무 시작시간
        //      WORK_OUT_TIME           근무 종료 시간
        //      REVIEW_POINT_AVG        평점
        //
        //      (getReviewList)         리뷰
        //      REVIEW_SEQ              리뷰 시퀀스
        //      REVIEW_POINT            리뷰 점수
        //      REVIEW_BODY             리뷰 내용
        //      REVIEW_DATE             리뷰 등록일
        //
        //      (getBoxList)            짐
        //      ORDER_SEQ               짐 시퀀스
        //      ITEM_KIND               짐 종류 코드
        //      ITEM_KIND_TXT           짐 종류 텍스트
        //      ITEM_QUANTITY           짐 종료 수량
        //
        // ------------------------------------------------------------- //
        
        
        let url = getRequestUrl(body: "/sys/basicMain/app/getDriverDetail.do")
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ": driverSeq
        ]
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[메인화면 운송사업자 상세 정보 요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                self.binding.bindingLocalDriverDetail(json: JSON(value), completion: completion)
                
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    
    // 메인화면 보관사업자 상세 정보 요청
    func requestLocalStorageDetail(storageSeq: String, completion: ResponseString = nil) {
        
        if false == _utils.createIndicator() { return }
        
        // -------------------------- Request -------------------------- //
        //
        //      USER_SEQ                유저 시퀀스
        //      SAVER_USER_SEQ          보관 사업자 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      POSSIBLE_RATE           적재 가용비율
        //      USER_SEQ                사용자 시퀀스
        //      MASTER_SEQ              마스터 사용자 시퀀스
        //      BIZ_NAME                보관 사업자 명
        //      COM_NM                  보관 사업 종류
        //      REVIEW_POINT_AVG        평점
        //      CARRYING_ISSUE          소개글
        //
        //      (getReviewList)         리뷰
        //      REVIEW_SEQ              리뷰 시퀀스
        //      REVIEW_POINT            리뷰 점수
        //      REVIEW_BODY             리뷰 내용
        //      REVIEW_DATE             리뷰 등록일
        //
        //      (basicPriceList)        기본요금(1일 이내)
        //      RATE_SEQ                기본 가격 시퀀스
        //      RATE_KIND               기본 가격 종류
        //      RATE_USER_SECTION       기본 적용시간
        //      RATE_USER_PRICE         기본 가격
        //
        //      (overPriceList)         추가요금(1일 이내)
        //      RATE_SEQ                기본 가격 시퀀스
        //      RATE_KIND               기본 가격 종류
        //      RATE_USER_SECTION       기본 적용시간
        //      RATE_USER_PRICE         기본 가격
        //
        //      (oneDayPriceList)       추가요금(1일 이후)
        //      RATE_SEQ                기본 가격 시퀀스
        //      RATE_KIND               기본 가격 종류
        //      RATE_USER_SECTION       기본 적용시간
        //      RATE_USER_PRICE         기본 가격
        //
        // ------------------------------------------------------------- //
        
        
        let url = getRequestUrl(body: "/sys/basicMain/app/getSaverDetail.do")
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ": storageSeq
        ]
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[메인화면 보관사업자 상세 정보 요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                self.binding.bindingLocalStorageDetail(json: JSON(value), completion: completion)
                
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    
    // MARK:- 약관
    func requestTerms(type: TermType, seq: String = "0", completion: ResponseString = nil) {
        if false == _utils.createIndicator() { return }
        
        // -------------------------- Request -------------------------- //
        //
        //      board_seq               약관 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      BOARD_SEQ               이용약관 시퀀스
        //      BOARD_TITLE             이용약관 제목
        //      BOARD_MEMO              이용약관 내용
        //
        // ------------------------------------------------------------- //
        
        var url = ""
        
        switch type {
        case .use:
            url = getRequestUrl(body: "/sys/contents/appAuth/termsInfo.do")
        case .info:
            url = getRequestUrl(body: "/sys/contents/appAuth/agreeInfo.do")
        case .marketting:
            url = getRequestUrl(body: "/sys/contents/appAuth/marketInfo.do")
        default: return
        }
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "board_seq": seq
        ]
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[약관 요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                self.binding.bindingTerms(type: type, json: JSON(value), completion: completion)
                
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    func requestWithdrawal(completion: ResponseString = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      USER_ID             유저 ID
        //      USER_SEQ            유저 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        // ------------------------------------------------------------- //
        
        let url = getRequestUrl(body: "/sys/member/app/dropMember.do")
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_ID": CarryUser.id,
            "USER_SEQ": CarryUser.seq
        ]
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[탈퇴 요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                self.binding.bindingWithDrawal(json: JSON(value), completion: completion)
                
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // MARK:- 유저 정보 수정 요청 (폰번호)
    func requestSetPhoneNumber(phone: String, completion: ResponseString = nil) {
        
        //-------------------------- Request -------------------------- //
        //
        //         USER_SEQ             사용자 시퀀스
        //         MASTER_SEQ           마스터 시퀀스
        //         BIZ_NAME             상호명
        //         CD_BIZ_TYPE          업종
        //         BIZ_SIMPLE_ADDR      사업체 주소
        //         BIZ_DETAIL_ADDR      사업체 상세 주소
        //         BIZ_LAT              위도
        //         BIZ_LNG              경도
        //         BIZ_CORP_NO          사업자 등록 번호
        //         BANK_CD              사업자 계좌 은행 코드
        //         BANK_PRIVATE_NO      사업자 핸드폰 번호
        //         USER_HP_NO           사업자 핸드폰 번호
        //         TMP_HP_NO            임시 핸드폰 번호
        //         ATTACH_YN            첨부파일 유무
        //         fileList             사업자 등록증 이미지
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        if false == _utils.createIndicator() { return }
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]

        let param: [String: String] = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ": CarryUser.seq,
            "MASTER_SEQ": CarryUser.seq,
            "BIZ_NAME": "-",
            "CD_BIZ_TYPE": "-",
            "BIZ_SIMPLE_ADDR": "-",
            "BIZ_DETAIL_ADDR": "-",
            "BIZ_LAT": "0",
            "BIZ_LNG": "0",
            "BIZ_CORP_NO": "-",
            "BIZ_GUBUN": "001",
            "BANK_CD": "-",
            "BANK_PRIVATE_NO": "-",
            "USER_HP_NO": phone,
            "TMP_HP_NO": "-",
            "ATTACH_YN": "N",
            "module": "3"
        ]
        

        let url = getRequestUrl(body: "/sys/member/app/setMasterUserModify.do")
        AF.upload(multipartFormData: { multipartFormData in
            
            // multipart 데이터 생성 (parameters)
            for (key, value) in param {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            
        }, to: url, method: .post, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            _utils.removeIndicator()
            
            let requestTitle = "[사업자 정보 수정 요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                if let result = jsonValue["resCd"].string {
                    if result == "0000" {
                        completion?(true, "")
                        MyLog.log("\(requestTitle) 성공")
                    } else {
                        completion?(false, jsonValue["resMsg"].stringValue)
                        MyLog.logWithArrow("\(requestTitle) 실패", jsonValue["resMsg"].stringValue)
                    }
                } else {
                    MyLog.logWithArrow("\(requestTitle) 실패", jsonValue["resMsg"].stringValue)
                    completion?(false, jsonValue["resMsg"].stringValue)
                }
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) 실패", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // MARK:- 환불 정보 조회
    func requestRefundInfo(orderSeq: String, completion: ResponseString = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      ORDER_SEQ           주문 시퀀스
        //      USER_SEQ_BUYER      유저 시퀀스
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      PAY_APPNUM          아임포트 결제 시퀀스
        //      CANCEL_PRICE        환불 결정 금액
        //      CANCEL_PERCENT      환불 결정 퍼센트
        //      ORDER_KIND          결제 종류
        //      PAYMENT_TYPE        결제 타입
        //      REFUND_STATUS       환불 가능 여부
        //      BUY_DAY
        //      DIFF_DAY
        //      ENTRUST_DATE
        //      ORDER_DATE
        //      ORDER_STATUS
        //      TOTAL_AMOUNT
        //      PAY_APPNUM
        //
        // ------------------------------------------------------------- //
        
        let url = getRequestUrl(body: "/sys/payment/app/refundForm.do")
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "ORDER_SEQ": orderSeq,
            "USER_SEQ_BUYER": CarryUser.seq
        ]
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[환불 정보 조회]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            _utils.removeIndicator()
            
            switch response.result {
            case .success(let value):
                self.binding.bindingRefundInfo(json: JSON(value), completion: completion)
                
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // MARK:- 환불 요청
    func requestRefund(orderSeq: String, iamportOrderSeq: String, refundAmount: String, refundPercent: String, orderKind: String, paymentType: String, completion: ResponseString = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      ORDER_SEQ               결제 시퀀스
        //      USER_SEQ_BUYER          사용자 시퀀스
        //      PAY_APPNUM              아임포트 결제 시퀀스
        //      REFUND_AMOUNT           환불 결정 금액
        //      REFUND_PERCENT          환불 결정 퍼센트
        //      ORDER_KIND              결제 종류
        //      PAYMENT_TYPE            결제 타입
        //
        // ------------------------------------------------------------- //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        // ------------------------------------------------------------- //
        
        if false == _utils.createIndicator() { return }
        
        let url = getRequestUrl(body: "/sys/payment/app/refundProcess.do")
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let refuncAmountStr = _utils.getStringFromDelemiter(str: refundAmount)
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "ORDER_SEQ": orderSeq,
            "USER_SEQ_BUYER": CarryUser.seq,
            "PAY_APPNUM": iamportOrderSeq,
            "REFUND_AMOUNT": refuncAmountStr,
            "REFUND_PERCENT": refundPercent,
            "ORDER_KIND": orderKind,
            "PAYMENT_TYPE": paymentType
        ]
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            _utils.removeIndicator()
            
            let requestTitle = "[환불 요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let msg = json["resMsg"].stringValue
                guard json["resCd"].stringValue == "0000" else {
                    MyLog.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                    return
                }
                
                MyLog.log("\(requestTitle) success")
                completion?(true, "")
                
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // MARK:- 프로필 사진 조회
    func requestProfilePicture(completion: ResponseString = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                사용자 시퀀스
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      USER_ATTACH_INFO        프로필 사진
        //      ATTACH_GRP_SEQ          프로필 사진 시퀀스
        //
        //------------------------------------------------------------- //
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ": CarryUser.seq
        ]
        
        let urlString = "/sys/member/app/getProfileImage.do"
        let url = getRequestUrl(body: urlString)
        
//        api = .getProfile
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[프로필 사진 조회]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                self.binding.bindingProfilePicture(json: JSON(value), completion: completion)
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) 실패", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
            
//            self.api = .none
        }
    }
    
    
    // MARK:- 프로필 사진 등록
    func requestSetProfilePicture(attachGrpSeq: String, imgData: Data, completion: ResponseString = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                사용자 시퀀스
        //      ATTACH_TYPE             저장 구분 (고정값: 016)
        //      ATTACH_GRP_SEQ          파일 시퀀스
        //      fileList                첨부 파일
        //      module                  모듈 번호 (고정값: 1)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: [String: String] = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ": CarryUser.seq,
            "ATTACH_GRP_SEQ": attachGrpSeq,
            "module": "1"
        ]
        
        let urlString = "/sys/member/app/setProfileImage.do"
        let url = getRequestUrl(body: urlString)
        
//        api = .getProfile
        
        let attachType = "016"
        let attach = "ATTACH_TYPE"
        AF.upload(multipartFormData: { multipartFormData in
            
            // multipart 데이터 생성 (parameters)
            for (key, value) in param {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            
            // multipart 데이터 생성 (image)
            multipartFormData.append(imgData, withName: "fileList", fileName: "profile_\(CarryUser.seq).jpg", mimeType: "image/jpeg")
            multipartFormData.append(attachType.data(using: .utf8)!, withName: attach)
            
        }, to: url, method: .post, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[프로필 사진 등록]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                let msg = jsonValue["resMsg"].stringValue
                guard jsonValue["resCd"].stringValue == "0000" else {
                    MyLog.logWithArrow("\(requestTitle) failed", msg)
                    completion?(false, msg)
                    return
                }
                
                MyLog.log("\(requestTitle) success")
                completion?(true, "")
                
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) 실패", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
            
//            self.api = .none
        }
    }
    
    
    // MARK:- 공항 목록 조회
    func requestAirportList(completion: ResponseString = nil) {
        //-------------------------- Request -------------------------- //
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      CD_CATEGORY             공항 코드
        //      CATEGORY_NM             공항 명
        //      CATEGORY_LNG            공항 좌표(위도)
        //      CATEGORY_LAT            공항 좌표(경도)
        //
        //------------------------------------------------------------- //
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ": CarryUser.seq
        ]
        
        let urlString = "/sys/common/app/getAllAirport.do"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[공항 목록 조회]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                self.binding.bindingAirport(json: JSON(value), completion: completion)
                
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    
    
    // MARK:- 직영 운반사업자 검색 (입력된 정보로 검색)
    func requestDirectDriver(completion: ((Bool, String) -> Void)? = nil) {
        let data = CarryDatas.shared.currentSearchData
        var airport = CarrySearch.startAirport
        if airport.code.isEmpty { airport = CarrySearch.endAirport }
        
        requestDirectDriver(startLat: data.startPoint?.lat, startLng: data.startPoint?.lng, endLat: data.endPoint?.lat, endLng: data.endPoint?.lng, startDate: data.serviceDate.startDate, endDate: data.serviceDate.endDate, airportCode: airport.code, s: data.serviceLuggage.mini, m: data.serviceLuggage.small, l: data.serviceLuggage.normal, xl: data.serviceLuggage.big, completion: completion)
    }
 
    
    // MARK:- 직영 운반사업자 검색
    func requestDirectDriver(startLat: Double?, startLng: Double?, endLat: Double?, endLng: Double?, startDate: Date?, endDate: Date?, airportCode: String, s: Int, m: Int, l: Int, xl: Int, completion: ResponseString = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                회원 seq
        //      START_LNG               맡기는곳 좌표
        //      START_LAT               맡기는곳 좌표
        //      END_LNG                 찾는곳 좌표
        //      END_LAT                 찾는곳 좌표
        //      START_TIME              맡기는 시간
        //      END_TIME                찾는 시간
        //      LOCATION_CD             공항 코드
        //      S_TYPE
        //      M_TYPE
        //      L_TYPE
        //      XL_TYPE
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      PRICE                   가격
        //      USER_SEQ                직역 운반 사업자 시퀀스
        //
        //------------------------------------------------------------- //
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        /*
        let startLatStr = String(describing: startLat ?? 0)
        let startLngStr = String(describing: startLng ?? 0)
        let endLatStr = String(describing: endLat ?? 0)
        let endLngStr = String(describing: endLng ?? 0)
        */
        
        // 출발 시간 string
        let startDateTime = getDateAndTime(date: startDate, removeDash: false)
        if startDateTime.count < 2 {
            let alert = _utils.createSimpleAlert(title: MyStrings.alertNeedCorrectTime.rawValue, message: "", buttonTitle: MyStrings.ok.rawValue)
            _utils.topViewController()?.present(alert, animated: true)
        }
        
        // 도착 시간 string
        let endDateTime = getDateAndTime(date: endDate, removeDash: false)
        if endDateTime.count < 2 {
            let alert = _utils.createSimpleAlert(title: MyStrings.alertNeedCorrectTime.rawValue, message: "", buttonTitle: MyStrings.ok.rawValue)
            _utils.topViewController()?.present(alert, animated: true)
        }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "USER_SEQ": CarryUser.seq,
            "START_LNG": startLng ?? 0,
            "START_LAT": startLat ?? 0,
            "END_LNG": endLng ?? 0,
            "END_LAT": endLat ?? 0,
            "START_TIME": startDateTime[1],
            "END_TIME": endDateTime[1],
            "LOCATION_CD": airportCode,
            "S_TYPE": s,
            "M_TYPE": m,
            "L_TYPE": l,
            "XL_TYPE": xl
        ]
        
        let urlString = "/sys/userBuyV2/app/getDirectSrcList.do"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[직영 운반사업자 검색]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
//                self.binding.bindingAirport(json: JSON(value), completion: completion)
                
                let json = JSON(value)
                let data = json["gerDirectDriverInfo"]
                let cost = data["PRICE"].intValue
                let driverNo = data["dicisionNo"].stringValue
                let name = data["BIZ_NAME"].stringValue
                let masterSeq = data["MASTER_SEQ"].stringValue
                let userSeq = data["USER_SEQ"].stringValue
                let imgUrl = data["DIRECT_IMG_INFO"].stringValue
                let driver = Driver()
                driver.userSeq = userSeq
                driver.masterSeq = masterSeq
                driver.imgUrl = imgUrl
                driver.name = name
                driver.cost = cost
                driver.driverNo = driverNo
                CarrySearch.drivers.insert(driver, at: 0)
                CarrySearch.directDriver = DirectDriverData(userSeq: userSeq, masterSeq: masterSeq, name: name, imgUrl: imgUrl, cost: String(cost), driverNo: driverNo)
                
                if driverNo.isEmpty == false { self.driverCurrentCount += 1 }
                
                // 전체 목록 수(driverTotalCount)와 마지막 운송사업자의 rowNum(driverCurrentCount)이 일치하지 않을때가 있는데 이렇게 되면 무한루프에 빠진다
                // 무한 루프에 빠지는 것을 방지하기 위해 값을 일치시킨다.
                if self.driverTotalCount != self.driverCurrentCount {
                    self.driverTotalCount = self.driverCurrentCount
                }
                
                completion?(true, "")
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    
    // MARK:- 직영 운반사업자에게 결제 요청
    func requestPurchasingToDirectDriver(driverMasterSeq: String, driverUserSeq: String, vehicleType: String, orderKind: String, payMethod: String, paymentType: String, startAddr: String, endAddr: String, buyerMemo: String, cost: Int, startLat: Double?, startLng: Double?, endLat: Double?, endLng: Double?, startDate: Date?, endDate: Date?, s: Int, m: Int, l: Int, xl: Int, completion: ResponseString = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      DRIVER_MASTER_SEQ
        //      DRIVER_USER_SEQ
        //      USER_SEQ
        //      VECHILE_TYPE
        //      ORDER_KIND
        //      PAY_METHOD
        //      PAYMENT_TYPE
        //      ENTRUST_ADDR
        //      ENTRUST_DATE
        //      TAKE_ADDR
        //      TAKE_DATE
        //      START_LNG
        //      START_LAT
        //      END_LNG
        //      END_LAT
        //      BUYER_NAME
        //      BUYER_PHONE
        //      BUYER_MEMO
        //      PRO_COST
        //      S_TYPE
        //      M_TYPE
        //      L_TYPE
        //      XL_TYPE
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        // 출발 시간 string
        let startDateTime = getDateAndTime(date: startDate, removeDash: false)
        if startDateTime.count < 2 {
            let alert = _utils.createSimpleAlert(title: MyStrings.alertNeedCorrectTime.rawValue, message: "", buttonTitle: MyStrings.ok.rawValue)
            _utils.topViewController()?.present(alert, animated: true)
        }
        
        // 도착 시간 string
        let endDateTime = getDateAndTime(date: endDate, removeDash: false)
        if endDateTime.count < 2 {
            let alert = _utils.createSimpleAlert(title: MyStrings.alertNeedCorrectTime.rawValue, message: "", buttonTitle: MyStrings.ok.rawValue)
            _utils.topViewController()?.present(alert, animated: true)
        }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appUser.user,
            "DRIVER_MASTER_SEQ": driverMasterSeq,
            "DRIVER_USER_SEQ": driverUserSeq,
            "USER_SEQ": CarryUser.seq,
            "VECHILE_TYPE": vehicleType,
            "ORDER_KIND": orderKind,
            "PAY_METHOD": payMethod,
            "PAYMENT_TYPE": paymentType,
            "ENTRUST_ADDR": startAddr,
            "ENTRUST_DATE": startDateTime[0],
            "TAKE_ADDR": endAddr,
            "TAKE_DATE": endDateTime[0],
            "START_LNG": startLng ?? 0,
            "START_LAT": startLat ?? 0,
            "END_LNG": endLng ?? 0,
            "END_LAT": endLat ?? 0,
            "START_TIME": startDateTime[1],
            "END_TIME": endDateTime[1],
            "S_TYPE": s,
            "M_TYPE": m,
            "L_TYPE": l,
            "XL_TYPE": xl,
            "PRO_COST": cost,
            "BUYER_NAME": CarryUser.name,
            "BUYER_PHONE": CarryUser.phone,
            "BUYER_MEMO": buyerMemo
        ]
        
        let urlString = "/sys/payment/app/directPayMajorProcess.do"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, parameters: param, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[직영 운반사업자 검색]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
//                self.binding.bindingAirport(json: JSON(value), completion: completion)
                
                let json = JSON(value)
                let data = json["gerDirectDriverInfo"]
                let imgUrl = data["ATTACH_INFO"].stringValue
                let cost = data["PRICE"].intValue
                let driverNo = data["dicisionNo"].stringValue
                let name = data["BIZ_NAME"].stringValue
                let masterSeq = data["MASTER_SEQ"].stringValue
                let userSeq = data["USER_SEQ"].stringValue
                let driver = Driver()
                driver.userSeq = userSeq
                driver.masterSeq = masterSeq
                driver.imgUrl = imgUrl
                driver.name = name
                driver.cost = cost
                driver.driverNo = driverNo
                CarrySearch.drivers.insert(driver, at: 0)
                CarrySearch.directDriver = DirectDriverData(userSeq: userSeq, masterSeq: masterSeq, name: name, imgUrl: imgUrl, cost: String(cost), driverNo: driverNo)
                
                let oderSeq = json["resMsg"].stringValue
                completion?(true, oderSeq)
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
 
    // MARK: - 테스트 결제 요청
    func requestTestPurchasing(completion: ResponseString = nil) {
        
        let headers: HTTPHeaders = [
            "USER_TOKEN": CarryUser.token,
            "USER_ID": CarryUser.id,
            "USER_TYPE": CarrifreeAppType.appUser.user
        ]
        
        let urlString = "/sys/payment/app/getTestModuleCheck.do"
        let url = getRequestUrl(body: urlString)
        
        AF.request(url, method: .post, headers: headers) { $0.timeoutInterval = self.timeoutInterval }.validate().ResponseJson { (response) in
            
            let requestTitle = "[테스트 결제 요청]"
            self.printRequestInfo(requestTitle: requestTitle, response: response)
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let cd = json["resCd"].stringValue
                if cd == "Y" { completion?(true, "") }
                else { completion?(false, "") }
                
            case .failure(let error):
                MyLog.logWithArrow("\(requestTitle) failed", error.localizedDescription)
                completion?(false, error.localizedDescription)
            }
        }
    }
}



*/
