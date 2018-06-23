//
//  ProfileVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    
    // Constants
    let cornerRadius = CGFloat(10)
    
    // Variables
    var allReviews: [Review] = []
    var selectedReview: Review?
    
    private(set) var datasource = DataSource()  // Datasource for data listener
    
    // Outlets
    @IBOutlet weak var signOutBtn: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImgView: UIControl!
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var userEmailField: UITextField!
    @IBOutlet weak var userBubbleField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        userNameField.delegate = self
        userEmailField.delegate = self
        
        self.customizeView()
        
        // Add a data listener to the "items" database
        datasource.reviewsQuery()
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                for document in documents {
                    if let review = Review(dictionary: document.data(), itemID: document.documentID) {
                        self.allReviews.append(review)
                        self.collectionView?.reloadData()
                    }
                }
        }
        
        userNameField.text = "Kyle Nakamura"
        userEmailField.text = "knakamura13@apu.edu"
        userBubbleField.text = "Azusa Pacific University"
    }
    
    // Customize visuals
    func customizeView() {
        signOutBtn.tintColor = Constants.Colors.TextColors.secondaryBlack
        scrollView.contentSize.height = 800
        navigationController?.navigationBar.barTintColor = Constants.Colors.appPrimaryColor
        profileImgView.layer.cornerRadius = CGFloat(self.profileImgView.frame.width/2)
        self.hideKeyboardWhenTappedAround() // Hide keyboard on background tap
    }
    
    // MARK: Textfields and Keyboard
    // Jump from userName to userEmail, then hide the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameField {
            userEmailField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allReviews.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Populate the collection view cells
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewCell", for: indexPath as IndexPath) as! ReviewCell
        cell.cellLbl.text = allReviews[indexPath.item].title
        
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
    
    // MARK: Actions
    @IBAction func signOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let vc = storyboard?.instantiateViewController(withIdentifier: "AuthenticationVC")
            self.present(vc!, animated: true, completion: nil)
        } catch {
            // Handle error with sign out
        }
    }
    
    @IBAction func profileImgTapped(_ sender: Any) {
        
    }
}
