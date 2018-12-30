//
//  OffersMadeCell.swift
//  Bubble Wrap 2.0
//
//  Created by Mario Lopez on 12/24/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit

class OffersMadeCell: UITableViewCell {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var offerPriceLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
