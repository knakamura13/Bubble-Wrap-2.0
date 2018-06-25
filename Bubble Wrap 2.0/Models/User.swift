//
//  User.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 6/24/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit

struct User {
    var firstName: String!
    var lastName: String!
    var profileImageURL: String!
    var bubbleCommunity: String!
    var rating: Double!
    var itemsSold: Int!
    var followers: Int!
    
    init?(dictionary: [String: Any]?, itemID: String) {
        guard let dictionary = dictionary,
            let firstName = dictionary["firstName"] as? String,
            let lastName = dictionary["lastName"] as? String,
            let profileImageURL = dictionary["profileImageURL"] as? String,
            let bubbleCommunity = dictionary["bubbleCommunity"] as? String,
            let rating = dictionary["rating"] as? Double,
            let itemsSold = dictionary["itemsSold"] as? Int,
            let followers = dictionary["followers"] as? Int
            else {
                return nil
        }
        
        self.init(firstName: firstName, lastName: lastName, profileImageURL: profileImageURL, bubbleCommunity: bubbleCommunity, rating: rating, itemsSold: itemsSold, followers: followers)
    }
    
    init(firstName: String?, lastName: String?, profileImageURL: String?, bubbleCommunity: String?, rating: Double?, itemsSold: Int?, followers: Int?) {
        self.firstName = firstName
        self.lastName = lastName
        self.profileImageURL = profileImageURL
        self.bubbleCommunity = bubbleCommunity
        self.rating = rating
        self.itemsSold = itemsSold
        self.followers = followers
    }
    
    func dictionary() -> [String: Any] {
        return ["firstName": firstName, "lastName": lastName, "profileImageURL": profileImageURL, "bubbleCommunity": bubbleCommunity, "rating": rating, "itemsSold": itemsSold, "followers": followers]
    }
}
