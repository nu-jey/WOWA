//
//  Routine.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/10.
//

import Foundation
import RealmSwift

class Routine: Object {
    var workList = List<Work>()
    @objc dynamic var routineName: String = ""
    @objc dynamic var routineDiscription: String = ""
}
