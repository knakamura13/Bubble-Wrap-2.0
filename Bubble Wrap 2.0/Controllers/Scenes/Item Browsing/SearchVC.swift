//
//  SearchVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

var currentUser: User!
var selectedItem: Item = Item(title: "", price: 0, imageURL: "", owner: nil, itemID: "")

class SearchVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var allItems: [Item] = []
    var searchItems: [Item] = []
    var allItemImages: [UIImage] = []
    var searchItemImages: [UIImage] = []
    
    private(set) var datasource = DataSource()  // Datasource for data listener
    
    // outlets
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var searchBar: UISearchBar!
    
    // viewDidLoad: runs only once when the scene loads for the first time
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        self.customizeView() // Setup the view
        
        // Load current user's profile information from Firebase
        if let userID = Auth.auth().currentUser?.uid {
            let userDocument = Firestore.firestore().collection("users").document(userID)
            userDocument.getDocument { (document, error) in
                if let document = document {
                    if let user = User(dictionary: document.data(), itemID: document.documentID) {
                        currentUser = user
                    }
                }
            }
        }
        
        // Add a data listener to the "items" database
        datasource.generalQuery(collection: "items", orderBy: "title", limit: 25)
            .addSnapshotListener { querySnapshot, error in
                if let documents = querySnapshot?.documents {
                    self.allItems.removeAll()
                    self.searchItems.removeAll()
                    
                    for document in documents {
                        if let item = Item(dictionary: document.data(), itemID: document.documentID) {
                            self.allItems.append(item)
                            self.searchItems.append(item)
                            
                            // Download the item's image and save as a UIImage
                            let httpsReference = Storage.storage().reference(forURL: item.imageURL)
                            httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                                if let error = error {
                                    print("error - \(error)")
                                } else {
                                    if let image = UIImage(data: data!) {
                                        self.allItemImages.append(image)
                                        self.searchItemImages.append(image)
                                        self.collectionView?.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
        }
    }
    
    // viewWillAppear: runs every time the scene is about to appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.applicationIconBadgeNumber = 0 // Reset the badge number on app launch
        
        // Deselect all cells; possibly redundant code
        for selectedCell in (collectionView?.indexPathsForSelectedItems)! {
            collectionView?.deselectItem(at: selectedCell, animated: false)
        }
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        self.roundCorners([.topLeft, .topRight], radius: CGFloat(10),self.collectionView(<#T##collectionView: UICollectionView##UICollectionView#>, cellForItemAt: <#T##IndexPath#>))
//    }
    
    
    
    
    func customizeView() {
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        navigationController?.navigationBar.barTintColor = Constants.Colors.appPrimaryColor
        self.hideKeyboardWhenTappedAround() // Hide keyboard on background tap
        
        // Apply a custom spacing layout to the CollectionView
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth/1.5, height: screenWidth/1.5)
        layout.minimumInteritemSpacing = 0  // column spacing
        layout.minimumLineSpacing = 50      // row spacing
        collectionView!.collectionViewLayout = layout
    }
    
    /*
     MARK: KEYBOARD AND SEARCH BAR
     */
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Delay for 0.025 seconds
        // Purpose: Cancel Button not dismissing keyboard immediately; forced delay required
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025) {
            self.searchBar.resignFirstResponder()   // Dismiss the keyboard
        }
    }
    
    /*
     MARK: COLLECTION VIEW
     */
    
    // Set how many cells should display
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchBar.text!.count == 0 {
            searchItems = allItems      // display every item
        }
        
        return searchItems.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MyCollectionViewCell
        
        // Return an empty cell if the index is out of bounds for the images array
        if indexPath.item >= searchItemImages.count {
            return cell
        }
        
        // Populate the cell's data
        cell.cellLbl.text = self.searchItems[indexPath.item].title!
        cell.cellImg.image = self.searchItemImages[indexPath.item]
        
        // Stylize the cell
        let cornerRadius = CGFloat(10)
        cell.layer.cornerRadius = cornerRadius
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.backgroundColor = UIColor.white.cgColor
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.15
        cell.layer.shadowRadius = 4
        cell.layer.shadowOffset = CGSize(width: 2, height: 2)
        cell.layer.masksToBounds = false
        
        // Stylize the image
        cell.cellImg.layer.masksToBounds = true
        cell.cellImg.layer.cornerRadius = cornerRadius
        cell.cellImg.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        
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
        for item in allItems {
            if item.title.lowercased().contains(searchText.lowercased()) {
                searchItems.append(item)
            }
        }
        
        collectionView!.reloadData()
    }
    
    // Pass data from this VC to the segue destination VC
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let secondViewController = segue.destination as! SingleItemVC
//        secondViewController.selectedItem = selectedItem
//    }
}
