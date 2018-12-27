//
//  Offer.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 6/26/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//


import FirebaseFirestore

struct Offer {
    var price: Int!
    var item: DocumentReference!
    var creator: DocumentReference!
    var recipient: DocumentReference!
    var bubble: String!
    
    init?(dictionary: [String: Any]?, itemID: String){
        guard let dictionary = dictionary,
            let price = dictionary["price"] as? Int,
            let item = dictionary["item"] as? DocumentReference,
            let creator = dictionary["creator"] as? DocumentReference,
            let recipient = dictionary["recipient"] as? DocumentReference,
            let bubble = dictionary["bubble"] as? String
            else {
                return nil
        }
        
        self.init(price: price, item: item, creator: creator, recipient: recipient, bubble: bubble)
    }
    
    init(price: Int, item: DocumentReference, creator: DocumentReference, recipient: DocumentReference, bubble: String) {
        self.price = price
        self.item = item
        self.creator = creator
        self.recipient = recipient
        self.bubble = bubble
    }
    
    func dictionary() -> [String: Any] {
        return [
            "price": price,
            "item": item,
            "creator": creator,
            "recipient": recipient,
            "bubble": bubble,
        ]
    }
}
