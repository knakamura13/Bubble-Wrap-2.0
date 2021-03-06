//
//  ReviewsCell.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 6/20/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit

private let highlightedColor = Constants.Colors.appPrimaryColor.withAlphaComponent(0.1)

class ReviewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var bodyLbl: UILabel!
    
    override var isSelected: Bool {
        willSet {
            onSelected(newValue)
        }
    }
    
    func onSelected(_ newValue: Bool) {
        guard selectedBackgroundView == nil else { return }
        contentView.backgroundColor = newValue ? highlightedColor : UIColor.clear
    }
    

}
