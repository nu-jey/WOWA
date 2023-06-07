//
//  SessionDelegator.swift
//  WOWA
//
//  Created by 오예준 on 2023/06/05.
//

import Foundation
import WatchConnectivity
import Combine
import RealmSwift

class SessionDelegater: NSObject, WCSessionDelegate {
    let assistantSubject: PassthroughSubject<[String], Never>
    let assistantSubjectWorkList: PassthroughSubject<String, Never>
    
    init(assistantSubject: PassthroughSubject<[String], Never>, assistantSubjectWorkList: PassthroughSubject<String, Never>) {
        self.assistantSubject = assistantSubject
        self.assistantSubjectWorkList = assistantSubjectWorkList
        super.init()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Protocol comformance only
        // Not needed for this demo
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let weight = message["weight"] as? [String] {
                self.assistantSubject.send(weight)
                #if os(iOS)
                DatabaseManager.manager.addNewWeight(WorkID: DatabaseManager.manager.convertObjectID(weight[0])!, weight: Int(weight[2])!, currentSet:  Int(weight[1])!, totalSet: 0, reps: 0, date: "")
                #endif
                print(weight)
            } else if let workList = message["workList"] as? String {
                self.assistantSubjectWorkList.send(workList)
                
                print(workList)
            } else {
                print("There was an error")
            }
            
        }
    }
    
    // iOS Protocol comformance
    // Not needed for this demo otherwise
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Activate the new session after having switched to a new watch.
        session.activate()
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    #endif
    
}

