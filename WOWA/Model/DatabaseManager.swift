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

    // MARK: - Work Methods
    func loadSelectedDateWork(date: String) -> Results<Work>? {
        var resWork = realm.objects(Work.self).filter("date == '\(date)'")
        if resWork.count == 0 {
            return nil
        } else {
            return resWork
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
    
    // MARK: - Routine Methods
    func loadAllRoutine() -> Results<Routine>? {
        var resRoutine =  realm.objects(Routine.self)
        if resRoutine.count == 0 {
            return nil
        } else {
            return resRoutine
        }
    }
    
    
    
}
