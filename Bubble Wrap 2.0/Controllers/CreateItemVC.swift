//
//  CreateItemVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import Firebase

class CreateItemVC: UIViewController {
    
    // Constants
    
    // Variables
    
    // Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var smallImg1: UIImageView!
    @IBOutlet weak var smallImg2: UIImageView!
    @IBOutlet weak var smallImg3: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize the visuals
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    // Actions
    
}
