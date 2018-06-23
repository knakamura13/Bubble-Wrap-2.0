//
//  Review.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 6/20/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit

struct Review {
    var title: String!
    var reviewerName: String!
    var itemName: String!
    var bodyText: String!
    
    init?(dictionary: [String: Any]?, itemID: String){
        guard let dictionary = dictionary,
            let title = dictionary["title"] as? String,
            let reviewerName = dictionary["reviewerName"] as? String,
            let itemName = dictionary["itemName"] as? String,
            let bodyText = dictionary["bodyText"] as? String
            else {
                return nil
        }
        
        self.init(title: title, reviewerName: reviewerName, itemName: itemName, bodyText: bodyText)
    }
    
    init(title: String, reviewerName: String, itemName: String, bodyText: String) {
        self.title = title
        self.reviewerName = reviewerName
        self.itemName = itemName
        self.bodyText = bodyText
    }
    
    func dictionary() -> [String: Any] {
        return ["title": title, "reviewerName": reviewerName, "itemName": itemName, "bodyText": bodyText]
    }
}
