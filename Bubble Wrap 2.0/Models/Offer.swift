//
//  Offer.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 6/26/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import Firebase

struct Offer {
    var price: Int!
    var item: DocumentReference!
    var creator: DocumentReference!
    var recipient: DocumentReference!
    
    init?(dictionary: [String: Any]?, itemID: String){
        guard let dictionary = dictionary,
            let price = dictionary["price"] as? Int,
            let item = dictionary["item"] as? DocumentReference,
            let creator = dictionary["creator"] as? DocumentReference,
            let recipient = dictionary["recipient"] as? DocumentReference
            else {
                return nil
        }
        
        self.init(price: price, item: item, creator: creator, recipient: recipient)
    }
    
    init(price: Int, item: DocumentReference, creator: DocumentReference, recipient: DocumentReference) {
        self.price = price
        self.item = item
        self.creator = creator
        self.recipient = recipient
    }
    
    func dictionary() -> [String: Any] {
        return [
            "price": price,
            "item": item,
            "creator": creator,
            "recipient": recipient
        ]
    }
}
