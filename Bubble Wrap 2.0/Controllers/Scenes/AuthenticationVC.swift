//
//  AuthenticationVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 6/14/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthenticationVC: UIViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailImageView: UIImageView!
    @IBOutlet weak var passwordImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var dividerView1: UIView!
    @IBOutlet weak var dividerView2: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        if let user = Auth.auth().currentUser {
            // Wait for 1/1000th of a second to ensure performSegue is not interrupted
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                self.performSegue(withIdentifier: "authenticatedSegue", sender: nil)
            }
        }
    
        
        logoImageView.image = logoImageView.image!.withRenderingMode(.alwaysTemplate)
        emailImageView.image = emailImageView.image!.withRenderingMode(.alwaysTemplate)
        passwordImageView.image = passwordImageView.image!.withRenderingMode(.alwaysTemplate)
        logoImageView.tintColor = UIColor.white
        emailImageView.tintColor = UIColor.white
        passwordImageView.tintColor = UIColor.white
        signInButton.layer.cornerRadius = 10
        dividerView1.layer.cornerRadius = 0.5
        dividerView2.layer.cornerRadius = dividerView1.layer.cornerRadius
        
        self.hideKeyboardWhenTappedAround() // Hide keyboard on background tap
    }
    
    // Jump from usernameField to passwordField, then hide the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
            self.attemptSignIn()
        }
        return true
    }
    
    // Perform authentication using Firebase
    func attemptSignIn() {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        Auth.auth().signIn(withEmail: email, password: "password") { (result, error) in
            if error != nil {
                // Handle error
            } else {
                self.performSegue(withIdentifier: "authenticatedSegue", sender: nil)
            }
        }
    }
    
    // Actions
    @IBAction func signInPressed(_ sender: Any) {
        attemptSignIn()
    }
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        
    }
}
