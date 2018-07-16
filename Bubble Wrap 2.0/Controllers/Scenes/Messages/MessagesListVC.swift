//
//  MessagesListVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 7/9/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MessagesListVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var allConversations: [Conversation] = []
    var searchConversations: [Conversation] = []
    var allMessageContents: [Message] = []
    var allThumbnails: [UIImage] = []
    var searchThumbnails: [UIImage] = []
    
    private(set) var datasource = DataSource()  // Datasource for data listener
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAllConversations()
    }
    
    // Data listener for current user's conversations
    func fetchAllConversations() {
        if let userID = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userID).collection("conversations").addSnapshotListener { (snapshot, err) in
                if let documents = snapshot?.documents {
                    for document in documents {
                        let conversation = Conversation(dictionary: document.data(), itemID: document.documentID)
                        self.allConversations.append(conversation!)
                        self.searchConversations.append(conversation!)
                        self.tableView.reloadData()
                        
//                        // Extract all the attributes from each message object
//                        for message in (conversation?.messages)! {
//                            guard let contents = message.value(forKey: "contents") as? String,
//                                let senderIsCurrUser = message.value(forKey: "senderIsCurrUser") as? Bool,
//                                let timeSent = message.value(forKey: "timeSent") as? Timestamp else {
//                                    return
//                            }
//
//                            let newMessage = Message(contents: contents, senderIsCurrUser: senderIsCurrUser, timeSent: timeSent)
//                        }
                    }
                }
            }
        }
    }
    
    /*
     Mark: Table View
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text?.count == 0 {
            searchConversations = allConversations
        }
        
        return searchConversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesCell", for: indexPath as IndexPath) as! MessagesCell
        
        if let recipientRef = searchConversations[indexPath.item].recipient {
            recipientRef.getDocument { (document, error) in
                if let document = document {
                    cell.cellNameLbl.text = document.data()!["firstName"] as? String
//                    cell.cellImageView.image = self.searchThumbnails[indexPath.item]
                    cell.cellImageView.image = demoPicsumImages.randomElement()
                    cell.cellMessageContentsLbl.text = self.searchConversations[indexPath.item].messages[0].value(forKey: "contents") as? String
                    let date = self.searchConversations[indexPath.item].messages[0].value(forKey: "timeSent") as? Date
                    let calendar = Calendar.current
                    let formatter = DateFormatter()
                    formatter.dateFormat = "EEEE"
                    let dayInWeek = formatter.string(from: date!)
                    cell.cellMessageTimeLbl.text = "\(dayInWeek)"
                }
            }
        }
        
        return cell
    }
    
    /*
     MARK: SEARCH BAR
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchConversations = []
        
        for conversation in allConversations {
            for message in conversation.messages {
                if let contents = message.value(forKey: "contents") as? String {
                    if contents.lowercased().contains(searchText.lowercased()) {
                        searchConversations.append(conversation)
                    }
                }
            }
        }
        
        tableView.reloadData()
    }
}
