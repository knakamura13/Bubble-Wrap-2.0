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
                }
            }
        }
        
        //cell.cellImageView.image = self.searchThumbnails[indexPath.item]
        cell.cellImageView.image = demoPicsumImages.randomElement()
        cell.cellMessageContentsLbl.text = self.searchConversations[indexPath.item].messages[0].value(forKey: "contents") as? String
        let date = self.searchConversations[indexPath.item].messages[0].value(forKey: "timeSent") as? Date
        let weekDayFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        weekDayFormatter.dateFormat = "EEEE"    // Format Date() object as weekday name, i.e. "Monday"
        timeFormatter.dateFormat = "h:mm a"     // Format Date() object as time with period, i.e. "8:15 PM"
        timeFormatter.amSymbol = "AM"
        timeFormatter.pmSymbol = "PM"
        
        var timeLbl = ""
        let dayInWeek = weekDayFormatter.string(from: date!)
        if dayInWeek == weekDayFormatter.string(from: Date()) {
            timeLbl = timeFormatter.string(from: date!)
        } else {
            timeLbl = dayInWeek
        }
        cell.cellMessageTimeLbl.text = "\(timeLbl)"
        
        return cell
    }
    
    /*
     MARK: SEARCH BAR
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchConversations = []
        
        for conversation in allConversations {
            if let recipientRef = conversation.recipient {
                recipientRef.getDocument { (document, error) in
                    if let document = document {
                        let name = document.data()!["firstName"] as? String
                        if (name?.lowercased().contains(searchText.lowercased()))! {
                            self.searchConversations.append(conversation)
                        }
                    }
                }
            }
        }
        
        tableView.reloadData()
    }
}
