//
//  SingleItemVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/30/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit

class SingleItemVC: UIViewController {

    var itemName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = itemName
    }
}
