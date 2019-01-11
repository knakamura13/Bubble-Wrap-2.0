//
//  AuthenticationVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 6/14/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

var userBubble: String!
var userEmail: String!
var userPassword: String!
var userLastName: String!
var userFirstName: String!
var userRating: Double!
var userItemsSold: Int!
var userFollowers: Int!
var userProfileImageURL: String!

class AuthenticationVC: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    // Image Views
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailImageView: UIImageView!
    @IBOutlet weak var passwordImageView: UIImageView!
    @IBOutlet weak var confirmPasswordImageView: UIImageView!
    // Text Fields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    // Buttons
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    // Misc Views
    @IBOutlet weak var dividerView1: UIView!
    @IBOutlet weak var dividerView2: UIView!
    @IBOutlet weak var dividerView3: UIView!
    // Stack Views
    @IBOutlet weak var textFieldsStackView: UIStackView!
    @IBOutlet weak var confirmPasswordStackView: UIStackView!
    
    // MARK: Variables
    var firstTime = false // Checks whether to perfrom segue or not when `getUserInformation` is ran
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        firstTime = true
        if Auth.auth().currentUser != nil {
            DispatchQueue.main.async {
                self.getUserInformation()
            }
            
        }
        
        self.setupStyles()
    }
    
    func setupStyles() {
        logoImageView.image = logoImageView.image!.withRenderingMode(.alwaysTemplate)
        emailImageView.image = emailImageView.image!.withRenderingMode(.alwaysTemplate)
        passwordImageView.image = passwordImageView.image!.withRenderingMode(.alwaysTemplate)
        confirmPasswordImageView.image = confirmPasswordImageView.image!.withRenderingMode(.alwaysTemplate)
        logoImageView.tintColor = UIColor.white
        emailImageView.tintColor = UIColor.white
        passwordImageView.tintColor = UIColor.white
        confirmPasswordImageView.tintColor = UIColor.white
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
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
            if confirmPasswordStackView.isHidden {
                passwordTextField.resignFirstResponder()
                self.attemptSignIn()
            } else {
                if textField == passwordTextField {
                    confirmPasswordTextField.becomeFirstResponder()
                } else {
                    confirmPasswordTextField.resignFirstResponder()
                    self.attemptSignIn()
                }
            }
        }
        return true
    }
    
    // Perform authentication using Firebase
    func attemptSignIn() {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        if confirmPasswordStackView.isHidden {
            // Sign in existing user
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Invalid Login", message: "Your username or password is wrong.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alert, animated: true)
                } else {
                    self.getUserInformation()
                    
                    if Auth.auth().currentUser?.isEmailVerified ?? false || Auth.auth().currentUser?.email == "test@apu.edu" /* FOR TESTING PURPOSES */ {
                        self.performSegue(withIdentifier: "authenticatedSegue", sender: nil) 
                    } else {
                        // Passwords to not match, so alert user to try again
                        let alert = UIAlertController(title: "Are you human...", message: "Or are you dancer? \n\nPlease verify your email and try again.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Okay :(", style: .default) {
                            UIAlertAction in
                        }
                        alert.addAction(action)
                        self.present(alert, animated: true)
                    }
                }
            }
        } else {
            // Check if email contains a valid .edu domain
            var validDomain = false
            for (domain, _) in EXISTING_BUBBBLE_COMMUNITIES {
                if email.contains(domain) {
                    validDomain = true
                }
            }
            if !validDomain {
                let alert = UIAlertController(title: "Sorry!", message: "You need a valid .edu email address to use Bubble Wrap.", preferredStyle: .alert)
                let action = UIAlertAction(title: "Okay", style: .default) {
                    UIAlertAction in
                    self.emailTextField.text = ""  // Clear the confirmPassword field
                }
                alert.addAction(action)
                self.present(alert, animated: true)
                return
            }
            
            // Verify passwords match and create a new user
            guard let confirmPassword = confirmPasswordTextField.text else { return }
            if password == confirmPassword {
                if password.count < 8 {
                    let alert = UIAlertController(title: "You can do better than that!", message: "Your password must be at least 8 characters long.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Okay", style: .default) {
                        UIAlertAction in
                        
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true)
                    
                    return
                } else if password.lowercased().contains("password") {
                    let alert = UIAlertController(title: "Hey, it's not a race.", message: "Try coming up with a more... sophisticated password. You can't use the word \"password\" in your password.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Okay", style: .default) {
                        UIAlertAction in
                        
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true)
                    
                    return
                } else if password.isEmptyOrWhitespace() {
                    let alert = UIAlertController(title: "Hey, it's not a race.", message: "Try coming up with a more... sophisticated password. You can't only use white spaces.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Okay", style: .default) {
                        UIAlertAction in
                        
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true)
                    
                    return
                }
                
                userEmail = email
                userPassword = password
                self.performSegue(withIdentifier: "segueToNewUserInformation", sender: nil)
                
            } else {
                // Passwords to not match, so alert user to try again
                let alert = UIAlertController(title: "Try that again", message: "Your passwords do not match.", preferredStyle: .alert)
                let action = UIAlertAction(title: "Okay", style: .default) {
                    UIAlertAction in
                    self.confirmPasswordTextField.text = ""  // Clear the confirmPassword field
                }
                alert.addAction(action)
                
                self.present(alert, animated: true)
            }
        }
    }
    
    
    // Load current user's profile information from Firebase and store in UserDeults
    func getUserInformation() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let uid = Auth.auth().currentUser?.uid  {
                let userDocument = Firestore.firestore().collection("users").document(uid)
                userDocument.getDocument { (document, error) in
                    if let document = document {
                        if document.data() != nil {
                            if let user = User(dictionary: document.data()!, itemID: document.documentID) {
                                userBubble = user.bubbleCommunity // Set the user's bubble community for the app
                                userLastName = user.lastName
                                userFirstName = user.firstName
                                userRating = user.rating
                                userItemsSold = user.itemsSold
                                userFollowers = user.followers
                                userProfileImageURL = user.profileImageURL
                                // Runs 'emailVerifcation()' when app is opened
                                if self.firstTime == true {
                                    self.emailVerification()
                                    self.firstTime = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func emailVerification(){
        if Auth.auth().currentUser?.isEmailVerified ?? false || Auth.auth().currentUser?.email == "test@apu.edu" /* FOR TESTING PURPOSES */ {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "authenticatedSegue", sender: self)
            }
            //performSegue(withIdentifier: "authenticatedSegue", sender: nil)
        } else {
            // Passwords to not match, so alert user to try again
            let alert = UIAlertController(title: "Are you human...", message: "Or are you dancer? \n\nPlease verify your email and try signing in again.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay :(", style: .default) {
                UIAlertAction in
                self.emailTextField.text = Auth.auth().currentUser?.email
            }
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
    
    // Actions
    @IBAction func signInPressed(_ sender: Any) {
        attemptSignIn()
    }
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        if confirmPasswordStackView.isHidden {
            signUpBtn.setTitle("Already have an account? Sign in", for: .normal)
            signInButton.setTitle("Sign up", for: .normal)
        } else {
            signUpBtn.setTitle("Don't have an account? Sign up", for: .normal)
            signInButton.setTitle("Sign in", for: .normal)
        }
        
        confirmPasswordStackView.isHidden.toggle()
    }
}

extension String {
    func isEmptyOrWhitespace() -> Bool {
        
        // Check empty string
        if self.isEmpty {
            return true
        }
        // Trim and check empty string
        return (self.trimmingCharacters(in: .whitespaces) == "")
    }
}
