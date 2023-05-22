//
//  SettingInfo.swift
//  WOWA
//
//  Created by 오예준 on 2023/05/18.
//

import Foundation
import RealmSwift

class SettingInfo: Object{
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var set: Int
    @Persisted var rep: Int
    @Persisted var bodyPart = List<String>()
        
    convenience init(set: Int, rep: Int, bodyPart: [String]) {
        self.init()
        self.set = set
        self.rep = rep
        self.bodyPart = List()
        self.bodyPart.append(objectsIn: bodyPart)
    }
}
