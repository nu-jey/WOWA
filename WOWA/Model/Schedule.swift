//
//  Schedule.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/14.
//

import Foundation
import RealmSwift

class Schedule: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var workList = List<Work>()
    @Persisted var date: String
    
    convenience init(workList: List<Work> = List<Work>(), date: String) {
        self.init()
        self.workList = workList
        self.date = date
    }
}
