//
//  CreateItemVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateItemVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // Constants
    private let imageUploadManager = ImageUploadManager()
    private let collection = Firestore.firestore().collection("items")
    
    // Variables
    var createItemWasPressed: Bool!
    var categoryChoosen = ""
    
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
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        priceTextField.delegate = self
        descriptionTextView.delegate = self
        
        categoryPicker.dataSource = self
        categoryPicker.delegate = self

        self.customizeVisuals() // Setup the visuals
        self.hideKeyboardWhenTappedAround() // Hide keyboard on background tap
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createItemWasPressed = false
    }
    
    func customizeVisuals() {
        navigationController?.navigationBar.barTintColor = Constants.Colors.appPrimaryColor
        
        var heightOfContent: CGFloat = 0.0
        if let lastView: UIView = scrollView.subviews.last {
            let yPosition = lastView.frame.origin.y
            let height = lastView.frame.size.height
            heightOfContent = yPosition + height
        } else {
            heightOfContent = 1150
        }
        scrollView.contentSize.height = heightOfContent
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.heightAnchor.constraint(equalToConstant: heightOfContent)
        
//        scrollView.contentSize.height = 1150 // arbitrary integer; increase if content does not fit in contentSize
        
        
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
    
    //Create category function
    
    
    @IBAction func createItemPressed(_ sender: Any) {
        if !createItemWasPressed {
            // Check if the input fields (Price, Title, Description) have correct inputs
            // The gaur let checks first if something has a value if not it excutes the else. If you have other condition you want to chcek you will have to write an if statment after teh gaurd let else statemetn. As it is done for the title propterty in teh following gaurd lets
            guard let image = mainImg.image else {
                let alert = UIAlertController(title: "You missed something.", message: "Please make sure you have at least one image.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.createItemWasPressed = false
                return
            }
            
            /* Check title is at least 4 characters */
            guard let title = titleTextField.text else {
                let alert = UIAlertController(title: "You missed something.", message: "Please make sure you have a title.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.createItemWasPressed = false
                return
            }
            if title.count < 4 {
                let alert = UIAlertController(title: "Check Title!", message: "Please make your title has at least 4 characters.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.createItemWasPressed = false
                return
            }
            
            /* Check price is not higher than $99,999 */
            guard let price = Int(priceTextField.text!) else {
                let alert = UIAlertController(title: "You missed something.", message: "Please make sure you have a price.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.createItemWasPressed = false
                return
            }
            if price > 99999{
                let alert = UIAlertController(title: "Check Price!", message: "Look no one can afford that...please consider lowering the price.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.createItemWasPressed = false
                return
            }
            
            /* Check description is at least 15 characters */
            guard let description = descriptionTextView.text else {
                let alert = UIAlertController(title: "You missed something.", message: "Please make sure you have a description.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.createItemWasPressed = false
                return
            }
            
            // Create user's item is all the condition hace been pas
            if description.count >= 15{
                if let userID = Auth.auth().currentUser?.uid{
                    let owner = Firestore.firestore().collection("users").document(userID)
                    self.createItem(image: image, price: price, title: title, description: description, owner: owner, category: categoryChoosen)
                    self.createItemWasPressed = true
                }
            } else {
                let alert = UIAlertController(title: "Check Description!", message: "Please describe your item more.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.createItemWasPressed = false
                return
            }
            
            // Navigate back to SearchVC
            let vc = storyboard?.instantiateViewController(withIdentifier: "TabBarController")
            self.present(vc!, animated: false, completion: nil)
        }
        
        
    }
    
    // Create Item object and send its data to Firebase
    func createItem(image: UIImage, price: Int, title: String, description: String, owner: DocumentReference, category: String!) {
        imageUploadManager.uploadImage(image, progressBlock: { (percentage) in
        }, completionBlock: { (fileURL, errorMessage) in
            if let fileURL = fileURL {
                let item = Item(title: title, price: NSNumber(value: price), imageURL: fileURL.absoluteString, owner: owner, itemID: "", category: category, bubble: userBubble, isSold: false)
                var ref: DocumentReference? = nil
                ref = self.collection.addDocument(data: item.dictionary()) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        ref!.updateData(["itemRef": ref!])
                    }
                }
            }
        })
    }
    
    
    
   
}

/*Set the content for the picker view*/
extension CreateItemVC: UIPickerViewDelegate, UIPickerViewDataSource{
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CATEGORIES_LIST.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryChoosen = CATEGORIES_LIST[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CATEGORIES_LIST[row]
    }
}
