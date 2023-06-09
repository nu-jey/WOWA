//
//  AddWorkViewController.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/07.
//

import UIKit
import RealmSwift
class AddWorkViewController: UIViewController {
    @IBOutlet weak var selectBodyPart: UIPickerView!
    @IBOutlet weak var repTextField: UITextField!
    @IBOutlet weak var setTextField: UITextField!
    @IBOutlet weak var stepperSet: UIStepper!
    @IBOutlet weak var stepperRep: UIStepper!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    weak var delegate: AddWorkViewControllerDelegate?
    weak var delegateForNewRoutine: ForNewRoutineAddWorkViewControllerDelegate?
    
    var target = "가슴"
    var newWork = Work()
    var workID: ObjectId?
    var routineID: ObjectId?
    var scheduleID: ObjectId?
    var selectedDate: String?
    var isNewRoutine = false
    var editingWorkIndex = -1
    var editingWorkTargetIndex = -1
    var editingWorkTargetRep = -1
    var editingWorkTargetSet = -1
    var editingWorkTargetName = ""
    var settingInfo: SettingInfo?
    
    @IBAction func stepperSetPressed(_ sender: UIStepper) {
        setTextField.text = Int(sender.value).description
    }
    
    @IBAction func stepperRepPressed(_ sender: UIStepper) {
        repTextField.text = Int(sender.value).description
    }
    
    @IBAction func addWork(_ sender: UIButton) {
        newWork.target = target
        newWork.name = nameTextField.text!
        newWork.set = Int(stepperSet.value)
        newWork.reps = Int(stepperRep.value)
        
        if editingWorkIndex >= 0 {
            if scheduleID != nil {
                DatabaseManager.manager.editWork(work: newWork, id: workID!)
                delegate?.addWorkAndReload()
            } else {
                delegateForNewRoutine?.addWorkForNewRoutineAndReload(newWork)
            }
        } else {
            if scheduleID != nil {
                DatabaseManager.manager.addWorkInSchedule(newWork: newWork, id: scheduleID!)
                DatabaseManager.manager.addNewWeight(WorkID: newWork._id, weight: -1, currentSet: newWork.set, totalSet: newWork.set, reps: newWork.reps, date: selectedDate!)
                delegate?.addWorkAndReload()
            } else if routineID != nil {
                delegateForNewRoutine?.addWorkForNewRoutineAndReload(newWork)
            } else if isNewRoutine {
                delegateForNewRoutine?.addWorkForNewRoutineAndReload(newWork)
            }
        }
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        setAddWorkViewText()
        settingInfo = DatabaseManager.manager.loadSettingInfo()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setAddWorkViewText()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let editRoutineViewController = segue.destination as? EditRoutineViewController else {
            return
        }
        if editingWorkIndex >= 0 {
            editRoutineViewController.tableViewData[editingWorkIndex] = newWork
        } else {
            
        }
    }
    func setAddWorkViewText() {
        if editingWorkIndex >= 0 {
            selectBodyPart.selectRow(editingWorkTargetIndex, inComponent: 0, animated: true)
            target = wowa.bodyPart[editingWorkTargetIndex]
            repTextField.text = String(editingWorkTargetRep)
            setTextField.text = String(editingWorkTargetSet)
            stepperSet.value = Double(editingWorkTargetSet)
            stepperRep.value = Double(editingWorkTargetRep)
            nameTextField.text = editingWorkTargetName
            addButton.setTitle("편집 후 저장하기", for: .normal)
        } else {
            stepperSet.value = 3
            stepperRep.value = 9
        }
    }
}

// MARK: - PickerView Methods
extension AddWorkViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return settingInfo!.bodyPart.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return settingInfo!.bodyPart[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        target = settingInfo!.bodyPart[row]
    }
}
