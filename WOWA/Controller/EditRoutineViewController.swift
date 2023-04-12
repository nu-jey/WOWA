//
//  EditRoutineViewController.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/12.
//

import UIKit

class EditRoutineViewController: UIViewController {

    @IBOutlet weak var routineNameTextField: UITextField!
    
    @IBOutlet weak var routineDescriptionTextField: UITextField!
    var editingRoutine: Routine?
    override func viewDidLoad() {
        routineNameTextField.text = editingRoutine?.routineName
        routineDescriptionTextField.text = editingRoutine?.routineDiscription
        super.viewDidLoad()
        print(editingRoutine)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
