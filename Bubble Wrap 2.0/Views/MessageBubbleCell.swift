//
//  MessageBubbleCell.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 9/3/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit

class MessageBubbleCell: UITableViewCell {
    
    @IBOutlet weak var messageBubble: UIImageView!
    @IBOutlet weak var messageLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
