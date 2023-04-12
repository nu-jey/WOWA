//
//  MyRoutineListCell.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/12.
//

import UIKit

class MyRoutineListCell: UITableViewCell {

    @IBOutlet weak var routineName: UILabel!
    @IBOutlet weak var routineDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
