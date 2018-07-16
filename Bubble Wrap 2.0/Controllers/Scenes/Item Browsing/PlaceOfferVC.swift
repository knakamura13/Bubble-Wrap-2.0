//
//  PlaceOfferVC.swift
//  Bubble Wrap 2.0
//
//  Created by Mario Lopez on 7/8/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import Firebase


class PlaceOfferVC: UIViewController {
    // Constants
     private let collection = Firestore.firestore().collection("offers")
    
    // Variables
    var placeOfferWasPressed: Bool!
    
    // Outlets
    @IBOutlet var txtfldUserOffer: UITextField!
    @IBOutlet var lblDirections: UILabel!
    @IBOutlet var btnPlaceOffer: UIButton!
    @IBOutlet var itemImageBackground: UIImageView!
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIntialData()
        setupStyles()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        placeOfferWasPressed = false
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
    @IBAction func placeOfferPressed(_ sender: Any) {
        // Ensure an offer is placed in text field
        if let userID = Auth.auth().currentUser?.uid{
            if !placeOfferWasPressed{
                    let price = Int(txtfldUserOffer.text!)
                    let creator = Firestore.firestore().collection("users").document(userID)
                    let itemID = selectedItem.itemID
                    let recipient = selectedItem.owner
                    self.createOffer(price: price!, creator: creator, item: Firestore.firestore().collection("items").document(itemID!), recipient: recipient!)
                    placeOfferWasPressed = true
            } else{
                placeOfferWasPressed = false
            }
            
        }
    }
    func setupStyles() {
        // Add blur effect to background picture
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = itemImageBackground.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        itemImageBackground.addSubview(blurEffectView)
        self.view.sendSubviewToBack(itemImageBackground)
        self.view.sendSubviewToBack(blurEffectView)
        
        //Place Offer Button
        btnPlaceOffer.backgroundColor = Constants.Colors.appPrimaryColor
        btnPlaceOffer.setTitleColor(Constants.Colors.TextColors.primaryWhite, for: UIControl.State.normal)
        btnPlaceOffer.layer.masksToBounds = true
        btnPlaceOffer.layer.cornerRadius = 10.0
        
        // Directions label with Item name
        lblDirections.text = "Enter your offer for \n\(selectedItem.title ?? "your desired item")"
        lblDirections.textColor = Constants.Colors.TextColors.primaryWhite
        
        //Keyboard Functions
        self.hideKeyboardWhenTappedAround()
        
    }
    // Create Offer object and send its data to firebase
    func createOffer(price: Int, creator:DocumentReference, item: DocumentReference, recipient: DocumentReference){
        let offer = Offer(price: price, item: item, creator: creator, recipient: recipient)
        self.collection.addDocument(data: offer.dictionary()){ err in
            if err != nil{
                let alert = UIAlertController(title: "Error", message: "You missed something", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "Offer Sent!", message: "If the owner is interested they will message you!", preferredStyle: .alert)
                // Create Variables in order to send the use back to the Tab Bar Controller after offer is made
                let segueBackToTabBarConroller = UIAlertAction(title: "Okay", style: .default) { (action) -> Void in
                    let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController")
                    self.present(tabBarVC!, animated: true, completion: nil)
                }
                alert.addAction(segueBackToTabBarConroller)
                self.present(alert, animated: true)
            }

        }
    }
}

