//
//  File.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/05.
//

import Foundation
import RealmSwift

class WorkModel: Object{
    @objc dynamic var date: String = "2023-04-05"
    var work = List<Work>()
    // id 가 고유 값입니다.
    override static func primaryKey() -> String? {
        return "date"
    }
}

class Work: Object{
    @objc dynamic var target: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var set: Int = 0
    @objc dynamic var reps: Int = 0
}

