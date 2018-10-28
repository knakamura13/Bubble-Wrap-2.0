//
//  CreateItemVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseFirestore

class CreateItemVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // Constants
    private let imageUploadManager = ImageUploadManager()
    private let collection = Firestore.firestore().collection("items")
    
    // Variables
    var createItemWasPressed: Bool!
    
    // Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var smallImg1: UIImageView!
    @IBOutlet weak var smallImg2: UIImageView!
    @IBOutlet weak var smallImg3: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var createItemBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        priceTextField.delegate = self
        descriptionTextView.delegate = self
        
        self.customizeVisuals() // Setup the visuals
        self.hideKeyboardWhenTappedAround() // Hide keyboard on background tap
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createItemWasPressed = false
    }
    
    func customizeVisuals() {
        navigationController?.navigationBar.barTintColor = Constants.Colors.appPrimaryColor
        scrollView.contentSize.height = 750 // arbitrary integer; increase if content does not fit in contentSize
        let cornerRadius = CGFloat(10)
        smallImg1.layer.cornerRadius = cornerRadius
        smallImg2.layer.cornerRadius = cornerRadius
        smallImg3.layer.cornerRadius = cornerRadius
        mainImg.image = demoPicsumImages.randomElement()
        smallImg1.image = demoPicsumImages.randomElement()
        smallImg2.image = demoPicsumImages.randomElement()
        smallImg3.image = demoPicsumImages.randomElement()
        descriptionTextView.layer.borderColor = UIColor(hex: 0xcdcdcd).cgColor   // light grey
        descriptionTextView.layer.borderWidth = 1/3
        descriptionTextView.layer.cornerRadius = 6
        createItemBtn.layer.cornerRadius = cornerRadius
        createItemBtn.layer.backgroundColor = Constants.Colors.appPrimaryColor.cgColor
    }
    
    // Jump from usernameField to passwordField, then hide the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            priceTextField.becomeFirstResponder()
        } else if textField == priceTextField {
            descriptionTextView.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func createItemPressed(_ sender: Any) {
        if !createItemWasPressed {
            // Ensure all information is filled out and not nil
            if let image = mainImg.image,
                let price = Int(priceTextField.text!),
                let title = titleTextField.text,
                let description = descriptionTextView.text,
                let userID = Auth.auth().currentUser?.uid{
                    let owner = Firestore.firestore().collection("users").document(userID)
                    self.createItem(image: image, price: price, title: title, description: description, owner: owner)
                    self.createItemWasPressed = true
            } else {
                    let alert = UIAlertController(title: "You missed something.", message: "Please add an image, title, price, and description.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    self.createItemWasPressed = false
            }
            
            // Navigate back to SearchVC
            let vc = storyboard?.instantiateViewController(withIdentifier: "TabBarController")
            self.present(vc!, animated: false, completion: nil)
        }
        
        
    }
    
    // Create Item object and send its data to Firebase
    func createItem(image: UIImage, price: Int, title: String, description: String, owner: DocumentReference) {
        imageUploadManager.uploadImage(image, progressBlock: { (percentage) in
        }, completionBlock: { (fileURL, errorMessage) in
            if let fileURL = fileURL {
                let item = Item(title: title, price: NSNumber(value: price), imageURL: fileURL.absoluteString, owner: owner, itemID: "")
                var ref: DocumentReference? = nil
                ref = self.collection.addDocument(data: item.dictionary()) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        ref!.updateData(["itemRef": ref])
                    }
                }
            }
        })
    }
}
