//
//  OffersMadeVC.swift
//  Bubble Wrap 2.0
//
//  Created by Mario Lopez on 12/24/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class OffersMadeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var offersMadeTbl: UITableView!
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    let itemSelected = DocumentReference = Firestore.firestore().collection("item")
    func arrayOfOffersMade(){
       Firestore.firestore()
        .collection("offers")
        .whereField("item", isEqualTo: itemSelected)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
//    func setOfferForEachCell() {
//        datasource.generalQuery(collection: "items", orderBy: "title", limit: 5)
//            .addSnapshotListener { querySnapshot, error in
//                if let documents = querySnapshot?.documents {
//                    self.allItems.removeAll()
//                    self.searchItems.removeAll()
//
//                    for document in documents {
//                        if let item = Item(dictionary: document.data(), itemID: document.documentID) {
//                            self.allItems.append(item)
//                            self.searchItems.append(item)
//
//                            // Download the item's image and save as a UIImage
//                            let url = URL(string: item.imageURL!)!
//                            let data = try? Data(contentsOf: url)
//                            if let imageData = data {
//                                let image = UIImage(data: imageData)
//                                self.allItemImages.append(image!)
//                                self.searchItemImages.append(image!)
//                            }
//                            print("Mario")
//                            self.collectionView?.reloadData()
//                        }
//                    }
//                }
//        }
//    }
}
