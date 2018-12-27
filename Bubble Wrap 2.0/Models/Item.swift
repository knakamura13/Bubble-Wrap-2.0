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
    var category: String!
    var price: NSNumber!
    var image: UIImage?
    var imageURL: String!
    var owner: DocumentReference?
    var bubble: String!
    var isSold: Bool!
    var itemID: String!
    
    
    init?(dictionary: [String: Any]?, itemID: String){
        guard let dictionary = dictionary,
            let title = dictionary["title"] as? String,
            let price = dictionary["price"] as? NSNumber,
            let imageURL = dictionary["imageURL"] as? String,
            let owner = dictionary["owner"] as? DocumentReference,
            let category = dictionary["category"] as? String,
            let bubble = dictionary["bubble"] as? String,
            let isSold = dictionary["isSold"] as? Bool
            else {
                return nil
        }
        
        self.init(title: title, price: price, imageURL: imageURL, owner: owner, itemID: itemID, category: category, bubble: bubble, isSold: isSold)
        
    }
    
    init(title: String?, price: NSNumber, imageURL: String, owner: DocumentReference?, itemID: String, category: String, bubble: String, isSold: Bool) {
        self.title = title
        self.price = price
        self.imageURL = imageURL
        if owner != nil {
            self.owner = owner!
        }
        self.itemID = itemID
        self.category = category
        self.bubble = bubble
        self.isSold = isSold
    }
    
    
    func dictionary() -> [String: Any] {
        return [
            "title": title,
            "price": price,
            "imageURL": imageURL,
            "owner": owner,
            "category": category,
            "bubble": bubble,
            "isSold": isSold,
        ]
    }
}
