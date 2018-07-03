//
//  OffersVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import Firebase

class OffersVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Constants
    let cornerRadius = CGFloat(10)
    
    // Variables
    var topOffers: [Offer] = []
    var bottomOffers: [Offer] = []
    var topOfferImages: [UIImage] = []
    var bottomOfferImages: [UIImage] = []
    
    private(set) var datasource = DataSource()  // Datasource for data listener

    // Outlets
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var bottomCollectionView: UICollectionView!
    @IBOutlet weak var offersReceivedLabel: UILabel!
    @IBOutlet weak var offersCreatedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = Constants.Colors.appPrimaryColor
        
        listenForOffers()
    }
    
    func listenForOffers() {
        // Get UserID and create a document reference for the WHERE parameter
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let userDocument: DocumentReference = Firestore.firestore().collection("users").document(userID)
        
        // Listen to "offers" collection WHERE "receiver" is current user
        Firestore.firestore()
            .collection("offers")
            .whereField("recipient", isEqualTo: userDocument)
            .order(by: "price")
            .limit(to: 100)
            .addSnapshotListener { querySnapshot, error in
                if let documents = querySnapshot?.documents {
                    for document in documents {
                        if let offer = Offer(dictionary: document.data(), itemID: document.documentID) {
                            self.topOffers.append(offer)
                            
                            // Download the offer's items image and save as a UIImage; append to images array
                            offer.item!.getDocument { (document, error) in
                                if let document = document {
                                    if let item = Item(dictionary: document.data(), itemID: document.documentID) {
                                        let url = URL(string: item.imageURL!)!
                                        let data = try? Data(contentsOf: url)
                                        if let imageData = data {
                                            let image = UIImage(data: imageData)
                                            self.topOfferImages.append(image!)
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
                
            // Fetch all created offers
            for offer in currentUser.offersCreated! {
                // TODO: replace with snapshot listener
                offer.getDocument { (document, error) in
                    if let document = document {
                        if let offer = Offer(dictionary: document.data(), itemID: document.documentID) {
                            self.offersCreated.append(offer)
                            
                            self.topCollectionView?.reloadData()    // Refresh the collection view
                        }
                    }
                } else {
                    print("KYLE: no documents to show")
                }
        }
        
        // Listen to "offers" collection WHERE "creator" is current user
        Firestore.firestore()
            .collection("offers")
            .whereField("creator", isEqualTo: userDocument)
            .order(by: "price")
            .limit(to: 100)
            .addSnapshotListener { querySnapshot, error in
                if let documents = querySnapshot?.documents {
                    for document in documents {
                        if let offer = Offer(dictionary: document.data(), itemID: document.documentID) {
                            self.bottomOffers.append(offer)
                            
                            // Download the offer's items image and save as a UIImage; append to images array
                            offer.item!.getDocument { (document, error) in
                                if let document = document {
                                    if let item = Item(dictionary: document.data(), itemID: document.documentID) {
                                        let url = URL(string: item.imageURL!)!
                                        let data = try? Data(contentsOf: url)
                                        if let imageData = data {
                                            let image = UIImage(data: imageData)
                                            self.bottomOfferImages.append(image!)
                                        }
                                    }
                                }
                            }
                            
                            self.bottomCollectionView?.reloadData()     // Refresh the collection view
                        }
                    }
                } else {
                    print("KYLE: no documents to show")
                }
        }
        
        // Listen to "offers" collection WHERE "creator" is current user
        Firestore.firestore()
            .collection("offers")
            .whereField("creator", isEqualTo: userDocument)
            .order(by: "price")
            .limit(to: 100)
            .addSnapshotListener { querySnapshot, error in
                if let documents = querySnapshot?.documents {
                    for document in documents {
                        if let offer = Offer(dictionary: document.data(), itemID: document.documentID) {
                            self.bottomOffers.append(offer)
                            
                            // Download the offer's items image and save as a UIImage; append to images array
                            offer.item!.getDocument { (document, error) in
                                if let document = document {
                                    if let item = Item(dictionary: document.data(), itemID: document.documentID) {
                                        let url = URL(string: item.imageURL!)!
                                        let data = try? Data(contentsOf: url)
                                        if let imageData = data {
                                            let image = UIImage(data: imageData)
                                            self.bottomOfferImages.append(image!)
                                        }
                                    }
                                }
                            }
                            
                            self.bottomCollectionView?.reloadData()     // Refresh the collection view
                        }
                    }
                } else {
                    print("KYLE: no documents to show")
                }
            }
            
            for offer in currentUser.offersReceived! {
                // TODO: replace with snapshot listener
                offer.getDocument { (document, error) in
                    if let document = document {
                        let offer = Offer(dictionary: document.data(), itemID: document.documentID)
                        self.offersReceived.append(offer!)
                    }
                }
            }
        }
    }
    
    // MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.topCollectionView {
            return topOffers.count
        } else {
            return bottomOffers.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        if collectionView == self.topCollectionView {
            // Populate the top collection view
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "TopOffersCell", for: indexPath as IndexPath) as! TopOffersCell
            topOffers[indexPath.item].item.getDocument { (document, error) in
                if let document = document {
                    if let item = Item(dictionary: document.data(), itemID: document.documentID) {
                        cell2.cellImg.image = self.topOfferImages[indexPath.item]
                        cell2.cellLbl.text = item.title
                    }
                }
            }
            
            // Stylize the cell's imageView
            let rectShape = CAShapeLayer()
            rectShape.bounds = cell2.cellImg.frame
            rectShape.position = cell2.cellImg.center
            rectShape.path = UIBezierPath(roundedRect:  cell2.cellImg.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
            cell2.cellImg.layer.mask = rectShape
            
            cell = cell2
        } else {
            // Populate the bottom collection view
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "BottomOffersCell", for: indexPath as IndexPath) as! BottomOffersCell
            bottomOffers[indexPath.item].item.getDocument { (document, error) in
                if let document = document {
                    if let item = Item(dictionary: document.data(), itemID: document.documentID) {
                        cell2.cellImg.image = self.bottomOfferImages[indexPath.item]
                        cell2.cellLbl.text = item.title
                    }
                }
            }
            
            // Stylize the cell's imageView
            let rectShape = CAShapeLayer()
            rectShape.bounds = cell2.cellImg.frame
            rectShape.position = cell2.cellImg.center
            rectShape.path = UIBezierPath(roundedRect:  cell2.cellImg.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
            cell2.cellImg.layer.mask = rectShape
            
            cell = cell2
        }
        
        // Stylize the cell
        cell.layer.cornerRadius = cornerRadius
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.backgroundColor = UIColor.white.cgColor
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.15
        cell.layer.shadowRadius = 4
        cell.layer.shadowOffset = CGSize(width: 2, height: 2)
        cell.layer.masksToBounds = false
        
        return cell
    }
}
