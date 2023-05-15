//
//  AddRoutineViewController.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/24.
//

import UIKit
import RealmSwift
class AddRoutineViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tableViewData = [Routine]()
    var routineID: ObjectId?
    var scheduleID: ObjectId?
    var date: String? 
    var selectedEditingRoutineIndex: Int?
    weak var delegate: AddWorkViewControllerDelegate? 
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: "RoutineListCell", bundle: nil), forCellReuseIdentifier: "RoutineListCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderTopPadding = 25
        loadRoutineData()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func loadRoutineData() {
        if let loadAllRoutine = DatabaseManager.manager.loadAllRoutine() {
            tableViewData = loadAllRoutine.map{ $0 }
            DispatchQueue.main.async {self.tableView.reloadData()}
            print(tableViewData)
        } else {
            // routine 없을 경우
        }
    }
    
    @objc func loadButtonPressed(_ sender: UIButton) {
        let sheet = UIAlertController(title: "Routine 추가 완료", message: "계속해서 추가하시나요?", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "No", style: .default, handler: { [self] _ in
            if scheduleID == nil {
                scheduleID = DatabaseManager.manager.addNewSchedule(date: self.date!)._id
            }
            DatabaseManager.manager.addRoutineInSchedule(routineID: self.tableViewData[sender.tag]._id, scheduleID: self.scheduleID!)
            delegate?.addWorkAndReload()
            dismiss(animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [self] _ in
            // 추가 동작
            DatabaseManager.manager.addRoutineInSchedule(routineID: self.tableViewData[sender.tag]._id, scheduleID: self.scheduleID!)
            delegate?.addWorkAndReload()
        }))
        
        present(sheet, animated: true)
    }
    
    @objc func editButtonPressed(_ sender: UIButton) {
        selectedEditingRoutineIndex = sender.tag
        performSegue(withIdentifier: "showEditRoutineFromAddRoutine", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editRoutineViewController = segue.destination as? EditRoutineViewController {
            editRoutineViewController.editingRoutine = tableViewData[selectedEditingRoutineIndex!]
        } else {
            return
        }
    }
    
}
extension AddRoutineViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewData[section].routineName + " - " + tableViewData[section].routineDiscription!
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.backgroundColor = .white
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        
        let loadButton = UIButton()
        loadButton.setTitle("불러오기", for: .normal)
        loadButton.backgroundColor = .blue
        loadButton.tag = section
        loadButton.titleLabel?.font =  UIFont.systemFont(ofSize: 20)
        loadButton.addTarget(self, action: #selector(loadButtonPressed(_:)), for: .touchUpInside)
        
        let editButton = UIButton()
        editButton.setTitle("편집 하기 ", for: .normal)
        editButton.backgroundColor = .gray
        editButton.tag = section
        editButton.addTarget(self, action: #selector(editButtonPressed(_:)), for: .touchUpInside)
        
        stackView.addArrangedSubview(loadButton)
        stackView.addArrangedSubview(editButton)
        
        return stackView
        
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: 18)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableViewData[section].workList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineListCell", for: indexPath) as! RoutineListCell
        cell.bodyPart.text = tableViewData[indexPath.section].workList[indexPath.row].target
        cell.name.text = tableViewData[indexPath.section].workList[indexPath.row].name
        cell.set.text = String(tableViewData[indexPath.section].workList[indexPath.row].set)
        cell.rep.text = String(tableViewData[indexPath.section].workList[indexPath.row].reps)
        return cell
    }
    
}
