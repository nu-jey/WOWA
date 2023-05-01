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
    @Persisted var repsPerSet = List<Int>()
    @Persisted var date: String
    
    convenience init(WorkID: ObjectId, set: Int, reps: Int, date: String) {
        self.init()
        self.WorkID = WorkID
        self.weightPerSet = List<Int>()
        self.repsPerSet = List<Int>()
        self.date = date
        for _ in 1...set {
            self.weightPerSet.append(-1)
        }
        for _ in 1...set {
            self.repsPerSet.append(reps)
        }
    }
}
