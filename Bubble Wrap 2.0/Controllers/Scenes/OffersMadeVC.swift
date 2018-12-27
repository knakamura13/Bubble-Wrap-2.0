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

class OffersMadeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Outlets
    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var offersMadeTbl: UITableView!
    
    // Variables
    var offersArray: [Offer] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Run an async function in order to run through the arrayOfOffersMade first before displaying the table
        DispatchQueue.main.async() {
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
                if let documents = querySnapshot?.documents {
                    for document in documents {
                        if let offer = Offer(dictionary: document.data(), itemID: document.documentID) {
                            // Append the offer to the array offersArray
                            self.offersArray.append(offer)
                            // Reload the data to the table to display the offers' information in the table
                            self.offersMadeTbl.reloadData()
                        }
                    }
                }
            }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Set the amount of cells for the table depending on the number of offers in offersArray
        return offersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create cell so if the user where to scroll past cells no longer showing, instead of creating a whole new cell (which uses up memory) this reuses the cell no longer seen
        let cell = offersMadeTbl.dequeueReusableCell(withIdentifier: "OfferMadeCell") as? OffersMadeCell
        
        // Make a query to the database to get the name and price of the person making the offer
        Firestore.firestore().collection("users").document(offersArray[indexPath.row].creator.documentID).getDocument { (document, error) in
            let dictionary = document?.data()
            let user = User(dictionary: dictionary, itemID: (document?.documentID)!)
            cell?.nameLbl.text = (user?.firstName)! + " " + (user?.lastName)!
            cell?.offerPriceLbl.text = "$\((self.offersArray[indexPath.row].price)!)"
        }
        
        return cell!
    }
    
    // Sets the title of the item
    func setStyles(){
        itemNameLbl.text = "Offers for \(currentItem.title!)"
        let navBar = navigationController?.navigationBar
        self.view.addSubview(navBar!);
        let navItem = UINavigationItem(title: "Delete");
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(deleteButtonTapped(_:)));
        navItem.rightBarButtonItem = doneItem;
        navBar!.setItems([navItem], animated: false);
    }
    
    @objc func deleteButtonTapped(_ sender : UIButton) {
        print("button tapped")
    }
}
