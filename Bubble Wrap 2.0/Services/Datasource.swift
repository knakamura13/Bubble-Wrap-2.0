//
//  Datasource.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 6/15/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import FirebaseFirestore

class DataSource: NSObject {
    func generalQuery(collection: String, orderBy: String, limit: Int?) -> Query {
        if let lim = limit {
            return Firestore.firestore().collection(collection).whereField("bubble", isEqualTo: userBubble).order(by: orderBy).limit(to: lim)
        }
        return Firestore.firestore().collection(collection).whereField("bubble", isEqualTo: userBubble).order(by: orderBy)
    }
    
}
