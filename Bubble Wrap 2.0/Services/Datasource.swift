//
//  Datasource.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 6/15/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import Foundation
import FirebaseFirestore

class DataSource: NSObject {
    func itemsQuery() -> Query {
        return Firestore.firestore().collection("items").limit(to: 100).order(by: "title")
    }
    
    override init() {
        super.init()
        
        for i in 1...100 {
            if let image = UIImage(named: "picsum-\(i)") {
                demoPicsumImages.append(image)
            }
        }
    }
}
