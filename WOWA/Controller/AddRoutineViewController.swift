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
        tableView.register(UINib(nibName: "RoutineTableHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "RoutineTableHeader")
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
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        //return tableViewData[section].routineName + " - " + tableViewData[section].routineDiscription!
    //    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "RoutineTableHeader") as! RoutineTableHeader
        if let description = tableViewData[section].routineDiscription {
            header.routineLable.text = tableViewData[section].routineName + " - " + description
        } else {
            header.routineLable.text = tableViewData[section].routineName
        }
        header.routineLable.sizeThatFits( CGSize(width: header.routineLable.frame.width, height: 1000))
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.backgroundColor = UIColor(named: "sideColor4")
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.frame = CGRect(x: 0, y: 0, width: 1000, height: 1000)
        
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        
        let loadButton = UIButton()
        let dumbbellImage = UIImage(systemName: "dumbbell", withConfiguration: imageConfig)
        loadButton.setImage(dumbbellImage, for: .normal)
        loadButton.tintColor = UIColor(named: "signatureColor")
        loadButton.tag = section
        loadButton.addTarget(self, action: #selector(loadButtonPressed(_:)), for: .touchUpInside)
    
        
        let editButton = UIButton()
        let pencilImage = UIImage(systemName: "pencil", withConfiguration: imageConfig)
        editButton.setImage(pencilImage, for: .normal)
        editButton.tintColor = UIColor(named: "signatureColor")
        editButton.tag = section
        editButton.addTarget(self, action: #selector(editButtonPressed(_:)), for: .touchUpInside)
        
        stackView.addArrangedSubview(loadButton)
        stackView.addArrangedSubview(editButton)
        
        return stackView
        
    }
    //
    //    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    //    {
    //        let header = view as! UITableViewHeaderFooterView
    //        header.textLabel?.font = UIFont.systemFont(ofSize: 18)
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableViewData[section].workList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineListCell", for: indexPath) as! RoutineListCell
        cell.bodyPart.text = tableViewData[indexPath.section].workList[indexPath.row].target
        cell.name.text = tableViewData[indexPath.section].workList[indexPath.row].name
        cell.setAndRep.text = String(tableViewData[indexPath.section].workList[indexPath.row].set) + " / " + String(tableViewData[indexPath.section].workList[indexPath.row].reps)
    
        return cell
    }
    
}
