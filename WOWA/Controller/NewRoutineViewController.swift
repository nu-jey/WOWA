//
//  NewRoutineViewController.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/12.
//
import UIKit
import RealmSwift

protocol ForNewRoutineAddWorkViewControllerDelegate: AnyObject {
    func addWorkForNewRoutineAndReload(_ newWork: Work)
}

class NewRoutineViewController: UIViewController {
    
    @IBOutlet weak var routineNameTextField: UITextField!
    @IBOutlet weak var routineDescriptionTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var tableViewData = [Work]()
    var routineID: ObjectId?
    var delegate: NewAndEditRoutineViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RoutineListCell", bundle: nil), forCellReuseIdentifier: "RoutineListCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let addViewController = segue.destination as? AddWorkViewController else {
            return
        }
        addViewController.isNewRoutine = true
        addViewController.delegateForNewRoutine = self
    }
    
    
    @IBAction func addWorkButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showNewWorkFromNewRoutine", sender: nil)
    }
    
    
    @IBAction func addSaveButton(_ sender: Any) {
        let newRoutine = Routine(routineName: routineNameTextField.text!)
        if let description = routineNameTextField.text {
            newRoutine.routineDiscription = description
        }
        for work in tableViewData {
            newRoutine.workList.append(work)
        }
        DatabaseManager.manager.addNewRoutine(newRoutine)
        delegate?.addRoutineAndReload()
        _ = navigationController?.popViewController(animated: true)
    }
    
}

extension NewRoutineViewController: ForNewRoutineAddWorkViewControllerDelegate {
    func addWorkForNewRoutineAndReload(_ newWork: Work) {
        tableViewData.append(newWork)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}


extension NewRoutineViewController: UITableViewDataSource {
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
