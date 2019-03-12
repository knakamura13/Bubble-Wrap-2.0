//
//  OffersMadeVC.swift
//  Bubble Wrap 2.0
//
//  Created by Mario Lopez on 12/24/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import MessageUI

class OffersMadeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    // Outlets
    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var offersMadeTbl: UITableView!
    
    // Variables
    var offersArray: [Offer] = []
    private var emailOfOfferCreator = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.arrayOfOffersMade()
            self.offersMadeTbl.dataSource = self
            self.offersMadeTbl.delegate = self
            self.offersMadeTbl.tableFooterView = UIView()
        }
        setStyles()
    }
    
    
    func arrayOfOffersMade(){
        // itemSelected is the DocumentRefernce for the currentItem selected by the user to check offers
        let itemSelected: DocumentReference = Firestore.firestore().collection("items").document(currentItem.itemID)
        
        // Query the database for the all the offers made for the itemSelected
        Firestore.firestore()
            .collection("offers")
            .whereField("item", isEqualTo: itemSelected)
            .order(by: "price")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("CHECKING CODE (OffersMadeVC), arrayOfOffersMade() - Error retreiving collection: \(error)") // Displays error if the listener fails
                }
                if let documents = querySnapshot?.documents {
                    for document in documents {
                        if let offer = Offer(dictionary: document.data(), itemID: document.documentID) {
                            // Append the offer to the array offersArray
                            self.offersArray.append(offer)
                            // Reload the data to the table to display the offers' information in the table
                            self.offersMadeTbl.reloadData()
                        }
                    }
                    // Check whether there are any offers for this item
                    if self.offersArray.count == 0 {
                        let noOffersAlert = UIAlertController(title: "Sorry!", message: "There have been no offers on you item yet.", preferredStyle: .alert)
                        noOffersAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(noOffersAlert, animated: true)
                    }
                }
            }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Set the amount of cells for the table depending on the number of offers in `offersArray`
        return offersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create cell so if the user where to scroll past cells no longer showing, instead of creating a whole new cell (which uses up memory) this reuses the cell no longer seen
        let cell = offersMadeTbl.dequeueReusableCell(withIdentifier: "OfferMadeCell") as? OffersMadeCell
        
        // Make a query to the database to get the name, email, and price of the person making the offer
        Firestore.firestore().collection("users").document(offersArray[indexPath.row].creator.documentID).getDocument { (document, error) in
            if let error = error {
                print("CHECKING CODE (OffersMadeVC), cellForRowAt() - Error retreiving collection: \(error)") // Displays error if the listener fails
            }
            let dictionary = document?.data()
            let user = User(dictionary: dictionary, itemID: (document?.documentID)!)
            self.emailOfOfferCreator = (user?.email)!
            cell?.nameLbl.text = (user?.firstName)! + " " + (user?.lastName)!
            cell?.offerPriceLbl.text = "$\((self.offersArray[indexPath.row].price)!)"
        }
        
        return cell!
    }
    
    /*
     * Sending email section.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mailComposeViewController = configuredMailController(email: emailOfOfferCreator)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showMailError()
        }
    }
    
    // View for messaging
    func configuredMailController(email: String) -> MFMailComposeViewController{
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([email])
        mailComposerVC.setSubject("BubbleWrap: Counteroffer!")
        // Can add html in the message body below you just have to make sure that `isHTML` is set to true
        mailComposerVC.setMessageBody("I would <b>love</b> to counteroffer you for a price for <ENTER PRICE HERE>", isHTML: true)
        
        return mailComposerVC
    }
    
    func showMailError(){
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email.", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Okay", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
    // Sets the title of the item
    func setStyles(){
        /// NavBar title color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:Constants.Colors.TextColors.primaryWhite, NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 21)!]
        
        itemNameLbl.text = "Offers for \(currentItem.title!)"
        let doneItem = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(deleteButtonTapped));
        self.navigationItem.rightBarButtonItem = doneItem

    }
    
    @objc func deleteButtonTapped() {
        let deleteAlert = UIAlertController(title: "Delete Item?", message: "Did you sell it", preferredStyle: .alert)
        
        // Handles when "Cancel" Button is pressed
        let actionCancel_Delete = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
         /**** SOLD IT BUTTON ****/
        let actionSoldIt = UIAlertAction(title: "Sold it!", style: UIAlertAction.Style.default, handler: {
            _ in
            // Alert to double check if Item is Sold
            let verify_SoldItAlert = UIAlertController(title: "Are you sure?", message: "Just want to make sure you meant to press 'Sold it!', this will delete the item and mark it as 'Sold' on your profile", preferredStyle: .alert)
            
            // Verify that they meant to 'Sold it' if so do the following
            let actionYes = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {
                _ in
                // itemSelected is the item the user want to edit
                let itemSelected = Firestore.firestore().collection("items").document(currentItem.itemID)
                let refItemSelected: DocumentReference = Firestore.firestore().collection("items").document(currentItem.itemID)
                itemSelected.updateData(["isSold" : true]){ err in
                    if let err = err {
                        print("CHECKING CODE (OffersMadeVC), Sold It Button - Error updating document: \(err)")
                    }
                }
                
                // Delete all offers that have refItemSelected as there item
                Firestore.firestore()
                    .collection("offers")
                    .whereField("item", isEqualTo: refItemSelected)
                    .addSnapshotListener { querySnapshot, error in
                        if let error = error {
                            print("CHECKING CODE (OffersMadeVC), Sold It Button - Error retreiving collection: \(error)") // Displays error if the listener fails
                        }
                        // Goes through each document and deletes each offer
                        if let documents = querySnapshot?.documents {
                            for document in documents {
                                Firestore.firestore().collection("offers").document(document.documentID).delete()
                            }
                        } else {
                            print("CHECKING CODE (OffersMadeVC), Sold It Button - Documents not queried") // Make's sure that all offers document queried if not, this prints
                        }
                }
                // If 'YES' is pressed than go back to the OffersVC
                self.segueBack()
            })
            
            // Cancel button
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            // Add the actions
            verify_SoldItAlert.addAction(actionYes)
            verify_SoldItAlert.addAction(actionCancel)
            
            // Add styles
            actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
            
            // Display alert
            self.present(verify_SoldItAlert, animated: true)
  
        })
        
         /**** DELETE BUTTON ****/
        let actionDelete = UIAlertAction(title: "Delete", style: .default, handler: {
            _ in
            // Alert to double check if Item is Sold
            let verify_DeleteAlert = UIAlertController(title: "Are you sure?", message: "Just want to make sure you meant to press 'Delete', this will completely delete the item.", preferredStyle: .alert)
            
            // Verify that they meant to 'Sold it' if so do the following
            let actionYes = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {
                _ in
                // `itemSelected` is the item the user wants to edit
                let itemSelected = Firestore.firestore().collection("items").document(currentItem.itemID)
                let refItemSelected: DocumentReference = Firestore.firestore().collection("items").document(currentItem.itemID)
                
                // Delete all offers that have `refItemSelected` as there item
                Firestore.firestore()
                    .collection("offers")
                    .whereField("item", isEqualTo: refItemSelected)
                    .addSnapshotListener { querySnapshot, error in
                        if let error = error {
                            print("CHECKING CODE (OffersMadeVC), Delete Button - Error retreiving collection: \(error)") // Displays error if the listener fails
                        }
                        // Goes through each document and deletes each offer
                        if let documents = querySnapshot?.documents {
                            for document in documents {
                                Firestore.firestore().collection("offers").document(document.documentID).delete()
                            }
                        } else {
                            print("CHECKING CODE (OffersMadeVC), Delete Button - Documents not queried") // Make's sure that all offers document queried if not, this prints
                            
                        }
                }
                // Delete the item from the database
                itemSelected.delete()
                
                // If 'YES' is pressed than go back to the OffersVC
                self.segueBack()
            })
            // Cancel button
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            // Add the actions
            verify_DeleteAlert.addAction(actionYes)
            verify_DeleteAlert.addAction(actionCancel)
            
            // Add styles
            actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
            
            // Display alert
            self.present(verify_DeleteAlert, animated: true)
        })
    
        /**** CANCEL BUTTON ****/
        actionDelete.setValue(UIColor.red, forKey: "titleTextColor")
        
        // Actions added
        deleteAlert.addAction(actionSoldIt)
        deleteAlert.addAction(actionDelete)
        deleteAlert.addAction(actionCancel_Delete)
        
        // Display alert
        self.present(deleteAlert, animated: true)

    }
    
    func segueBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
