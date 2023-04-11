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

    func loadSelectedDateWork(date: String) -> Results<Work>? {
        var res = realm.objects(Work.self).filter("date == '\(date)'")
        if res.count == 0 {
            return nil
        } else {
            return res
        }
    }
    
    func addWork(work: Work) {
        do {
            try realm.write {
                realm.add(work)
            }
        } catch {
            print(error)
        }
    }
}
