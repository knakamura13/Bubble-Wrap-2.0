//
//  Message.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 7/11/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import Firebase

struct Message {
    var contents: String!
    var senderIsCurrUser: Bool!
    var timeSent: Date!
    
    init?(dictionary: [String: Any]?, itemID: String){
        guard let dictionary = dictionary,
            let contents = dictionary["contents"] as? String,
            let senderIsCurrUser = dictionary["senderIsCurrUser"] as? Bool,
            let timeSent = dictionary["timeSent"] as? Date
            else {
                return nil
        }
        
        self.init(contents: contents, senderIsCurrUser: senderIsCurrUser, timeSent: timeSent)
    }
    
    init(contents: String, senderIsCurrUser: Bool, timeSent: Date) {
        self.contents = contents
        self.senderIsCurrUser = senderIsCurrUser
        self.timeSent = timeSent
    }
    
    func dictionary() -> [String: Any] {
        return [
            "contents": contents,
            "senderIsCurrUser": senderIsCurrUser,
            "timeSent": timeSent
        ]
    }
}
