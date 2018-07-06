//
//  NewUserInformationVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 7/5/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NewUserInformationVC: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    // Image Views
    @IBOutlet weak var profileImageView: UIImageView!
    // Labels
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var firstNameLbl: UILabel!
    @IBOutlet weak var lastNameLbl: UILabel!
    // Text Fields
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    // Buttons
    @IBOutlet weak var letsGoBtn: UIButton!
    
    // Contants
    let cornerRadius: CGFloat = 10
    let placeholderImageURL: String = "https://firebasestorage.googleapis.com/v0/b/bubble-wrap-2-16e4b.appspot.com/o/itemImages%2F1529951599.378715.jpg?alt=media&token=30cb4efb-8652-4441-84b9-619fbbdee3ed"
    private let imageUploadManager = ImageUploadManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        
        if Auth.auth().currentUser == nil {
            print("User is not authenticated")
        }

        self.setupStyles()
    }
    
    func setupStyles() {
        letsGoBtn.layer.cornerRadius = cornerRadius
        self.hideKeyboardWhenTappedAround() // Hide keyboard on background tap
    }
    
    // Jump from usernameField to passwordField, then hide the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        } else {
            lastNameTextField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func profileTapped(_ sender: Any) {
        print("Profile image tapped")
    }
    
    @IBAction func letsGoTapped(_ sender: Any) {
        
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        
        let noFirstName: Bool = (firstName == "")
        let noLastName: Bool = (lastName == "")
        
        // Display an alert message if a textField is empty
        var alertMessage = ""
        if noFirstName {
            if noLastName {
                alertMessage = "You need to add your first and last name."
            } else {
                // Has last name but no first name
                alertMessage = "You need to add your first name."
            }
        } else {
            if noLastName {
                // Has first name, but no last name
                alertMessage = "You need to add your last name."
            }
        }
        if noFirstName || noLastName {
            let alert = UIAlertController(title: "Oops!", message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
        } // End: Display an alert message if a textField is empty
        
        // Get profile image from the UIView if it's defined, or apply a placeholder image to the user profile
        if let profileImage = profileImageView.image {
            updateUserData(firstName: firstName, lastName: lastName, profileImage: profileImage)
        } else {
            if let userID = Auth.auth().currentUser?.uid {
                let userRef = Firestore.firestore().collection("users").document(String(userID))
                userRef.updateData(([
                    "firstName": firstName,
                    "lastName": lastName,
                    "profileImageURL": placeholderImageURL
                    ])) { (error) in
                        if error != nil {
                            print("KYLE: error \(error!)")
                        }
                        
                        self.performSegue(withIdentifier: "segueNewUserToTabBar", sender: nil)
                    }
            }
        }
    }
    
    // Set firstName, lastName, and profileImageURL fields of the user's FireStore document
    func updateUserData(firstName: String, lastName: String, profileImage: UIImage?) {
        if let image = profileImage {
            imageUploadManager.uploadImage(image, progressBlock: { (percentage) in
            }, completionBlock: { (fileURL, error) in
                if error != nil {
                    print("KYLE: error \(error!)")
                }
                
                if let url = fileURL?.absoluteString {
                    if let userID = Auth.auth().currentUser?.uid {
                        // Update the user's FireStore data
                        let userRef = Firestore.firestore().collection("users").document(String(userID))
                        userRef.updateData([
                            "firstName": firstName,
                            "lastName": lastName,
                            "profileImageURL": url
                        ])
                    }
                    
                    self.performSegue(withIdentifier: "segueNewUserToTabBar", sender: nil)
                } else {
                    print("KYLE: Undefined fileURL")
                }
                
            })
        }
    }
}
