//
//  CreateItemVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit

class CreateItemVC: UIViewController {
    
    // Constants
    
    // Variables
    
    // Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        navigationController?.navigationBar.barTintColor = Constants.Colors.appPrimaryColor
        scrollView.contentSize.height = 750 // arbitrary integer; increase value if content does not fit on screen
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    // Actions
    
}
