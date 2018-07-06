//
//  Item.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 6/15/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit

struct Item {
    var title: String!
    var price: NSNumber!
    var image: UIImage?
    var imageURL: String!
    
    init?(dictionary: [String: Any]?, itemID: String){
        guard let dictionary = dictionary,
            let title = dictionary["title"] as? String,
            let price = dictionary["price"] as? NSNumber,
            let imageURL = dictionary["imageURL"] as? String
        else {
            return nil
        }
        
        self.init(title: title, price: price, imageURL: imageURL)
    }
    
    init(title: String?, price: NSNumber, imageURL: String) {
        self.title = title
        self.price = price
        self.imageURL = imageURL
    }
    
    func dictionary() -> [String: Any] {
        return [
            "title": title,
            "price": price,
            "imageURL": imageURL
        ]
    }
}
