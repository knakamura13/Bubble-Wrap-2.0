//
//  ProfileVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Constants
    let cornerRadius = CGFloat(10)
    
    // Variables
    var allItemsNames: [String] = []
    var allItemImages: [UIImage] = []
    
    // Outlets
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var bottomCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topCollectionView.delegate = self
        topCollectionView.dataSource = self
        bottomCollectionView.delegate = self
        bottomCollectionView.dataSource = self
        
        navigationController?.navigationBar.barTintColor = Constants.Colors.appPrimaryColor
        
        allItemsNames = ["Apple Watch (Series 3)", "APU Year Book", "Razer Gaming Mouse", "2017 MacBook Pro", "24\" ASUS Monitor", "Apple Watch (Series 3)", "APU Year Book", "Razer Gaming Mouse", "2017 MacBook Pro", "24\" ASUS Monitor", "Apple Watch (Series 3)", "APU Year Book", "Razer Gaming Mouse", "2017 MacBook Pro", "24\" ASUS Monitor"]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allItemsNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        if collectionView == self.topCollectionView {
            // Populate the top collection view
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "TopProfileCell", for: indexPath as IndexPath) as! TopProfileCell
            cell2.cellImg.image = demoPicsumImages.randomElement()
            cell2.cellLbl.text = allItemsNames[indexPath.item]
            
            // Stylize the cell's imageView
            let rectShape = CAShapeLayer()
            rectShape.bounds = cell2.cellImg.frame
            rectShape.position = cell2.cellImg.center
            rectShape.path = UIBezierPath(roundedRect:  cell2.cellImg.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
            cell2.cellImg.layer.mask = rectShape
            
            cell = cell2
        } else {
            // Populate the bottom collection view
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "BottomProfileCell", for: indexPath as IndexPath) as! BottomProfileCell
            cell2.cellImg.image = demoPicsumImages.randomElement()
            cell2.cellLbl.text = allItemsNames[indexPath.item]
            
            // Stylize the cell's imageView
            let rectShape = CAShapeLayer()
            rectShape.bounds = cell2.cellImg.frame
            rectShape.position = cell2.cellImg.center
            rectShape.path = UIBezierPath(roundedRect:  cell2.cellImg.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
            cell2.cellImg.layer.mask = rectShape
            
            cell = cell2
        }
        
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
    
}
