//
//  RoutineViewController.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/04.
//
import UIKit
import KakaoSDKShare
protocol NewAndEditRoutineViewControllerDelegate: AnyObject {
    func addRoutineAndReload()
}


class RoutineViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var tableViewData = [Routine]()
    var selectedIndex: Int?
    var hiddenSections = Set<Int>()
    var isHidden = false
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: "RoutineListCell", bundle: nil), forCellReuseIdentifier: "RoutineListCell")
        loadAllRoutines()
        
        if !isHidden {
            for i in 0..<tableViewData.count {
                if tableView.numberOfRows(inSection: i) != 0 {
                    var indexPaths = [IndexPath]()
                    for row in 0..<self.tableViewData[i].workList.count {
                        indexPaths.append(IndexPath(row: row, section: i))
                    }
                    self.hiddenSections.insert(i)
                    self.tableView.deleteRows(at: indexPaths, with: .none)
                }
            }
            isHidden = true
        }
        
        super.viewDidLoad()
    }
    
    func loadAllRoutines() {
        if let loadAllRoutine = DatabaseManager.manager.loadAllRoutine() {
            tableViewData = loadAllRoutine.map{ $0 }
            DispatchQueue.main.async {self.tableView.reloadData()}
        } else {
            print("오늘 날짜의 운동 없음 ")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNewRoutineView" {
            guard let newRoutineViewController = segue.destination as? NewRoutineViewController else {return}
            newRoutineViewController.delegate = self
            
        } else if segue.identifier == "showEditRoutineView" {
            guard let editRoutineViewController = segue.destination as? EditRoutineViewController else {return}
            editRoutineViewController.editingRoutine = tableViewData[selectedIndex!]
        }
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
        
        if self.hiddenSections.contains(section) && (tableViewData[section].workList.count > 0){
            isHidden = false
            self.hiddenSections.remove(section)
            self.tableView.insertRows(at: indexPathsForSection(), with: .fade)
            self.tableView.scrollToRow(at: IndexPath(row: self.tableViewData[section].workList.count - 1,section: section), at: UITableView.ScrollPosition.bottom, animated: true)
        } else {
            isHidden = true
            self.hiddenSections.insert(section)
            self.tableView.deleteRows(at: indexPathsForSection(), with: .fade)
        }
    }
    
    @objc private func goToEditRoutine(sender: UIButton) {
        selectedIndex = sender.tag
        performSegue(withIdentifier: "showEditRoutineView", sender: nil)
    }
    
    @objc func shareButtonPressed(_ gesture: UITapGestureRecognizer) {
        selectedIndex = (gesture.view?.tag)!
        let routine = tableViewData[selectedIndex!]
        let str = """
                    \(routine.workList)
                    """
        if ShareApi.isKakaoTalkSharingAvailable()  {
            ShareApi.shared.shareCustom(templateId: 94186, templateArgs:["routineName":routine.routineName, "routineDescription":routine.routineDiscription ?? "", "workList": str]) {(sharingResult, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("shareCustom() success.")
                    if let sharingResult = sharingResult {
                        UIApplication.shared.open(sharingResult.url, options: [:], completionHandler: nil)
                        print(sharingResult.url)
                    }
                }
            }
            
            
        } else {
            print("카카오톡 미설치")
        }
        
        
    }
    
    @objc func editButtonPressed(_ gesture: UITapGestureRecognizer) {
        selectedIndex = (gesture.view?.tag)!
        performSegue(withIdentifier: "showEditRoutineView", sender: nil)
    }
    
    @objc func removeButtonPressed(_ gesture: UITapGestureRecognizer) {
        selectedIndex = (gesture.view?.tag)!
        let sheet = UIAlertController(title: "Routine 삭제", message: "해당 Routine을 삭제하시나요?", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in }))
        sheet.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [self] _ in
            DatabaseManager.manager.deleteRoutine(id: tableViewData[selectedIndex!]._id)
            loadAllRoutines()
        }))
        present(sheet, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadAllRoutines()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        print("hi")
        performSegue(withIdentifier: "showNewRoutineView", sender: nil)
    }
    
}

extension RoutineViewController: UITableViewDataSource ,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.backgroundColor = .white
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.backgroundColor = UIColor(named: "sideColor4")
        stackView.layer.cornerRadius = 5
        
        let sectionButton = UIButton()
        sectionButton.setTitle("\(tableViewData[section].routineName) - \(tableViewData[section].routineDiscription!)", for: .normal)
        sectionButton.tag = section
        sectionButton.contentHorizontalAlignment = .left // 버튼 텍스트 왼쪽 정렬
        sectionButton.addTarget(self,action: #selector(self.hideSection(sender:)),for: .touchUpInside)
        
        
        let shareButton = UIImageView()
        shareButton.image = UIImage(systemName: "arrow.up.message.fill")
        shareButton.tag = section
        shareButton.tintColor = UIColor(named: "signatureColor")
        let shareTapGesture = UITapGestureRecognizer(target: self, action: #selector(shareButtonPressed(_:)))
        shareButton.addGestureRecognizer(shareTapGesture)
        shareButton.isUserInteractionEnabled = true
        
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
        stackView.addArrangedSubview(shareButton)
        stackView.addArrangedSubview(editButton)
        stackView.addArrangedSubview(removeButton)
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        return stackView
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
        cell.setAndRep.text = String(tableViewData[indexPath.section].workList[indexPath.row].set) + " / " + String(tableViewData[indexPath.section].workList[indexPath.row].reps)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath.row
    }
    
}

extension RoutineViewController: NewAndEditRoutineViewControllerDelegate {
    func addRoutineAndReload() {
        loadAllRoutines()
    }
}
