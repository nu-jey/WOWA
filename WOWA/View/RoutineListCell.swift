//
//  RoutineListCellTableViewCell.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/07.
//

import UIKit

class RoutineListCell: UITableViewCell {

    @IBOutlet weak var bodyPart: UILabel!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var setAndRep: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
