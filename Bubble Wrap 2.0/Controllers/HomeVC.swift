//
//  HomeVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class HomeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var allItemsNames: [String] = []
    var allItemImages: [UIImage] = []
    var searchItems: [String] = []
    var selectedItem: String = ""
    
    // outlets
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var searchBar: UISearchBar!
    
    // viewDidLoad: runs only once when the scene loads for the first time
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        // Setup the view
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        navigationController?.navigationBar.barTintColor = Constants.Colors.appPrimaryColor
        
        // Apply a custom spacing layout to the CollectionView
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth/1.5, height: screenWidth/1.5)
        layout.minimumInteritemSpacing = 0  // column spacing
        layout.minimumLineSpacing = 50      // row spacing
        collectionView!.collectionViewLayout = layout
        
        // Set the data
        allItemsNames = ["Apple Watch (Series 3)", "APU Year Book", "Razer Gaming Mouse", "2017 MacBook Pro", "24\" ASUS Monitor"]
        for i in 1...10 {
            allItemImages.append(UIImage(named: "item-img-\(i).jpg")!)
        }
        
        let db = Firestore.firestore()
        
        // Fetch data from all items
        db.collection("items")
            .order(by: "title")
            .getDocuments { (snapshot, err) in
                if err != nil {
                    print(err!)
                } else {
                    print("\n\nNow printing all items\n")
                    for document in (snapshot?.documents)! {
                        if let title = document.data()["title"] as? String {
                            if let price = document.data()["price"] as? Int {
                                if let images = document.data()["images"] as? [String] {
                                    print(title)
                                    print(price)
                                    print()
                                }
                            }
                        }
                    }
                }
            }
    }
    
    // viewWillAppear: runs every time the scene is about to appear
    override func viewWillAppear(_ animated: Bool) {
        // Deselect all cells
        for selectedCell in (collectionView?.indexPathsForSelectedItems)! {
            collectionView?.deselectItem(at: selectedCell, animated: false)
        }
    }
    
    /*
     MARK: COLLECTION VIEW
     */
    
    // Set how many cells should display
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchBar.text!.count == 0 {
            // if search bar is empty, display all items
            searchItems = allItemsNames
        }
        
        return searchItems.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MyCollectionViewCell
        
        // Populate the cell's data
        cell.cellLbl.text = self.searchItems[indexPath.item]
        let data = try? Data(contentsOf: URL(string: "https://picsum.photos/250/?random")!) // pull a random image from the web
        // TODO: Fetch image urls from Firestore
        cell.cellImg.image = UIImage(data: data!)
        
        // Stylize the cell
        let cornerRadius = CGFloat(10)
        cell.layer.cornerRadius = cornerRadius
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.backgroundColor = UIColor.white.cgColor
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowRadius = cornerRadius
        cell.layer.shadowOffset = CGSize(width: 2, height: 2)
        cell.layer.masksToBounds = false
        
        // Stylize the cell's imageView
        let rectShape = CAShapeLayer()
        rectShape.bounds = cell.cellImg.frame
        rectShape.position = cell.cellImg.center
        rectShape.path = UIBezierPath(roundedRect:  cell.cellImg.bounds,     byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        cell.cellImg.layer.mask = rectShape
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem = searchItems[indexPath.row]
        performSegue(withIdentifier: "singleItemSegue", sender: nil)
    }
    
    /*
     MARK: SEARCH BAR
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchItems = []
        for item in allItemsNames {
            if item.lowercased().contains(searchText.lowercased()) {
                searchItems.append(item)
            }
        }
        
        collectionView!.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass data from this VC to the segue destination VC
        let secondViewController = segue.destination as! SingleItemVC
        secondViewController.selectedItem = selectedItem
    }
}
