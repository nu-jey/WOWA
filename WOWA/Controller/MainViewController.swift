//
//  MainViewController.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/04.
//

import UIKit
import FSCalendar
import RealmSwift

class MainViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    let dateFormatter = DateFormatter()
    var rows = 1
    
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
              
        
        var today = dateFormatter.string(from: Date())
        var todayWork = WorkModel()
        todayWork = DatabaseManager.manager.loadSelectedDateWork(date: today)!
        //rows = todayWork.work.count
        print(todayWork)
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
    }
    
    @objc func swipeEvent(_ swipe: UISwipeGestureRecognizer) {
        if swipe.direction == .up {
            calendarView.setScope(.week, animated: true)
            print("up")
        } else if swipe.direction == .down {
            calendarView.setScope(.month, animated: true)
            print("down")
        }
    }
}

extension MainViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        var todayWork = DatabaseManager.manager.loadSelectedDateWork(date: dateFormatter.string(from: date))!
        print(todayWork)
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeight.constant = bounds.height
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineListCell", for: indexPath) as! RoutineListCell
        cell.bodyPart.text = "어깨"
        cell.name.text = "밀리터리 프레스"
        cell.set.text = "4"
        cell.rep.text = "10"
        return cell
    }
}

