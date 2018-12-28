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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        if let uid = Auth.auth().currentUser?.uid  {
            print("CHECK: AUTH userBubble before set")
            let userDocument = Firestore.firestore().collection("users").document(uid)
            userDocument.getDocument { (document, error) in
                if let document = document {
                    if document.data() != nil {
                        if let user = User(dictionary: document.data()!, itemID: document.documentID) {
                            print("CHECK: AUTH userBubble set")
                            userBubble = user.bubbleCommunity
                            print("CHECK USERBUBBLE: \(userBubble)")
                        }
                    }
                }
            }
        }
        if Auth.auth().currentUser != nil {
            print("CHECK: Start getinfo()")
            self.getUserInformation()
            // Wait for 1/1000th of a second to ensure performSegue is not interrupted
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                if Auth.auth().currentUser?.isEmailVerified ?? false || Auth.auth().currentUser?.email == "test@apu.edu" /* FOR TESTING PURPOSES */ {
                    print("CHECK: Move from getinfo()")
                    self.performSegue(withIdentifier: "authenticatedSegue", sender: nil)
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
                
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    if error != nil {
                        // Handle error
                    } else {
                        let email = email
                        self.createUser(email: email)
                        self.sendEmailVerification()
                        self.getUserInformation()
                        self.performSegue(withIdentifier: "segueToNewUserInformation", sender: nil)
                        
                    }
                }
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
    
    func sendEmailVerification() {
        Auth.auth().currentUser?.sendEmailVerification { (error) in
            if error != nil {
                // Handle error
            }
        }
    }
    
    // Create User object and send its data to Firebase
    func createUser(email: String) {
        for (domain, university) in EXISTING_BUBBBLE_COMMUNITIES {
            if email.contains(domain) {
                userBubble = university
            }
        }
        let user = User(firstName: "", lastName: "", profileImageURL: "", bubbleCommunity: userBubble, rating: 0, itemsSold: 0, followers: 0, offersCreated: nil, offersReceived: nil)
        let data = user.dictionary()
        if let uid = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(uid).setData(data)
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
                                UserDefaults.standard.set(user.firstName, forKey: "firstName")
                                UserDefaults.standard.set(user.lastName, forKey: "lastName")
                                UserDefaults.standard.set(user.bubbleCommunity, forKey: "bubbleCommunity")
                                UserDefaults.standard.set(user.rating, forKey: "rating")
                                UserDefaults.standard.set(user.itemsSold, forKey: "itemsSold")
                                UserDefaults.standard.set(user.followers, forKey: "followers")
                                UserDefaults.standard.set(user.profileImageURL, forKey: "profileImgURL")
                            }
                        }
                    }
                }
            }
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
