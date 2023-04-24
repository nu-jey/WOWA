//
//  AddRoutineViewController.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/24.
//

import UIKit

class AddRoutineViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tableViewData = [Routine]()
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: "RoutineListCell", bundle: nil), forCellReuseIdentifier: "RoutineListCell")
        tableView.delegate = self
        tableView.dataSource = self
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
    
}
extension AddRoutineViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
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
