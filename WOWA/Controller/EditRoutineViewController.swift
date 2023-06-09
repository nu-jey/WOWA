//
//  EditRoutineViewController.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/12.
//

import UIKit
import RealmSwift

class EditRoutineViewController: UIViewController {
    
    @IBOutlet weak var routineNameTextField: UITextField!
    @IBOutlet weak var routineDescriptionTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var editingRoutine: Routine?
    var tableViewData = [Work]()
    var routineID: ObjectId?
    var delegate: NewAndEditRoutineViewControllerDelegate?
    var currentWorkIsEditing = -1
    
    override func viewDidLoad() {
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "RoutineListCell", bundle: nil), forCellReuseIdentifier: "RoutineListCell")
        routineNameTextField.text = editingRoutine?.routineName
        routineDescriptionTextField.text = editingRoutine?.routineDiscription
        tableViewData = (editingRoutine?.workList)!.map { $0 }
        routineID = editingRoutine?._id
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let addViewController = segue.destination as? AddWorkViewController else {
            return
        }
        if currentWorkIsEditing >= 0 {
            addViewController.editingWorkIndex = currentWorkIsEditing
            addViewController.workID = tableViewData[currentWorkIsEditing]._id
            addViewController.editingWorkTargetIndex = wowa.bodyPart.firstIndex(of: tableViewData[currentWorkIsEditing].target)!
            addViewController.editingWorkTargetRep = tableViewData[currentWorkIsEditing].reps
            addViewController.editingWorkTargetSet = tableViewData[currentWorkIsEditing].set
            addViewController.editingWorkTargetName = tableViewData[currentWorkIsEditing].name
        }
        
        addViewController.routineID = routineID!
        addViewController.delegateForNewRoutine = self
    }
    
    @IBAction func addNewWorkButtonPressed(_ sender: UIButton) {
        currentWorkIsEditing = -1
        performSegue(withIdentifier: "showNewWorkFromEditRoutine", sender: nil)
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        let tempRoutine = Routine(routineName: routineNameTextField.text!, routineDiscription: routineDescriptionTextField.text!)
        let tempList = List<Work>()
        tempList.append(objectsIn: tableViewData)
        tempRoutine.workList = tempList
        DatabaseManager.manager.editRoutine(routine: tempRoutine, id: routineID!)
        delegate?.addRoutineAndReload()
        _ = navigationController?.popViewController(animated: true)
    }
}

extension EditRoutineViewController: ForNewRoutineAddWorkViewControllerDelegate {
    func addWorkForNewRoutineAndReload(_ newWork: Work) {
        if currentWorkIsEditing >= 0 {
            tableViewData[currentWorkIsEditing] = newWork
        } else {
            tableViewData.append(newWork)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}


extension EditRoutineViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineListCell", for: indexPath) as! RoutineListCell
        cell.bodyPart.text = tableViewData[indexPath.row].target
        cell.name.text = tableViewData[indexPath.row].name
        cell.setAndRep.text = String(tableViewData[indexPath.row].set) + " / " + String(tableViewData[indexPath.row].reps)
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.tableViewData.remove(at: indexPath.row)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            success(true)
        }
        delete.backgroundColor = .systemRed
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.currentWorkIsEditing = indexPath.row
            self.performSegue(withIdentifier: "showNewWorkFromEditRoutine", sender: nil)
            
        }
        edit.backgroundColor = .systemTeal
        
        return UISwipeActionsConfiguration(actions:[delete, edit])
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
}

