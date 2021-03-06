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

class ProfileVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Constants
    let cornerRadius = CGFloat(10)
    private let imageUploadManager = ImageUploadManager()
    private let collection = Firestore.firestore().collection("users")
    
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
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var itemsSoldLbl: UILabel!
    @IBOutlet weak var followersLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        userNameField.delegate = self
        userEmailField.delegate = self
        
        self.customizeView()
        
        // Add a data listener to the "items" collection
        datasource.generalQuery(collection: "reviews", orderBy: "title", limit: nil)
            .addSnapshotListener { querySnapshot, error in
                if let documents = querySnapshot?.documents {
                    for document in documents {
                        if let review = Review(dictionary: document.data(), itemID: document.documentID) {
                            self.allReviews.append(review)
                            self.collectionView?.reloadData()
                        }
                    }
                }
        }
        
        // Display user's image and information
        if let imageData = try? Data(contentsOf: URL(string: currentUser.profileImageURL!)!) {
            let image = UIImage(data: imageData)
            userProfileImg.image = image
        }
        userNameField.text = currentUser.firstName + " " + currentUser.lastName
        userEmailField.text = Auth.auth().currentUser?.email
        userBubbleField.text = currentUser.bubbleCommunity
        ratingLbl.text = String(currentUser.rating)
        itemsSoldLbl.text = String(currentUser.itemsSold)
        followersLbl.text = String(currentUser.followers)
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

        cell.titleLbl.text = allReviews[indexPath.item].title!
        cell.bodyLbl.text = "\"" + allReviews[indexPath.item].bodyText! + "\""
        // TODO: pull user image from review.reviewer.imageUrl
        
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
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .photoLibrary
        controller.allowsEditing = true
        self.present(controller, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.userProfileImg.image = image
            // TODO: Upload this image to Firebase and save to user's document
            imageUploadManager.uploadImage(image, progressBlock: { (percentage) in
            }, completionBlock: { (fileURL, errorMessage) in
                if let fileURL = fileURL?.absoluteString {
                    if let userID = Auth.auth().currentUser?.uid {
                        let userRef = Firestore.firestore().collection("users").document(String(userID))
                        userRef.updateData([
                            "profileImageURL": fileURL
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                                let alert = UIAlertController(title: "Image Uploaded", message: "Your profile picture has been updated", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Sweet!", style: .default, handler: nil))
                                self.present(alert, animated: true)
                            }
                        }

                    }
                } else {
                    print("Error")
                }
            })
        }
        self.dismiss(animated: true, completion: nil)
    }
}
