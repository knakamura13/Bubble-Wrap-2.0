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

class ProfileVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    
    // Constants
    let cornerRadius = CGFloat(10)
    
    // Variables
    var allItemsNames: [String] = []
    var allItemImages: [UIImage] = []
    
    // Outlets
    @IBOutlet weak var signOutBtn: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var profileImgView: UIControl!
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var userEmailField: UITextField!
    @IBOutlet weak var userBubbleField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topCollectionView.delegate = self
        topCollectionView.dataSource = self
        userNameField.delegate = self
        userEmailField.delegate = self
        
        // Customize visuals
        signOutBtn.tintColor = Constants.Colors.TextColors.secondaryBlack
        scrollView.contentSize.height = 800
        navigationController?.navigationBar.barTintColor = Constants.Colors.appPrimaryColor
        profileImgView.layer.cornerRadius = CGFloat(self.profileImgView.frame.width/2)
        self.hideKeyboardWhenTappedAround() // Hide keyboard on background tap
        
        // Set the initial data
        allItemsNames = ["Apple Watch (Series 3)", "APU Year Book", "Razer Gaming Mouse", "2017 MacBook Pro", "24\" ASUS Monitor", "Apple Watch (Series 3)", "APU Year Book", "Razer Gaming Mouse", "2017 MacBook Pro", "24\" ASUS Monitor", "Apple Watch (Series 3)", "APU Year Book", "Razer Gaming Mouse", "2017 MacBook Pro", "24\" ASUS Monitor"]
        userNameField.text = "Kyle Nakamura"
        userEmailField.text = "knakamura13@apu.edu"
        userBubbleField.text = "Azusa Pacific University"
    }
    
    // Jump from userName to userEmail, then hide the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameField {
            userEmailField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allItemsNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Populate the collection view cells
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopProfileCell", for: indexPath as IndexPath) as! TopProfileCell
        cell.cellImg.image = demoPicsumImages.randomElement()
        cell.cellLbl.text = allItemsNames[indexPath.item]
        
        // Stylize the cell's imageView
        let rectShape = CAShapeLayer()
        rectShape.bounds = cell.cellImg.frame
        rectShape.position = cell.cellImg.center
        rectShape.path = UIBezierPath(roundedRect:  cell.cellImg.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        cell.cellImg.layer.mask = rectShape
        
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
    
    // Actions
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
        
    }
}
