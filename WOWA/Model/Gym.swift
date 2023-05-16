//
//  File.swift
//  WOWA
//
//  Created by 오예준 on 2023/05/16.
//

import Foundation
import RealmSwift

class Gym: Object{
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var gymName: String
    @Persisted var location = List<Double>()
    
    convenience init(gymName: String, location: [Double]) {
        self.init()
        self.gymName = gymName
        self.location = List()
        self.location.append(objectsIn: location)
    }
}
