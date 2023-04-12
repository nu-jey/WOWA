//
//  RoutineViewController.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/04.
//
import UIKit

class RoutineViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var tableViewData = [Routine]()
    var selectedIndex: Int?
    var hiddenSections = Set<Int>()
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: "RoutineListCell", bundle: nil), forCellReuseIdentifier: "RoutineListCell")
        
        if let loadAllRoutine = DatabaseManager.manager.loadAllRoutine() {
            tableViewData = loadAllRoutine.map{ $0 }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            print("오늘 날짜의 운동 없음 ")
        }
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let editRoutineViewController = segue.destination as? EditRoutineViewController else {return}
        editRoutineViewController.editingRoutine = tableViewData[selectedIndex!]
    }
    
    @objc private func hideSection(sender: UIButton) {
        let section = sender.tag
        func indexPathsForSection() -> [IndexPath] {
            var indexPaths = [IndexPath]()
            for row in 0..<self.tableViewData[section].workList.count {
                indexPaths.append(IndexPath(row: row, section: section))
            }
            
            return indexPaths
        }
        
        if self.hiddenSections.contains(section) {
            self.hiddenSections.remove(section)
            self.tableView.insertRows(at: indexPathsForSection(), with: .fade)
            self.tableView.scrollToRow(at: IndexPath(row: self.tableViewData[section].workList.count - 1,section: section), at: UITableView.ScrollPosition.bottom, animated: true)
        } else {
            self.hiddenSections.insert(section)
            self.tableView.deleteRows(at: indexPathsForSection(), with: .fade)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        for i in 0..<tableViewData.count {
            var indexPaths = [IndexPath]()
            for row in 0..<self.tableViewData[i].workList.count {
                indexPaths.append(IndexPath(row: row, section: i))
            }
            self.hiddenSections.insert(i)
            self.tableView.deleteRows(at: indexPaths, with: .none)
        }
    }
}

extension RoutineViewController: UITableViewDataSource ,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionButton = UIButton()
        sectionButton.setTitle(tableViewData[section].routineName, for: .normal)
        sectionButton.backgroundColor = .systemBlue
        sectionButton.tag = section
        sectionButton.addTarget(self,action: #selector(self.hideSection(sender:)),for: .touchUpInside)
        return sectionButton
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.hiddenSections.contains(section) {
            return 0
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "showEditRoutineView", sender: nil)
    }
    
}
