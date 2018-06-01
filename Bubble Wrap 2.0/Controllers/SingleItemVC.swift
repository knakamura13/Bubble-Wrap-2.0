//
//  SingleItemVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/30/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit

class SingleItemVC: UIViewController {

    var selectedItem: String = ""   // variable is set in HomeVC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = selectedItem   // update the title on the nav bar
    }
}
