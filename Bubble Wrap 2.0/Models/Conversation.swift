//
//  Conversation.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 7/11/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import Foundation
import Firebase

struct Conversation {
    var recipient: DocumentReference!
    var messages: [NSObject]!
    
    init?(dictionary: [String: Any]?, itemID: String){
        guard let dictionary = dictionary,
            let recipient = dictionary["recipient"] as? DocumentReference,
            let messages = dictionary["messages"] as? [NSObject]
            else {
                return nil
        }
        
        self.init(recipient: recipient, messages: messages)
    }
    
    init(recipient: DocumentReference!, messages: [NSObject]) {
        self.recipient = recipient
        self.messages = messages
    }
    
    func dictionary() -> [String: Any] {
        return [
            "recipient": recipient,
            "messages": messages
        ]
    }
}
