//
//  MainViewController.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/04.
//

import UIKit
import FSCalendar
import RealmSwift
import CoreLocation
import SwiftUI
import WatchConnectivity

protocol AddWorkViewControllerDelegate: AnyObject {
    func addWorkAndReload()
}

class MainViewController: UIViewController {
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedDateTotalWeight: UILabel!
    @IBOutlet weak var imageViewGymStatus: UIImageView!
    
    
    let dateFormatter = DateFormatter()
    var rows = 1
    var tableViewData = [Work]()
    var tableViewDataWeight = [Weight]()
    var scheduleID: ObjectId?
    var scheduleDates =  [String]()
    var today = ""
    var currentWorkIsEditing = -1
    var currentSelectedDate: String?
    var selectedIndex: Int?
    var hiddenSections = Set<Int>()
    var locationManger = CLLocationManager()
    var isGym = false
    
    @State var text = "test is worked"
    @ObservedObject var assistant = Assistant()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("realm 위치: ", Realm.Configuration.defaultConfiguration.fileURL!)
        // FSCalendar 설정
        calendarView.backgroundColor = .white
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.appearance.headerDateFormat = "YYYY년 MM월"
        calendarView.appearance.weekdayTextColor = UIColor(named: "sideColor2")
        calendarView.appearance.headerTitleColor = UIColor(named: "sideColor2")
        calendarView.appearance.selectionColor = UIColor(named: "signatureColor")
        calendarView.appearance.todayColor = UIColor(named: "sideColor1")
        calendarView.appearance.todaySelectionColor = UIColor(named: "signatureColor")
        calendarView.appearance.eventDefaultColor = UIColor(named: "sideColor1")
        calendarView.appearance.eventSelectionColor = UIColor(named: "sideColor1")
        calendarView.appearance.titleDefaultColor = UIColor(named: "sideColor2")
        calendarView.appearance.titlePlaceholderColor = UIColor(named: "sideColor2")!.withAlphaComponent(0.2)
        calendarView.backgroundColor = UIColor.secondarySystemBackground
        dateFormatter.dateFormat = "yyyy-MM-dd"
        calendarView.layer.cornerCurve = .continuous
        calendarView.layer.cornerRadius = 10.0
        calendarView.delegate = self
        calendarView.dataSource = self
        
        // tableView 설정
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeEvent(_:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeEvent(_:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
        
        // 오늘 운동 정보 불러오기 
        currentSelectedDate = dateFormatter.string(from: Date())
        loadSchedule(currentSelectedDate!)
        foldAllSections()
        
        // 위치 정보
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest // 위치 정확도 -> 최고 수준으로
        locationManger.requestWhenInUseAuthorization()
        isGymNow()
    }
    
    func shareScheduleForWatch() {
        let convertedData =
          """
            \(tableViewData)
            """
        assistant.loadWorkList(wl: convertedData)
    }
    
    
    func loadSchedule(_ date: String) {
        if let selectedDateWorks = DatabaseManager.manager.loadSelectedDateSchedule(date: date) {
            tableViewData = selectedDateWorks.workList.map{ $0 }
            tableViewDataWeight = []
            var weightSum = 0
            for weight in DatabaseManager.manager.loadSelectedDateWeights(date: currentSelectedDate!)! {
                weightSum += weight.weightPerSet.filter { $0 != -1 }.reduce(0, +)
                tableViewDataWeight.append(weight)
            }
            selectedDateTotalWeight.text = " 들어올린 무게: \(weightSum)Kg"
            scheduleID = selectedDateWorks._id
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            let newSchedule = DatabaseManager.manager.addNewSchedule(date: date)
            tableViewData = newSchedule.workList.map{ $0 }
            scheduleID = newSchedule._id
        }
        scheduleDates = DatabaseManager.manager.loadAllScheduleDate()
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
        shareScheduleForWatch()
        loadSchedule(currentSelectedDate!)
        foldAllSections()
        isGymNow()
    }
    
    // delegate를 설정하여 AddWorkView로부터 데이터가 추가됨을 확인받고 테이블 뷰 reload
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addViewController = segue.destination as? AddWorkViewController {
            if currentWorkIsEditing >= 0 {
                addViewController.workID = tableViewData[currentWorkIsEditing]._id
                addViewController.editingWorkIndex = currentWorkIsEditing
                addViewController.editingWorkTargetIndex = wowa.bodyPart.firstIndex(of: tableViewData[currentWorkIsEditing].target)!
                addViewController.editingWorkTargetRep = tableViewData[currentWorkIsEditing].reps
                addViewController.editingWorkTargetSet = tableViewData[currentWorkIsEditing].set
                addViewController.editingWorkTargetName = tableViewData[currentWorkIsEditing].name
                currentWorkIsEditing = -1
            }
            addViewController.scheduleID = scheduleID!
            addViewController.selectedDate = currentSelectedDate
            addViewController.delegate = self
        } else if let addRoutineViewController = segue.destination as? AddRoutineViewController {
            addRoutineViewController.scheduleID = self.scheduleID
            addRoutineViewController.date = currentSelectedDate
            addRoutineViewController.delegate = self
        } else {
            return
        }
    }
    
    @objc private func hideSection(sender: UIButton) {
        let section = sender.tag
        
        func indexPathsForSection() -> [IndexPath] {
            var indexPaths = [IndexPath]()
            for row in 0..<self.tableViewData[section].set {
                indexPaths.append(IndexPath(row: row, section: section))
            }
            return indexPaths
        }
        
        if self.hiddenSections.contains(section) {
            self.hiddenSections.remove(section)
            self.tableView.insertRows(at: indexPathsForSection(), with: .fade)
        } else {
            self.hiddenSections.insert(section)
            self.tableView.deleteRows(at: indexPathsForSection(), with: .fade)
        }
    }
    
    func foldAllSections() {
        for i in 0..<tableViewData.count {
            if tableView.numberOfRows(inSection: i) > 0 {
                var indexPaths = [IndexPath]()
                for row in 0..<self.tableViewData[i].set {
                    indexPaths.append(IndexPath(row: row, section: i))
                }
                self.hiddenSections.insert(i)
                self.tableView.deleteRows(at: indexPaths, with: .none)
            }
        }
    }
    
    func unfoldAllSections() {
        for i in 0..<tableViewData.count {
            if tableView.numberOfRows(inSection: i) == 0 {
                var indexPaths = [IndexPath]()
                for row in 0..<self.tableViewData[i].set {
                    indexPaths.append(IndexPath(row: row, section: i))
                }
                self.hiddenSections.remove(i)
                self.tableView.insertRows(at: indexPaths,  with: .fade)
            }
        }
    }
    
    @objc func editButtonPressed(_ gesture: UITapGestureRecognizer) {
        currentWorkIsEditing = (gesture.view?.tag)!
        performSegue(withIdentifier: "showAddWorkView", sender: nil)
    }
    
    @objc func removeButtonPressed(_ gesture: UITapGestureRecognizer) {
        selectedIndex = (gesture.view?.tag)!
        let sheet = UIAlertController(title: "Routine 삭제", message: "해당 Routine을 삭제하시나요?", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in }))
        sheet.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [self] _ in
            print(selectedIndex!)
            DatabaseManager.manager.deleteWorkInSchedule(scheduleID: scheduleID!, workID: tableViewData[selectedIndex!]._id)
            loadSchedule(currentSelectedDate!)
        }))
        present(sheet, animated: true)
    }
    
    @objc func addWeightButtonPressed(sender: UIButton) {
        if isGym {
            let alert = UIAlertController(title: "운동 완료", message: "무게 등록", preferredStyle: .alert)
            let add = UIAlertAction(title: "Add", style: .default) { (ok) in
                sender.setTitle((alert.textFields![0].text)! + "Kg", for: .normal)
                let sectionAndRow = self.numConvert2(input: sender.tag)
                let section = sectionAndRow[0]
                let row = sectionAndRow[1]
                let addedWeight = Int(alert.textFields![0].text!)!
                let targetWork = self.tableViewData[section]
                DatabaseManager.manager.addNewWeight(WorkID: targetWork._id, weight: addedWeight, currentSet: row, totalSet: targetWork.set, reps: targetWork.reps, date: self.currentSelectedDate!)
                self.loadSchedule(self.currentSelectedDate!)
                
            }
            
            let cancel = UIAlertAction(title: "cancel", style: .cancel) { (cancel) in
                print(sender)
            }
            
            alert.addAction(cancel)
            alert.addAction(add)
            alert.addTextField()
            alert.textFields![0].placeholder = "등록 무게 단위는 Kg"
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "헬스장이 아닙니다", message: "헬스장 이동후 운동을 수행하세요", preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .cancel) { (cancel) in
                print(sender)
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func numConvert1(input: [Int]) -> Int {
        return Int(input.map(String.init).joined())!
    }
    
    func numConvert2(input: Int) -> [Int] {
        let array = String(input).map { Int(String($0))! }
        print(array)
        // section 정보 꺼내기
        let sectionCount = array[0]
        var temp = [Int]()
        for i in 1...sectionCount {
            temp.append(array[i])
        }
        let sectionValue = temp.reduce(0, { $0 * 10 + $1})
        
        temp = []
        for i in sectionCount+String(sectionValue).count + 1..<array.count {
            temp.append(array[i])
        }
        let rowValue = temp.reduce(0, { $0 * 10 + $1})
        
        return [sectionValue, rowValue]
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            foldAllSections()
        case 1:
            unfoldAllSections()
        default: return 
        }
    }
    
    func isGymNow() {
        if let gymInfo = DatabaseManager.manager.loadGymInfo() {
            let from = CLLocation(latitude: gymInfo.location[0], longitude: gymInfo.location[1])
            let to = CLLocation(latitude: (locationManger.location?.coordinate.latitude)!, longitude: (locationManger.location?.coordinate.longitude)!)
    
            print(from.distance (from: to))
            if from.distance (from: to) > 100 {
                imageViewGymStatus.tintColor = UIColor(named: "sideColor4")
                isGym = false
            } else {
                imageViewGymStatus.tintColor = UIColor(named: "signatureColor")
                isGym = true
            }
        }
    }
    
}

// MARK: - AddWorkViewControllerDelegate Method
extension MainViewController: AddWorkViewControllerDelegate {
    func addWorkAndReload() {
        DispatchQueue.main.async {
            self.loadSchedule(self.currentSelectedDate!)
        }
        foldAllSections()
    }
    
}


// MARK: - FSCalendar Methods
extension MainViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currentSelectedDate = dateFormatter.string(from: date)
        if let selectedDateSchedule = DatabaseManager.manager.loadSelectedDateSchedule(date: currentSelectedDate!) {
            loadSchedule(currentSelectedDate!)
            hiddenSections = Set(0..<tableViewData.count)
            
        } else {
            tableViewData = []
            tableViewDataWeight = []
            scheduleID = nil
            selectedDateTotalWeight.text = "아직 운동전 입니다!"
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeight.constant = bounds.height
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if self.scheduleDates.contains(dateFormatter.string(from: date)){
            return 1
        }
        return 0
    }
    
    
}

// MARK: - TableView Methods
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.backgroundColor = .white
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.backgroundColor = UIColor(named: "sideColor4")
        stackView.layer.cornerRadius = 5
        
        let sectionButton = UIButton()
        sectionButton.setTitle("\(tableViewData[section].target) - \(tableViewData[section].name)", for: .normal)
        sectionButton.tag = section
        sectionButton.contentHorizontalAlignment = .left // 버튼 텍스트 왼쪽 정렬
        sectionButton.addTarget(self,action: #selector(self.hideSection(sender:)),for: .touchUpInside)
        
        let editButton = UIImageView()
        editButton.image = UIImage(systemName: "pencil")
        editButton.tag = section
        editButton.tintColor = UIColor(named: "signatureColor")
        let editTapGesture = UITapGestureRecognizer(target: self, action: #selector(editButtonPressed(_:)))
        editButton.addGestureRecognizer(editTapGesture)
        editButton.isUserInteractionEnabled = true
        
        let removeButton = UIImageView()
        removeButton.image = UIImage(systemName: "trash")
        removeButton.tag = section
        removeButton.tintColor = UIColor(named: "signatureColor")
        let removeTapGesture = UITapGestureRecognizer(target: self, action: #selector(removeButtonPressed(_:)))
        removeButton.addGestureRecognizer(removeTapGesture)
        removeButton.isUserInteractionEnabled = true
        
        stackView.addArrangedSubview(sectionButton)
        stackView.addArrangedSubview(editButton)
        stackView.addArrangedSubview(removeButton)
        // 패딩 설정
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        return stackView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.hiddenSections.contains(section) {
            return 0
        }
        return tableViewData[section].set
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
        cell.currentSetTextField.text = "Set " + String(indexPath.row + 1)
        cell.currentRepsTextField.text = String(tableViewDataWeight[indexPath.section].repsPerSet[indexPath.row]) + "Reps"
        let convertValue = [String(indexPath.section).count, indexPath.section, String(indexPath.row).count, indexPath.row]
        cell.addWeightButton.tag = numConvert1(input: convertValue)
        cell.addWeightButton.addTarget(self, action: #selector(addWeightButtonPressed(sender:)), for: .touchUpInside)
        if let weightList = DatabaseManager.manager.laodWeight(WorkID: tableViewData[indexPath.section]._id) {
            let weight = weightList[indexPath.row] >= 0 ? String(weightList[indexPath.row]) + "Kg" : "Work"
            cell.addWeightButton.setTitle(weight, for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            print(indexPath.section, indexPath.row)
            DatabaseManager.manager.removeSetInWork(WorkId: self.tableViewData[indexPath.section]._id, setNum: indexPath.row)
            self.loadSchedule(self.currentSelectedDate!)
            success(true)
        }
        delete.backgroundColor = .systemRed
        
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            
            let alert = UIAlertController(title: "Reps 변경", message: "변경 Reps 작성", preferredStyle: .alert)
            let add = UIAlertAction(title: "Edit", style: .default) { (ok) in
                let newReps = (alert.textFields![0].text)!
                DatabaseManager.manager.editRepsInWeight(WorkID: self.tableViewData[indexPath.section]._id, setNum: indexPath.row, reps: Int(newReps)!)
                self.loadSchedule(self.currentSelectedDate!)
            }
            
            let cancel = UIAlertAction(title: "cancel", style: .cancel) { (cancel) in
                
            }
            
            alert.addAction(cancel)
            alert.addAction(add)
            alert.addTextField()
            alert.textFields![0].placeholder = "등록 무게 단위는 Kg"
            self.present(alert, animated: true, completion: nil)
            
            success(true)
        }
        edit.backgroundColor = .systemTeal
        
        return UISwipeActionsConfiguration(actions:[delete, edit])
    }
}

// MARK: - Selection Heading
extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 위치 정보 업데이트
        print("123")
        if let location = locations.first {
            print("위도: \(location.coordinate.latitude)")
            print("경도: \(location.coordinate.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
