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
    
    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var offersMadeTbl: UITableView!
    
    // Variables
    var offersArray: [Offer] = []
    private(set) public var currentItem: Item = Item(title: "", price: 0, imageURL: "", owner: nil, itemID: "", category: "")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.arrayOfOffersMade()
        offersMadeTbl.dataSource = self
        offersMadeTbl.delegate = self

    }

    func arrayOfOffersMade(){
        //let vc = OffersVC()
        //document(vc.selectedItemOffer.itemID)
        print("I GO IN HERE\(currentItem.itemID)")
        let itemSelected: DocumentReference = Firestore.firestore().collection("items").document(currentItem.itemID)
        print("IM IN THE ARRAY FUNCTION")
        
        Firestore.firestore()
            .collection("offers")
            .whereField("item", isEqualTo: itemSelected)
            .addSnapshotListener { querySnapshot, error in
                if let documents = querySnapshot?.documents {
                    for document in documents {
                        if let offer = Offer(dictionary: document.data(), itemID: document.documentID) {
                             print("APPENDED OFFER")
                            self.offersArray.append(offer)
                        }
                    }
                }
            }
        
    }
    
    func getSelectedItemOffer(item: DocumentReference){
     
            item.addSnapshotListener({ (document, error) in
                if let error = error {
                    print(error)
                }
                print("THIS WORKS5")
                if let document = document {
                    print("THIS WORKS6")
                    if let item = Item(dictionary: document.data(), itemID: document.documentID) {
                        print("THIS WORKS7")
                        self.currentItem = item
                        let nothing = "Nothing was sent"
                        print("\(self.currentItem.itemID ?? nothing)")
                    }
                }
            })

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("BOOM: \(offersArray.count)")
        return self.offersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = offersMadeTbl.dequeueReusableCell(withIdentifier: "OfferMadeCell") as? OffersMadeCell
        
        //offersArray[indexPath.row].creator
        Firestore.firestore().collection("user").document(offersArray[indexPath.row].creator.documentID).getDocument { (document, error) in
            let dictionary = document?.data()
           // let name = "\(dictionary!["firstName"]) \(dictionary!["lastName"])"
            let user = User(dictionary: dictionary, itemID: (document?.documentID)!)
            print("USER_BOOM: \((user?.firstName)!)  \((user?.lastName)!)")
            cell?.nameLbl.text = (user?.firstName)! + " " + (user?.lastName)!
             print("PRICE_BOOM: \(self.offersArray[indexPath.row].price!)")
            cell?.offerPriceLbl.text = "$\((self.offersArray[indexPath.row].price)!)"
        }
        
        return cell!
    }
}
