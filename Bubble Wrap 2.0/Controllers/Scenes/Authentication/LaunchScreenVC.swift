//
//  LaunchScreenVC.swift
//  Bubble Wrap 2.0
//
//  Created by Mario Lopez on 1/14/19.
//  Copyright © 2019 Kyle Nakamura. All rights reserved.
//

import UIKit

class LaunchScreenVC: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Set Background Color
        self.view.backgroundColor = Constants.Colors.appPrimaryColor
        
        // Set Logo Image Styles
        logoImageView.image = logoImageView.image!.withRenderingMode(.alwaysTemplate)
        logoImageView.tintColor = UIColor.white
        
    }

}
