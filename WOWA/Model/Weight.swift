//
//  Weight.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/22.
//

import Foundation
import RealmSwift

class Weight: Object {
    @Persisted(primaryKey: true) var WorkID: ObjectId
    @Persisted var weightPerSet = List<Int>()
    
    convenience init(WorkID: ObjectId, set: Int) {
        self.init()
        self.WorkID = WorkID
        self.weightPerSet = List<Int>()
        for _ in 1...set {
            self.weightPerSet.append(-1)
        }
    }
}
