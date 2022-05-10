//
//  HelpVm.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/25.
//

import Foundation

typealias Answer = (title: String, desc: String)

class HelpVm {
    var keywords: [String] = []
    var answers: [Answer] = []
    var dummyAnswers: [Answer] = []
    
    init() {
        setDummyDatas()
    }
    
    func setDummyDatas() {
        keywords = [
            "TOP 5",
            "이용문의",
            "불편사항",
            "분실신고"
        ]
        
        dummyAnswers = [
            ("1번 질문입니다", "1번 답변입니다\n1번 답변입니다\n1번 답변입니다"),
            ("2번 질문입니다", "2번 답변입니다"),
            ("3번 질문입니다", "3번 답변입니다\n3번 답변입니다\n3번 답변입니다\n3번 답변입니다\n3번 답변입니다\n3번 답변입니다"),
            ("4번 질문입니다", "4번 답변입니다\n4번 답변입니다"),
            ("5번 질문입니다", "5번 답변입니다\n5번 답변입니다\n5번 답변입니다\n5번 답변입니다"),
            ("6번 질문입니다", "6번 답변입니다"),
            ("7번 질문입니다", "7번 답변입니다\n7번 답변입니다\n7번 답변입니다"),
            ("8번 질문입니다", "8번 답변입니다\n8번 답변입니다"),
            ("9번 질문입니다", "9번 답변입니다\n9번 답변입니다\n9번 답변입니다\n9번 답변입니다"),
            ("10번 질문입니다", "10번 답변입니다\n10번 답변입니다\n10번 답변입니다\n10번 답변입니다\n10번 답변입니다")
        ]
    }
    
    func getRandomDummyDatas() -> [Answer] {
        var result: [Answer] = []
        let answerCount = Int.random(in: 0 ... 8)
        for _ in 0 ..< answerCount {
            let randomIndex = Int.random(in: 0 ..< dummyAnswers.count)
            result.append(dummyAnswers[randomIndex])
        }
        
        return result
    }
    
    func lookup(word: String, completion: ResponseString = nil) {
        // 서버에 검색 요청
        // ...
        //
        answers.removeAll()
        answers = getRandomDummyDatas()
        completion?(true, "")
    }
}
