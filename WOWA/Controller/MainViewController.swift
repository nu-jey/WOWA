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
    var currentSelectedDate: String?
    var selectedIndex: Int?
    var hiddenSections = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FSCalendar 설정
        calendarView.backgroundColor = .white
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.appearance.headerDateFormat = "YYYY년 MM월"
        dateFormatter.dateFormat = "yyyy-MM-dd"
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
        currentSelectedDate = dateFormatter.string(from: Date())
        loadSchedule(currentSelectedDate!)
        hideAllSections()
        
    }
    
    func loadSchedule(_ date: String) {
        if let selectedDateWorks = DatabaseManager.manager.loadSelectedDateSchedule(date: date) {
            tableViewData = selectedDateWorks.workList.map{ $0 }
            scheduleID = selectedDateWorks._id
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            let newSchedule = DatabaseManager.manager.addNewSchedule(date: date)
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
        loadSchedule(currentSelectedDate!)
        hideAllSections()
    }
    
    // delegate를 설정하여 AddWorkView로부터 데이터가 추가됨을 확인받고 테이블 뷰 reload
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let addViewController = segue.destination as? AddWorkViewController else {
            return
        }
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
        addViewController.delegate = self
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
    
    func hideAllSections() {
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
            DatabaseManager.manager.deleteWork(id: tableViewData[selectedIndex!]._id)
            loadSchedule(currentSelectedDate!)
        }))
        present(sheet, animated: true)
    }
    
    @objc func addWeightButtonPressed(sender: UIButton) {
        let alert = UIAlertController(title: "운동 완료", message: "무게 등록", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add", style: .default) { (ok) in
            sender.setTitle((alert.textFields![0].text)! + "Kg", for: .normal)
            let sectionAndRow = numConvert2(input: sender.tag)
            let section = sectionAndRow[0]
            let row = sectionAndRow[1]
//            let addedWeight = Int(alert.textFields![0].text!)!
//            let targetWork = self.tableViewData[sender.tag]
            // DatabaseManager.manager.addNewWeight(WorkID: <#T##ObjectId#>, weight: addedWeight, currentSet: <#T##Int#>, totalSet: <#T##Int#>)
        }
        
        let cancel = UIAlertAction(title: "cancel", style: .cancel) { (cancel) in
            print(sender)
            
        }

        alert.addAction(cancel)
        alert.addAction(add)
        alert.addTextField()
        alert.textFields![0].placeholder = "등록 무게 단위는 Kg"
        self.present(alert, animated: true, completion: nil)
    }
    
    func numConvert1(input: [Int]) -> Int {
        
    }
    
    func numConvert2(input: Int) -> [Int] {
        
    }
}

// MARK: - AddWorkViewControllerDelegate Method
extension MainViewController: AddWorkViewControllerDelegate {
    func addWorkAndReload() {
        loadSchedule(currentSelectedDate!)
    }
}

// MARK: - FSCalendar Methods
extension MainViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currentSelectedDate = dateFormatter.string(from: date)
        if let selectedDateSchedule = DatabaseManager.manager.loadSelectedDateSchedule(date: currentSelectedDate!) {
            tableViewData = selectedDateSchedule.workList.map{ $0 }
            scheduleID = selectedDateSchedule._id
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            hiddenSections = Set(0..<tableViewData.count)
            
        } else {
            tableViewData = []
            scheduleID = nil
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
        
        let sectionButton = UIButton()
        sectionButton.setTitle("\(tableViewData[section].target) - \(tableViewData[section].name)", for: .normal)
        sectionButton.backgroundColor = .systemBlue
        sectionButton.tag = section
        sectionButton.addTarget(self,action: #selector(self.hideSection(sender:)),for: .touchUpInside)
        
        let editButton = UIImageView()
        editButton.image = UIImage(systemName: "pencil")
        editButton.tag = section
        let editTapGesture = UITapGestureRecognizer(target: self, action: #selector(editButtonPressed(_:)))
        editButton.addGestureRecognizer(editTapGesture)
        editButton.isUserInteractionEnabled = true
        
        let removeButton = UIImageView()
        removeButton.image = UIImage(systemName: "trash")
        removeButton.tag = section
        let removeTapGesture = UITapGestureRecognizer(target: self, action: #selector(removeButtonPressed(_:)))
        removeButton.addGestureRecognizer(removeTapGesture)
        removeButton.isUserInteractionEnabled = true
        
        stackView.addArrangedSubview(sectionButton)
        stackView.addArrangedSubview(editButton)
        stackView.addArrangedSubview(removeButton)
        
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
        cell.currentRepsTextField.text = String(tableViewData[indexPath.section].reps) + "Reps"
        let tempLst = [String(indexPath.section).count, indexPath.section, String(indexPath.row).count, indexPath.row]
        cell.addWeightButton.tag = numConvert1(input: tempLst)
        cell.addWeightButton.addTarget(self, action: #selector(addWeightButtonPressed(sender:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            print(indexPath.section, indexPath.row)
            // schedule에서 set수 조정
            DatabaseManager.manager.deleteWorkInSchedule(id: self.tableViewData[indexPath.section]._id)
            // weight에서 해당 무게 존재 시 삭제
            self.loadSchedule(self.currentSelectedDate!)
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

