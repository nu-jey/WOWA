//
//  File.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/05.
//

import Foundation
import RealmSwift

class Work: Object{
    @objc dynamic var date: String = ""
    @objc dynamic var target: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var set: Int = 0
    @objc dynamic var reps: Int = 0
}

