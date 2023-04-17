//
//  MainViewController.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/04.
//

import UIKit
import FSCalendar
import RealmSwift

protocol AddWorkViewControllerDelegate: AnyObject {
    func addWorkAndReload()
}

class MainViewController: UIViewController {
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    
    let dateFormatter = DateFormatter()
    var rows = 1
    var tableViewData = [Work]()
    var scheduleID: ObjectId?
    var today = ""
    var currentWorkIsEditing = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.backgroundColor = .white
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.appearance.headerDateFormat = "YYYY년 MM월"
        dateFormatter.dateFormat = "yyyy-MM-dd"
        calendarView.delegate = self
        calendarView.dataSource = self
        
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeEvent(_:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeEvent(_:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RoutineListCell", bundle: nil), forCellReuseIdentifier: "RoutineListCell")
        loadTodaySchedule()
        // print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    func loadTodaySchedule() {
        today = dateFormatter.string(from: Date())
        if let todayWorks = DatabaseManager.manager.loadSelectedDateSchedule(date: today) {
            tableViewData = todayWorks.workList.map{ $0 }
            scheduleID = todayWorks._id
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            let newSchedule = DatabaseManager.manager.addNewSchedule(date: today)
            tableViewData = newSchedule.workList.map{ $0 }
            scheduleID = newSchedule._id
        }
    }
    
    @objc func swipeEvent(_ swipe: UISwipeGestureRecognizer) {
        if swipe.direction == .up {
            calendarView.setScope(.week, animated: true)
        } else if swipe.direction == .down {
            calendarView.setScope(.month, animated: true)
            UIView.animate(withDuration: 0.3, delay: 0, animations: {self.view.layoutIfNeeded()}, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentWorkIsEditing = -1
        loadTodaySchedule()
    }
    
    // delegate를 설정하여 AddWorkView로부터 데이터가 추가됨을 확인받고 테이블 뷰 reload
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let addViewController = segue.destination as? AddWorkViewController else {
            return
        }
        if currentWorkIsEditing >= 0 {
            addViewController.workID = tableViewData[currentWorkIsEditing]._id
            addViewController.editingWorkTargetIndex = currentWorkIsEditing
            addViewController.editingWorkTargetRep = tableViewData[currentWorkIsEditing].reps
            addViewController.editingWorkTargetSet = tableViewData[currentWorkIsEditing].set
            addViewController.editingWorkTargetName = tableViewData[currentWorkIsEditing].name
        }
        addViewController.scheduleID = scheduleID!
        addViewController.delegate = self
    }
}

// MARK: - AddWorkViewControllerDelegate Method
extension MainViewController: AddWorkViewControllerDelegate {
    func addWorkAndReload() {
        loadTodaySchedule()
    }
}

// MARK: - FSCalendar Methods
extension MainViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //print(dateFormatter.string(from: date))
        print(date, Date())
        let selectedDate = dateFormatter.string(from: date)
        if  selectedDate == dateFormatter.string(from: Date()) {
            loadTodaySchedule()
        } else {
            if let selectedDateSchedule = DatabaseManager.manager.loadSelectedDateSchedule(date: selectedDate) {
                tableViewData = selectedDateSchedule.workList.map{ $0 }
                scheduleID = selectedDateSchedule._id
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                tableViewData = []
                scheduleID = nil
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeight.constant = bounds.height
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - TableView Methods
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineListCell", for: indexPath) as! RoutineListCell
        cell.bodyPart.text = tableViewData[indexPath.row].target
        cell.name.text = tableViewData[indexPath.row].name
        cell.set.text = String(tableViewData[indexPath.row].set)
        cell.rep.text = String(tableViewData[indexPath.row].reps)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print(tableViewData[indexPath.row])
        let delete = UIContextualAction(style: .normal, title: "Delete") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            print("Delete 클릭 됨")
            DatabaseManager.manager.deleteWork(id: self.tableViewData[indexPath.row]._id)
            self.loadTodaySchedule()
            success(true)
        }
        delete.backgroundColor = .systemRed
        
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.currentWorkIsEditing = indexPath.row
            self.performSegue(withIdentifier: "showAddWorkView", sender: nil)
            success(true)
        }
        edit.backgroundColor = .systemTeal
        
        return UISwipeActionsConfiguration(actions:[delete, edit])
    }
}

