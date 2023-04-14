//
//  File.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/05.
//

import Foundation
import RealmSwift

class Work: Object{
    @Persisted var target: String
    @Persisted var name: String
    @Persisted var set: Int
    @Persisted var reps: Int
    @Persisted(primaryKey: true) var _id: ObjectId
    
    convenience init(target: String, name: String, set: Int, reps: Int) {
        self.init()
        self.target = target
        self.name = name
        self.set = set
        self.reps = reps
    }
}

