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
    
    override func viewDidLoad() {
        
        tableView.dataSource = self
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
        addViewController.routineID = routineID!
        addViewController.delegateForNewRoutine = self
    }
    
    @IBAction func addNewWorkButtonPressed(_ sender: UIButton) {
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
        tableViewData.append(newWork)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}


extension EditRoutineViewController: UITableViewDataSource {
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
    
    
}

