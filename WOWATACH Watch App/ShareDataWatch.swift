//
//  ShareDataWatch.swift
//  WOWA
//
//  Created by 오예준 on 2023/06/04.
//

import Foundation
import WatchConnectivity

class ShareDataWatch: NSObject, WCSessionDelegate, ObservableObject {
#if os(iOS)
public func sessionDidBecomeInactive(_ session: WCSession) { }
public func sessionDidDeactivate(_ session: WCSession) {
    session.activate()
}
#endif
    
    @Published var messageText = ""
    var session: WCSession
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
    
    func test() -> String {
        return messageText
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
                
    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.messageText = message["message"] as? String ?? "Unknown"
            print(self.messageText)
        }
    }
    
    
}
