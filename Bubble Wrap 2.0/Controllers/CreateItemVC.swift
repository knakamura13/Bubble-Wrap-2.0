//
//  CreateItemVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import Firebase

class CreateItemVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // Constants
    
    // Variables
    
    // Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var smallImg1: UIImageView!
    @IBOutlet weak var smallImg2: UIImageView!
    @IBOutlet weak var smallImg3: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        priceTextField.delegate = self
        descriptionTextView.delegate = self
        
        // Customize the visuals
        navigationController?.navigationBar.barTintColor = Constants.Colors.appPrimaryColor
        scrollView.contentSize.height = 1000 // arbitrary integer; increase if content does not fit in contentSize
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
        
        self.hideKeyboardWhenTappedAround() // Hide keyboard on background tap
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    // Jump from usernameField to passwordField, then hide the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            priceTextField.becomeFirstResponder()
        } else if textField == priceTextField {
            descriptionTextView.becomeFirstResponder()
        } else {
            resignFirstResponder()
        }
        return true
    }
    
    // Actions
    
}
