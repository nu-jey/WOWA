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
    
    func loadRoutineData(id: ObjectId) -> Routine? {
        if let resRoutine = realm.object(ofType: Routine.self, forPrimaryKey: id) {
            return resRoutine
        } else {
            return nil
        }
    }
    
    
    func loadSelectedDateSchedule(date: String) -> Schedule? {
        if let resWork = realm.objects(Schedule.self).filter("date == '\(date)'").first {
            return resWork
        } else {
            return nil
        }
    }
    
    func addWorkInRoutine(newWork: Work, id: ObjectId) {
        if let routine = realm.object(ofType: Routine.self, forPrimaryKey: id) {
            try! realm.write {
                routine.workList.append(newWork)
            }
        } else {
            print("routine에 work 추가 불가능")
        }
    }
    
    func addWorkInSchedule(newWork: Work, id: ObjectId) {
        if let schedule = realm.object(ofType: Schedule.self, forPrimaryKey: id) {
            try! realm.write {
                schedule.workList.append(newWork)
            }
        } else {
            print("schedule에 work 추가 불가능")
        }
    }
    
    func loadAllRoutine() -> Results<Routine>? {
        let resRoutine =  realm.objects(Routine.self)
        if resRoutine.count == 0 {
            return nil
        } else {
            return resRoutine
        }
    }
    
    func addNewSchedule(date: String) -> Schedule {
        let newSchedule = Schedule(date: date)
        try! realm.write {
            realm.add(newSchedule)
        }
        return newSchedule
    }
    
    func addNewRoutine(_ newRuotine: Routine) {
        try! realm.write {
            realm.add(newRuotine)
        }
    }
    
    func editRoutine(routine: Routine, id: ObjectId) {
        if let editingRoutine = realm.object(ofType: Routine.self, forPrimaryKey: id) {
            try! realm.write {
                editingRoutine.workList = routine.workList
                editingRoutine.routineName = routine.routineName
                editingRoutine.routineDiscription = routine.routineDiscription
            }
        } else {
            print("편집한 routine 저장 불가")
        }
    }
}
