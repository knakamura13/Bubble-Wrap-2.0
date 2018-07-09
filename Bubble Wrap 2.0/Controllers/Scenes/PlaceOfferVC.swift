//
//  PlaceOfferVC.swift
//  Bubble Wrap 2.0
//
//  Created by Mario Lopez on 7/8/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit

class PlaceOfferVC: UIViewController {
    // Outlets
//    @IBOutlet var itemImageBackground: UIImageView!
//    @IBOutlet var txtfldUserOffer: UITextField!
//    @IBOutlet var lblDirections: UILabel!
//    @IBOutlet var btnPlaceOffer: UIButton!
    @IBOutlet var itemImageBackground: UIImageView!
    @IBOutlet var btnPlaceOffer: UIButton!
    @IBOutlet var lblDirections: UILabel!
    @IBOutlet var txtfldUserOffer: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIntialData()
        setupStyles()
        // Do any additional setup after loading the view.
    }
    
    func setIntialData(){
        //Download the item's image and save as UIImage
        guard let url = URL(string: selectedItem.imageURL!) else {
            print("Item does not have an imageURL")
            return
        }
        if let data = try? Data(contentsOf: url) {
            let imageData = data
            let image = UIImage(data: imageData)
            itemImageBackground.image = image
        }
    }
    
    func setupStyles() {
        // Add blur effect to background picture
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = itemImageBackground.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        itemImageBackground.addSubview(blurEffectView)
        
        //Place Offer Button
        btnPlaceOffer.backgroundColor = Constants.Colors.appPrimaryColor
        btnPlaceOffer.setTitleColor(Constants.Colors.TextColors.primaryWhite, for: UIControl.State.normal)
        btnPlaceOffer.layer.masksToBounds = true
        btnPlaceOffer.layer.cornerRadius = 10.0
        
        // Directions label with Item name
        lblDirections.text = "Enter your offer for \(selectedItem.title ?? "your desired item")"
        lblDirections.textColor = Constants.Colors.TextColors.primaryWhite
        
        
        //
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

