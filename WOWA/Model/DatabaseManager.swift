//
//  DatabaseManager.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/06.
//

import Foundation
import RealmSwift

class DatabaseManager{
    
    static let manager = DatabaseManager()
    private var realm: Realm
    init() {
        realm = try! Realm()
    }

    func loadSelectedDateWork(date: String) -> WorkModel? {
        if let res = realm.objects(WorkModel.self).filter("date == '\(date)'").first {
            return res
        } else {
            return WorkModel()
        }
    }
}
