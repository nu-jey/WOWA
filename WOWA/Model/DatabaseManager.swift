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
    
    func editWork(work: Work, id: ObjectId) {
        if let editingWork = realm.object(ofType: Work.self, forPrimaryKey: id) {
            try! realm.write {
                editingWork.target = work.target
                editingWork.name = work.name
                editingWork.set = work.set
                editingWork.reps = work.reps
            }
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
    
    func deleteRoutine(id: ObjectId) {
        if let targetRoutine = realm.object(ofType: Routine.self, forPrimaryKey: id) {
            try! realm.write {
                realm.delete(targetRoutine)
            }
        } else {
            print("")
        }
    }
    
    func deleteWork(id: ObjectId) {
        if let targetWork = realm.object(ofType: Work.self, forPrimaryKey: id) {
            try! realm.write {
                realm.delete(targetWork)
            }
        }
    }
    
    func addNewWeight(WorkID: ObjectId, weight: Int, currentSet: Int, totalSet: Int, reps: Int, date: String) {
        if let targetWeight = realm.object(ofType: Weight.self, forPrimaryKey: WorkID) {
            // 기존에 weight 모델 데이터 값을 수정
            try! realm.write {
                targetWeight.weightPerSet[currentSet] = weight
            } 
        } else {
            // 새로운 weight 모델 추가
            try! realm.write {
                var newWeight = Weight(WorkID: WorkID, set: totalSet, reps: reps, date: date)
                realm.add(newWeight)
            }
        }
    }
    
    func laodWeight(WorkID: ObjectId) -> [Int]? {
        if let targetWeight = realm.object(ofType: Weight.self, forPrimaryKey: WorkID) {
            return targetWeight.weightPerSet.map {$0}
        } else {
            return nil
        }
    }
    
    func deleteWorkInSchedule(scheduleID: ObjectId, workID: ObjectId) {
        if let targetSchedule = realm.object(ofType: Schedule.self, forPrimaryKey: scheduleID) {
            if let targetWork = realm.object(ofType: Work.self, forPrimaryKey: workID) {
                try! realm.write {
                    let tempWorkList = targetSchedule.workList
                    tempWorkList.remove(at: tempWorkList.firstIndex(of: targetWork)!)
                    targetSchedule.workList = tempWorkList
                }
            } else {
                return
            }
        } else {
            return
        }
        
    }
    
    func addRoutineInSchedule(routineID: ObjectId, scheduleID: ObjectId) {
        if let targetSchedule = realm.object(ofType: Schedule.self, forPrimaryKey: scheduleID) {
            if let targetRoutine = realm.object(ofType: Routine.self, forPrimaryKey: routineID) {
                try! realm.write {
                    for work in targetRoutine.workList{
                        let newWork = Work(target: work.target, name: work.name, set: work.set, reps: work.reps)
                        targetSchedule.workList.append(newWork)
                        let newWeight = Weight(WorkID: newWork._id, set: newWork.set, reps: newWork.reps, date: targetSchedule.date)
                        realm.add(newWeight)
                    }
                }
            } else {
                return
            }
        } else {
            return
        }
    }
    
    func removeSetInWork(WorkId: ObjectId, setNum: Int) {
        if let targetWeight = realm.object(ofType: Weight.self, forPrimaryKey: WorkId) {
            try! realm.write {
                targetWeight.weightPerSet.remove(at: setNum)
                targetWeight.repsPerSet.remove(at: setNum)
            }
        }
        if let targetWork = realm.object(ofType: Work.self, forPrimaryKey: WorkId) {
            try! realm.write {
                targetWork.set -= 1
            }
        }
    }
    
    func editRepsInWeight(WorkID: ObjectId, setNum: Int, reps: Int) {
        if let targetWeight = realm.object(ofType: Weight.self, forPrimaryKey: WorkID) {
            try! realm.write {
                targetWeight.repsPerSet[setNum] = reps
            }
        }
    }
    
    func loadSelectedDateWeights(date: String) -> Results<Weight>? {
        return realm.objects(Weight.self).filter("date == '\(date)'")
    }
    
    func loadAllScheduleDate() -> [String] {
        return realm.objects(Schedule.self).map { $0.date }
    }
    
    func loadWeightDataForWeek() -> [Int] {
        var result = [Int]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for i in (0...6).reversed() {
            let date = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -i, to: Date())!)
            result.append(realm.objects(Weight.self).filter("date == '\(date)'").map { $0.weightPerSet.filter { $0 >= 0 }.reduce(0, +)}.reduce(0, +))
        }
        return (result)
    }
    func loadWeightDataForMonth() -> [Int] {
        var result = [Int]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for i in (0...30).reversed() {
            let date = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -i, to: Date())!)
            result.append(realm.objects(Weight.self).filter("date == '\(date)'").map { $0.weightPerSet.filter { $0 >= 0}.reduce(0, +)}.reduce(0, +))
        }
        return result
    }
    
    func loadWeightDataForYear() -> [Int] {
        var result = [Int]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        
        for i in (0...11).reversed() {
            let date = dateFormatter.string(from: Calendar.current.date(byAdding: .month, value: -i, to: Date())!)
            result.append(realm.objects(Weight.self).filter("date CONTAINS '\(date)'").map { $0.weightPerSet.filter { $0 >= 0}.reduce(0, +)}.reduce(0, +))
        }
        return result
    }
    
    func loadWeightDataForSpiderChart() -> [Int] {
        var result = Array(repeating: 0, count: wowa.bodyPart.count)
        for w in realm.objects(Weight.self) {
            if let part = realm.object(ofType: Work.self, forPrimaryKey: w.WorkID)?.target {
                result[wowa.bodyPart.firstIndex(of: part)!] += w.weightPerSet.filter { $0 > 0 }.reduce(0, +)
            }
        }
        return result
    }
   
    
}
