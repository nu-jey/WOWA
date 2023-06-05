//
//  Assistant.swift
//  WOWA
//
//  Created by 오예준 on 2023/06/05.
//

import Foundation
import WatchConnectivity
import Combine

final class Assistant: ObservableObject {
    var session: WCSession
    let delegate: WCSessionDelegate
    let subject = PassthroughSubject<Int, Never>()
    let subjectWorkList = PassthroughSubject<String, Never>()
    
    @Published private(set) var weight: Int = 0
    @Published private(set) var workList: String = ""
    
    init(session: WCSession = .default) {
        self.delegate = SessionDelegater(assistantSubject: subject, assistantSubjectWorkList: subjectWorkList)
        self.session = session
        self.session.delegate = self.delegate
        self.session.activate()
        
        subject.receive(on: DispatchQueue.main).assign(to: &$weight)
        subjectWorkList.receive(on: DispatchQueue.main).assign(to: &$workList)
    }
    
    func addWeight(_ w: Int) {
        weight = w
        session.sendMessage(["weight": weight], replyHandler: nil) { error in
            print("에러 발생: ")
            print(error.localizedDescription)
        }
    }
    
    func checkWeight() -> Int {
        return weight
    }
    
    func loadWorkList(wl: String) {
        workList = wl
        session.sendMessage(["workList": workList], replyHandler: nil) { error in
            print("에러 발생: ")
            print(error.localizedDescription)
        }
    }
    
}
