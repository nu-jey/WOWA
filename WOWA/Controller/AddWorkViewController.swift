//
//  AddWorkViewController.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/07.
//

import UIKit

class AddWorkViewController: UIViewController {
    
    @IBOutlet weak var bodyPart: UILabel!
    @IBOutlet weak var selectBodyPart: UIPickerView!
    @IBOutlet weak var selectSetAndRep: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension AddWorkViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return wowa.bodyPart.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return wowa.bodyPart[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        bodyPart.text = wowa.bodyPart[row]
    }
}
