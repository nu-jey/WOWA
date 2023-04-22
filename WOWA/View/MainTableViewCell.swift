//
//  MainTableViewCell.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/21.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var currentSetTextField: UILabel!
    @IBOutlet weak var currentRepsTextField: UILabel!
    @IBOutlet weak var addWeightButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
