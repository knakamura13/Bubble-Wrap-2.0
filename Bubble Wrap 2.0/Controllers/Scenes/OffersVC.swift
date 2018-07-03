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
    var offersReceived: [Offer] = []
    var offersCreated: [Offer] = []
    var allOffersReceivedImages: [UIImage] = []
    var allOffersCreatedImages: [UIImage] = []
    
    private(set) var datasource = DataSource()  // Datasource for data listener

    // Outlets
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var bottomCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = Constants.Colors.appPrimaryColor
        
        // Display only the current user's sent and received offers
        if Auth.auth().currentUser?.uid != nil {
            // Fetch all received offers
            for offer in currentUser.offersReceived! {
                offer.getDocument { (document, error) in
                    if let document = document {
                        if let offer = Offer(dictionary: document.data(), itemID: document.documentID) {
                            self.offersReceived.append(offer)
                            
                            // Download the offer's item's image and save as a UIImage; append to images array
                            offer.item!.getDocument { (document, error) in
                                if let document = document {
                                    let item = Item(dictionary: document.data(), itemID: document.documentID)
                                    let url = URL(string: item!.imageURL!)!
                                    let data = try? Data(contentsOf: url)
                                    if let imageData = data {
                                        let image = UIImage(data: imageData)
                                        self.allOffersReceivedImages.append(image!)
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
                            
                            // Download the offer's item's image and save as a UIImage; append to images array
                            offer.item!.getDocument { (document, error) in
                                if let document = document {
                                    let item = Item(dictionary: document.data(), itemID: document.documentID)
                                    let url = URL(string: item!.imageURL!)!
                                    let data = try? Data(contentsOf: url)
                                    if let imageData = data {
                                        let image = UIImage(data: imageData)
                                        self.allOffersCreatedImages.append(image!)
                                    }
                                }
                            }
                        }
                    }
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.topCollectionView {
            return offersReceived.count
        } else {
            return offersCreated.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        if collectionView == self.topCollectionView {
            // Populate the top collection view
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "TopOffersCell", for: indexPath as IndexPath) as! TopOffersCell
            cell2.cellImg.image = demoPicsumImages.randomElement()
            offersReceived[indexPath.item].item.getDocument { (document, error) in
                if let document = document {
                    if let item = Item(dictionary: document.data(), itemID: document.documentID) {
                        cell2.cellImg.image = self.allOffersReceivedImages[indexPath.item]
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
            offersCreated[indexPath.item].item.getDocument { (document, error) in
                if let document = document {
                    if let item = Item(dictionary: document.data(), itemID: document.documentID) {
                        cell2.cellImg.image = self.allOffersCreatedImages[indexPath.item]
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
    
    // Actions
    
}
