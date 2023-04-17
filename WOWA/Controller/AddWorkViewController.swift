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
    var today = ""
    let dateFormatter = DateFormatter()
    var newWork = Work()
    var workID: ObjectId?
    var routineID: ObjectId?
    var scheduleID: ObjectId?
    var isNewRoutine = false
    var editingWorkTargetIndex = -1
    var editingWorkTargetRep = -1
    var editingWorkTargetSet = -1
    var editingWorkTargetName = ""
    
    override func viewDidLoad() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        today = dateFormatter.string(from: Date())
        
        if editingWorkTargetIndex >= 0 {
            selectBodyPart.selectRow(editingWorkTargetIndex, inComponent: 0, animated: true)
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
        super.viewDidLoad()
    }
    
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
        
        if editingWorkTargetIndex > 0 {
            if scheduleID != nil {
                DatabaseManager.manager.editWork(work: newWork, id: workID!)
                delegate?.addWorkAndReload()
            }
        } else {
            if scheduleID != nil {
                DatabaseManager.manager.addWorkInSchedule(newWork: newWork, id: scheduleID!)
                delegate?.addWorkAndReload()
            } else if routineID != nil {
                delegateForNewRoutine?.addWorkForNewRoutineAndReload(newWork)
            } else if isNewRoutine {
                delegateForNewRoutine?.addWorkForNewRoutineAndReload(newWork)
            }
        }
        self.dismiss(animated: true)
    }
    
}

// MARK: - PickerView Methods
extension AddWorkViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return wowa.bodyPart.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return wowa.bodyPart[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        target = wowa.bodyPart[row]
    }
}
