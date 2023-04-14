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
    
    weak var delegate: AddWorkViewControllerDelegate?
    
    var target = "가슴"
    var today = ""
    let dateFormatter = DateFormatter()
    var newWork = Work()
    var routineID: ObjectId?
    var scheduleID: ObjectId?
    
    
    override func viewDidLoad() {
        stepperSet.value = 3
        stepperRep.value = 9
        dateFormatter.dateFormat = "yyyy-MM-dd"
        today = dateFormatter.string(from: Date())
        print(routineID)
        super.viewDidLoad()
    }
    
    @IBAction func stepperSetPressed(_ sender: UIStepper) {
        setTextField.text = Int(sender.value).description
    }
    
    @IBAction func stepperRepPressed(_ sender: UIStepper) {
        repTextField.text = Int(sender.value).description
    }
    
    @IBAction func addWork(_ sender: UIButton) {
        if (scheduleID != nil) {
            newWork.target = target
            newWork.name = nameTextField.text!
            newWork.set = Int(stepperSet.value)
            newWork.reps = Int(stepperRep.value)
            DatabaseManager.manager.addWorkInSchedule(newWork: newWork, id: scheduleID!)
            delegate?.addWorkAndReload()
            self.dismiss(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MainViewController {
            let vc = segue.destination as? MainViewController
            vc?.tableViewData.append(newWork)
        } else if segue.destination is EditRoutineViewController {
            
        } else if segue.destination is NewRoutineViewController {
            
        }
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
