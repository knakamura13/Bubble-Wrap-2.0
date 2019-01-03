//
//  OffersVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// Global Variable
var currentItem: Item = Item(title: "", price: 0, imageURL: "", owner: nil, itemID: "", category: "", bubble: userBubble, isSold: false)

class OffersVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Constants
    let cornerRadius = CGFloat(10)
    
    // Variables
    var topItems: [Item] = []
    var bottomOffers: [Offer] = []
    var topItemImages: [UIImage] = []
    var bottomOfferImages: [UIImage] = []
    var cellTapped: Bool! // Checks whether cell is tapped to prevent users from breaking the app by tapping twice rapidly
    
    private(set) var datasource = DataSource()  // Datasource for data listener

    // Outlets
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var bottomCollectionView: UICollectionView!
    @IBOutlet weak var offersReceivedLabel: UILabel!
    @IBOutlet weak var offersCreatedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = Constants.Colors.appPrimaryColor
        // NavBar title color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:Constants.Colors.TextColors.primaryWhite, NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 21)!]
        
        cellTapped = false
        listenForOffers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cellTapped = false
    }
    
    
    
    func listenForOffers() {
        // Get UserID and create a document reference for the WHERE parameter
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let userDocument: DocumentReference = Firestore.firestore().collection("users").document(userID)
        print("Listen for offers")
        // Listen to "offers" collection WHERE "receiver" is current user
        Firestore.firestore()
            .collection("items")
            .whereField("owner", isEqualTo: userDocument)
            .whereField("isSold", isEqualTo: false)
            .order(by: "price")
            .limit(to: 100)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("CHECKING CODE (OffersVC), listenForOffers() [owner] - Error retreiving collection: \(error)") // Displays error if the listener fails
                }
                self.topItems.removeAll()
                self.topItemImages.removeAll()
                
                if let documents = querySnapshot?.documents {
                    for document in documents {
                        // THhis documents would be changed  to be items
                        if let item = Item(dictionary: document.data(), itemID: document.documentID) {
                            self.topItems.append(item)
                            let url = URL(string: item.imageURL!)!
                            let data = try? Data(contentsOf: url)
                            if let imageData = data {
                                let image = UIImage(data: imageData)
                                self.topItemImages.append(image!)
                            }
                        }
                        self.topCollectionView?.reloadData() // Refresh the collection view
                    }
                } else {print("CHECKING CODE (OffersVC), listenForOffers() [OWNER]: Documents not queried")}      // Make's sure that the offeris created if not, this prints
            }
        
        // Listen to "offers" collection WHERE "creator" is current user
        Firestore.firestore()
            .collection("offers")
            .whereField("creator", isEqualTo: userDocument)
            .order(by: "price")
            .limit(to: 100)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("CHECKING CODE (OffersVC), listenForOffers() [creator] - Error retreiving collection: \(error)") // Displays error if the listener fails
                }

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
                            
                            self.bottomCollectionView?.reloadData()             // Refresh the collection view
                        } else {print("CHECKING CODE (OffersVC), listenForOffers() [CREATOR]: Documents not queried")}         // Makes sure that the if let goes through and the offer is created, if not this prints
                    }
                }
            }
    }
    
    // MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.topCollectionView {
            return topItems.count
        } else {
            return bottomOffers.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        if collectionView == self.topCollectionView {
            // Populate the top collection view
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "TopOffersCell", for: indexPath as IndexPath) as! TopItemsCell
            if self.topItemImages.indices.contains(indexPath.item) {
                cell2.cellImg.image = self.topItemImages[indexPath.item]
            }
            cell2.cellLbl.text = topItems[indexPath.row].title
            
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
                        if self.bottomOfferImages.indices.contains(indexPath.item) {
                            cell2.cellImg.image = self.bottomOfferImages[indexPath.item]
                        }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var vc: UIViewController?
        if cellTapped == false {
            if collectionView == self.topCollectionView {
                // Set the Cell tapped button to true
                cellTapped = true
                // Set up the ViewController that the user will be "pushed" to when item is click in collection view
                vc = storyboard?.instantiateViewController(withIdentifier: "OffersMadeVC")
                self.definesPresentationContext = true
                vc?.modalPresentationStyle = .overCurrentContext
                
                // Sets current Item seleceted to the gobal variable currentItem to be used in OffersMadeVC
                currentItem = self.topItems[indexPath.row]
                // Allows the OffersMadeVC to have the NavigationBar with the back button
                self.navigationController!.pushViewController(vc!, animated:true)
                
            } else {
                // Set the Cell tapped button to true
                cellTapped = true
                // Bottom collection view item clicked goes to MessagesListVS
                vc = storyboard?.instantiateViewController(withIdentifier: "MessagesListVC")
                self.definesPresentationContext = true
                vc?.modalPresentationStyle = .overCurrentContext
                self.present(vc!, animated: true, completion: nil)
            }
        }
    }
}
