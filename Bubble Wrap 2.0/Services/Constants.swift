//
//  Constants.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import Foundation
import UIKit

var demoPicsumImages: [UIImage] = []

struct Constants {
    struct Colors {
        static let appPrimaryColor =  UIColor(red: 99/255, green: 213/255, blue: 255/255, alpha: Alphas.Opaque)  // Bubble Blue
        static let appSecondaryColor =  UIColor.blue.withAlphaComponent(Alphas.Opaque)                           // Transparent Blue
        
        private struct Alphas {
            static let Opaque = CGFloat(1)
            static let SemiOpaque = CGFloat(0.85)
            static let SemiTransparent = CGFloat(0.50)
            static let Transparent = CGFloat(0.30)
        }
        
        struct TextColors {
            static let primaryBlack = UIColor.black.withAlphaComponent(Alphas.SemiOpaque)
            static let secondaryBlack = UIColor.black.withAlphaComponent(Alphas.SemiTransparent)
            static let primaryWhite = UIColor.white
            static let secondaryWhite = UIColor.white.withAlphaComponent(Alphas.SemiOpaque)
        }
        
        struct TabBarColors{
            static let Selected = UIColor.white
            static let NotSelected = appPrimaryColor
        }
    }
}
