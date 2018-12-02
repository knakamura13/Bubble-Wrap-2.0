//
//  Item.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 6/15/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import FirebaseFirestore

struct Item {
    var title: String!
    var price: NSNumber!
    var image: UIImage?
    var imageURL: String!
    var owner: DocumentReference?
    var itemID: String!
    
    init?(dictionary: [String: Any]?, itemID: String){
        guard let dictionary = dictionary,
            let title = dictionary["title"] as? String,
            let price = dictionary["price"] as? NSNumber,
            let imageURL = dictionary["imageURL"] as? String,
            let owner = dictionary["owner"] as? DocumentReference
        else {
            return nil
        }
        
        self.init(title: title, price: price, imageURL: imageURL, owner: owner, itemID: itemID)
        
    }
    
    init(title: String?, price: NSNumber, imageURL: String, owner: DocumentReference?, itemID: String) {
        self.title = title
        self.price = price
        self.imageURL = imageURL
        if owner != nil {
            self.owner = owner!
        }
        self.itemID = itemID
    }

    
    func dictionary() -> [String: Any] {
        return [
            "title": title,
            "price": price,
            "imageURL": imageURL,
            "owner": owner as Any
        ]
    }
}
