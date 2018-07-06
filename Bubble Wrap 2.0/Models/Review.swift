//
//  Review.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 6/20/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import Firebase

struct Review {
    var title: String!
    var reviewer: DocumentReference!
    var item: DocumentReference!
    var bodyText: String!
    
    init?(dictionary: [String: Any]?, itemID: String){
        guard let dictionary = dictionary,
            let title = dictionary["title"] as? String,
            let reviewer = dictionary["reviewer"] as? DocumentReference,
            let item = dictionary["item"] as? DocumentReference,
            let bodyText = dictionary["bodyText"] as? String
            else {
                return nil
        }
        
        self.init(title: title, reviewer: reviewer, item: item, bodyText: bodyText)
    }
    
    init(title: String, reviewer: DocumentReference, item: DocumentReference, bodyText: String) {
        self.title = title
        self.reviewer = reviewer
        self.item = item
        self.bodyText = bodyText
    }
    
    func dictionary() -> [String: Any] {
        return [
            "title": title,
            "reviewer": reviewer,
            "item": item,
            "bodyText": bodyText
        ]
    }
}
