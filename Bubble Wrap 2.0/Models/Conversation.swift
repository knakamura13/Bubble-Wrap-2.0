//
//  Conversation.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 7/11/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import FirebaseFirestore

struct Conversation {
    var recipient: DocumentReference!
    var messages: CollectionReference
    var itemID: String!
    
    init?(document: QueryDocumentSnapshot){
        let recipient = document.data()["recipient"] as? DocumentReference
        let messages = document.reference.collection("messages") as CollectionReference
        let docID = document.documentID
        
        self.init(recipient: recipient!, messages: messages, itemID: docID)
    }
    
    init(recipient: DocumentReference!, messages: CollectionReference!, itemID: String!) {
        self.recipient = recipient
        self.messages = messages
        self.itemID = itemID
    }
    
    func dictionary() -> [String: Any] {
        return [
            "recipient": recipient,
            "messages": messages
        ]
    }
}
