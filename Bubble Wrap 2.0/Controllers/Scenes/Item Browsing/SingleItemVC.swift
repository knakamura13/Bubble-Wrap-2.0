//
//  SingleItemVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/30/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit

class SingleItemVC: UIViewController {
    
    // Outlets
    @IBOutlet var btnMakeOffer: UIButton!
    @IBOutlet var itemImage: UIImageView!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblTitle: UILabel!
    
    // Loads once when the screen is rendered for the first time
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupStyles()
        self.setInitialData()
    }
    
    // Stylize all views for initial page load
    func setupStyles() {
        // NavBar title color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:Constants.Colors.TextColors.primaryWhite, NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 21)!]
        // Make Offer Button
        btnMakeOffer.backgroundColor = Constants.Colors.appPrimaryColor
        btnMakeOffer.setTitleColor(Constants.Colors.TextColors.primaryWhite, for: UIControl.State.normal)
        
        // Price Label
        lblPrice.layer.masksToBounds = true
        lblPrice.layer.cornerRadius = 10.0
        lblPrice.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner] // Rounded corners on top-right and bottom-right
        lblPrice.backgroundColor = Constants.Colors.TextColors.primaryWhite.withAlphaComponent(0.4)
        lblPrice.textColor = Constants.Colors.TextColors.primaryWhite
    }
    
    // Set all data for initial page load
    func setInitialData() {
        // Set the price label
        let price = selectedItem.price
        if price == 0 {
            lblPrice.text = "FREE"
        } else {
            lblPrice.text = "$\(price ?? 0)"
        }
        
        // TODO: Item information div below the UIImage should scroll over the image and the price
        
        // Set the item title and description
        lblTitle.text = selectedItem.title
        // TODO: Description label
        
        //Download the item's image and save as UIImage
        guard let url = URL(string: selectedItem.imageURL!) else {
            print("Item does not have an imageURL")
            return
        }
        if let data = try? Data(contentsOf: url) {
            let imageData = data
            let image = UIImage(data: imageData)
            itemImage.image = image
        }
    }
}
