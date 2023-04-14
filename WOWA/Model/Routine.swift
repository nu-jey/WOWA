//
//  Routine.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/10.
//

import Foundation
import RealmSwift

class Routine: Object {
    @Persisted var workList = List<Work>()
    @Persisted var routineName: String
    @Persisted var routineDiscription: String?
    @Persisted(primaryKey: true) var _id: ObjectId
    
    convenience init(workList: List<Work> = List<Work>(), routineName: String, routineDiscription: String? = nil) {
        self.init()
        self.workList = workList
        self.routineName = routineName
        self.routineDiscription = routineDiscription
    }
}
