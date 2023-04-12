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

class MainViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    
    let dateFormatter = DateFormatter()
    var rows = 1
    var tableViewData = [Work]()
    var today = ""
    
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
        loadTodayWorks()
        // print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    func loadTodayWorks() {
        today = dateFormatter.string(from: Date())
        if let todayWorks = DatabaseManager.manager.loadSelectedDateWork(date: today) {
            tableViewData = todayWorks.map{ $0 }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            print("오늘 날짜의 운동 없음 ")
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
        loadTodayWorks()
    }
    
    // delegate를 설정하여 AddWorkView로부터 데이터가 추가됨을 확인받고 테이블 뷰 reload
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let addViewController = segue.destination as? AddWorkViewController else {
            return
        }
        addViewController.delegate = self
    }
    
}

// MARK: - AddWorkViewControllerDelegate Method
extension MainViewController: AddWorkViewControllerDelegate {
    func addWorkAndReload() {
        print("추가 후 리로딩")
        loadTodayWorks()
    }
}

// MARK: - FSCalendar Methods
extension MainViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        var todayWork = DatabaseManager.manager.loadSelectedDateWork(date: dateFormatter.string(from: date))!
//        print(todayWork)
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeight.constant = bounds.height
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - TableView Methods
extension MainViewController: UITableViewDataSource {
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
    
}

