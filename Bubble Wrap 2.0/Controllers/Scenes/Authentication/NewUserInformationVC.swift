//
//  NewUserInformationVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 7/5/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import Photos
import FirebaseAuth
import FirebaseFirestore

class NewUserInformationVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Outlets
    // Image Views
    @IBOutlet weak var profileImageView: UIImageView!
    // Labels
    @IBOutlet weak var titleLbl: UILabel!
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
        self.checkPermission()
    }
    
    func setupStyles() {
        // Attributes for the user's name textFields
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Light", size: 14)! // Note the !
        ]
        letsGoBtn.layer.cornerRadius = cornerRadius
        profileImageView.layer.borderWidth = 0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        firstNameTextField.attributedPlaceholder = NSAttributedString(string: "First Name",attributes: attributes)
        lastNameTextField.attributedPlaceholder = NSAttributedString(string: "Last Name",attributes: attributes)
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
        print("PROFILE TAPPED")
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .photoLibrary
        controller.allowsEditing = true
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func letsGoTapped(_ sender: Any) {
        
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
       

        // Display an alert message if a textField is empty
        var alertMessage = ""
        if (firstNameTextField.text?.isEmptyOrWhitespace())! {
            if (lastNameTextField.text?.isEmptyOrWhitespace())! {
                alertMessage = "Invalid First Name and Last Name inputed."
            } else {
                // Has last name but no first name
                alertMessage = "Invalid First Name inputed."
            }
        } else {
            if (lastNameTextField.text?.isEmptyOrWhitespace())! {
                // Has first name, but no last name
                alertMessage = "Invalid Last Name inputed."
            }
        }
        if firstName.rangeOfCharacter(from: characterset.inverted) != nil || lastName.rangeOfCharacter(from: characterset.inverted) != nil {
            let alert = UIAlertController(title: "Oops!", message: "Sorry, your name does not need special characters. You are already special enough!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            self.present(alert, animated: true)
            return
        }
        if (firstNameTextField.text?.isEmptyOrWhitespace())! || (lastNameTextField.text?.isEmptyOrWhitespace())! {
            let alert = UIAlertController(title: "Oops!", message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            self.present(alert, animated: true)
            return
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
                    "profileImageURL": profileImageView
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.profileImageView.image = imagePicked
            // TODO: Upload this image to Firebase and save to user's document
            imageUploadManager.uploadImage(imagePicked, progressBlock: { (percentage) in
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
    
    //Prompts user to allow access to their Photo Library
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            print("User do not have access to photo album.")
        case .denied:
            
            print("User has denied the permission.")
        }
    }

}

