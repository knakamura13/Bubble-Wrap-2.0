//
//  Conversation.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 7/11/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import FirebaseFirestore

struct Conversation {
    var itemID: String!
    var person1: [String : Any]!
    var person2: [String : Any]!
    var messages: CollectionReference
    
    init?(document: QueryDocumentSnapshot) {
        let person1 = document.data()["person1"] as! [String : Any]
        let person2 = document.data()["person2"] as! [String : Any]
        let messages = document.reference.collection("messages") as CollectionReference
        let docID = document.documentID

        self.init(person1: person1, person2: person2, messages: messages, itemID: docID)
    }

    init(person1: [String : Any], person2: [String : Any], messages: CollectionReference!, itemID: String!) {
        self.person1 = person1
        self.person2 = person2
        self.messages = messages
        self.itemID = itemID
    }
//
//    func dictionary() -> [String: Any] {
//        return [
//            "recipient": recipient,
//            "messages": messages
//        ]
//    }
}
