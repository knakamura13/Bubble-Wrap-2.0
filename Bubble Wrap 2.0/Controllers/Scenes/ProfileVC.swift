//
//  ProfileVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import Photos
import FirebaseAuth
import FirebaseFirestore

var globalProfilePicture: UIImage!

class ProfileVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: Properties
    
    let cornerRadius = CGFloat(10)
    private let imageUploadManager = ImageUploadManager()
    private let collection = Firestore.firestore().collection("users")
    var allReviews: [Review] = []
    var selectedReview: Review?
    var tappedName: Bool = false
    private(set) var datasource = DataSource()
    
    
    // MARK: IBOutlets
    
    @IBOutlet weak var signOutBtn: UIBarButtonItem!
    @IBOutlet weak var profileImgView: UIControl!
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userBubbleField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // MARK: View load and appear
    
    override func viewDidLoad() {
        self.customizeViews()
        self.updateContentsFromUserDefaults()
        self.checkPhotoLibraryPermissions()
    }
    
    // MARK: IBActions
    
    @IBAction func signOutPressed(_ sender: Any) {
        signOutUser()
    }
    
    @IBAction func nameLblTapped (_ gestureRecognizer : UITapGestureRecognizer ) {
        if gestureRecognizer.view != nil && gestureRecognizer.state == .ended {
            updateUserName()
        }
    }
    
    @IBAction func profileImgTapped(_ sender: Any) {
        updateProfileImage()
    }
    

    // MARK: Custom functions
    
    /**
     * Customizes this view controller's contents on page load.
    */
    func customizeViews() {
        // Change text color of the sign out button.
        signOutBtn.tintColor = Constants.Colors.TextColors.secondaryBlack
        
        // Change image color of navigation bar icon.
        navigationController?.navigationBar.barTintColor = Constants.Colors.appPrimaryColor
        
        // Set corner radius to make profile image view circular.
        profileImgView.layer.cornerRadius = CGFloat(self.profileImgView.frame.width/2)
        
        // Dismiss the keyboard on background tap.
        self.hideKeyboardWhenTappedAround()
        
        // Setup custom layout for the collection view.
        let screenWidth = UIScreen.main.bounds.width
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth/3-2, height: screenWidth/3-2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 2
        collectionView!.collectionViewLayout = layout
    }
    
    /**
     * Sets the user's profile information if data was stored in UserDefaults.
    */
    func updateContentsFromUserDefaults() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.userNameLbl.text = UserDefaults.standard.string(forKey: "firstName")! + " " + UserDefaults.standard.string(forKey: "lastName")!
            self.userBubbleField.text =  UserDefaults.standard.string(forKey: "bubbleCommunity")
            
            // Upload picture asynchronously.
            if let imgURL = URL(string: UserDefaults.standard.string(forKey: "profileImgURL")!) {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: imgURL)
                    DispatchQueue.main.async{
                        if let imageData = data {
                            let image = UIImage(data: imageData)
                            globalProfilePicture = image!
                            self.userProfileImg.image = image
                        }
                    }
                }
            } else if let imgURL = URL(string: currentUser.profileImageURL) {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: imgURL)
                    DispatchQueue.main.async{
                        if let imageData = data {
                            let image = UIImage(data: imageData)
                            globalProfilePicture = image!
                            self.userProfileImg.image = image
                        }
                    }
                }
            }
        }
    }

    /**
     * Prompts the user to allow access to their photo library if not already authorized.
    */
    func checkPhotoLibraryPermissions() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
            case .authorized:
                break
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({(newStatus) in})
            case .restricted:
                break
            case .denied:
                break
        }
    }
    
    /**
     * Signs the user out and sends them back to the `AuthenticationVC` view controller.
    */
    func signOutUser() {
        do {
            try Auth.auth().signOut()
            let vc = storyboard?.instantiateViewController(withIdentifier: "AuthenticationVC")
            self.present(vc!, animated: true, completion: nil)
        } catch {
            // Handle error with sign out
        }
    }
    
    /**
     * Presents a UIAlert with two textfields to allow the user to update their name.
    */
    func updateUserName() {
        let alert = UIAlertController(title: "Change Your Name", message: "Enter your name!", preferredStyle: .alert)
        alert.addTextField { (textField1: UITextField) in
            textField1.placeholder = "First Name"
        }
        alert.addTextField { (textField2: UITextField) in
            textField2.placeholder = "Last Name"
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action: UIAlertAction) in
            if let textField1 = alert.textFields?.first {
                if let textField2 = alert.textFields?[1]{
                    if textField1.text?.count == 0 || textField2.text?.count == 0{
                        let alert = UIAlertController(title: "Error", message: "You have not updated both your first and last name.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    } else {
                        // If both text fields have text, update Firestore values.
                        if let userID = Auth.auth().currentUser?.uid {
                            let userRef = Firestore.firestore().collection("users").document(String(userID))
                            userRef.updateData([
                                "firstName": textField1.text!,
                                "lastName": textField2.text!
                            ]) { err in
                                if let error = err {
                                    print("Error updating user profile information with error: \(error).")
                                } else {
                                    let alert = UIAlertController(title: "Name Updated", message: "Your first and last name have been updated!", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                                    self.userNameLbl.text = textField1.text! + " " + textField2.text!
                                    self.present(alert, animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     * Presents a UIImagePickerController to allow the user to set a new profile picture.
    */
    func updateProfileImage() {
        let controller = UIImagePickerController()
        
        controller.delegate = self
        controller.sourceType = .photoLibrary
        controller.allowsEditing = true
        
        self.present(controller, animated: true, completion: nil)
    }
    
    
    // MARK: Image Picker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.userProfileImg.image = imagePicked
            imageUploadManager.uploadImage(imagePicked, progressBlock: { (percentage) in
                // Handle the upload progress.
            }, completionBlock: { (fileURL, errorMessage) in
                // Image uploaded successfully or Firebase returned an error.
                if let fileURL = fileURL?.absoluteString {
                    if let userID = Auth.auth().currentUser?.uid {
                        let userRef = Firestore.firestore().collection("users").document(String(userID))
                        userRef.updateData([
                            "profileImageURL": fileURL
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                let alert = UIAlertController(title: "Image Uploaded", message: "Your profile picture has been updated", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Sweet!", style: .default, handler: nil))
                                self.present(alert, animated: true)
                            }
                        }
                    }
                }
            })
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileItemCell", for: indexPath as IndexPath) as! ProfileItemCell
        
        cell.cellLbl.text = "Item Name"
        cell.cellImg.image = UIImage(named: "item-img-3")
        
        return cell
    }
}
