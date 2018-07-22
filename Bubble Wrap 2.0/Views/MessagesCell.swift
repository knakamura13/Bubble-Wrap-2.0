//
//  MessagesCell.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 7/10/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit

class MessagesCell: UITableViewCell {

    @IBOutlet weak var cellNameLbl: UILabel!
    @IBOutlet weak var cellMessageContentsLbl: UILabel!
    @IBOutlet weak var cellMessageTimeLbl: UILabel!
    @IBOutlet weak var cellImageViewContainer: UIView!
    @IBOutlet weak var cellImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
