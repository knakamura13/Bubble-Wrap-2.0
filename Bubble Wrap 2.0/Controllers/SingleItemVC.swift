//
//  SingleItemVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/30/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import Firebase

class SingleItemVC: UIViewController {

 
    @IBOutlet var btnMakeOffer: UIButton!
    @IBOutlet var itemImage: UIImageView!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // setting the button with the background color form constants (Primary Color)
        btnMakeOffer.backgroundColor = Constants.Colors.appPrimaryColor
        btnMakeOffer.setTitleColor(Constants.Colors.TextColors.primaryWhite, for: .normal)
        //Download the item's image and save as a UIImage
        let url = URL(string: selectedItem.imageURL)
        let data = try? Data(contentsOf: url!)
        if let imageData = data {
            let image = UIImage(data: imageData)
            itemImage.image = image
        }
        //  ***LABEL STYLES***
        // Rounded corners are created only top right and bottom right corners
        lblPrice.layer.masksToBounds = true
        lblPrice.layer.cornerRadius = 10.0
        lblPrice.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        // Background and text color
        lblPrice.backgroundColor = Constants.Colors.TextColors.primaryWhite.withAlphaComponent(0.4)
        lblPrice.textColor = Constants.Colors.TextColors.primaryWhite
        
        //  ***PRICE LABEL***
        let price = selectedItem.price

        // why do i have to do price ?? 0
        lblPrice.text = "$\(price ?? 0)"
        
        // Title
        lblTitle.text = selectedItem.title
       
        
        //Description
        
    }
}
