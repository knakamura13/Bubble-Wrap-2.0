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

var selectedConversation: Conversation?

class MessagesListVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var allConversations: [Conversation] = []
    var searchConversations: [Conversation] = []
    var allMessageContents: [Message] = []
    var allThumbnails: [UIImage] = []
    var searchThumbnails: [UIImage] = []
    var selectedConversationRecipient: String = ""
    
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
                        let conversation = Conversation(document: document)
                        self.allConversations.append(conversation!)
                        self.searchConversations = self.allConversations
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
                    
                    // Asynchonously set profile image
                    DispatchQueue.main.async(execute: {
                        if let imgURL = URL(string: document.data()!["profileImageURL"] as! String) {
                            let data = try? Data(contentsOf: imgURL)
                            if let imageData = data {
                                let image = UIImage(data: imageData)
                                globalProfilePicture = image!
                                cell.cellImageView.image = image
                            }
                        }
                    })
                }
            }
        }
        
        cell.cellImageViewContainer.layer.cornerRadius = 5
        cell.cellMessageContentsLbl.text = ""
        let date = Date()
        let weekDayFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        weekDayFormatter.dateFormat = "EEEE"    // Format Date() object as weekday name, i.e. "Monday"
        timeFormatter.dateFormat = "h:mm a"     // Format Date() object as time with period, i.e. "8:15 PM"
        timeFormatter.amSymbol = "AM"
        timeFormatter.pmSymbol = "PM"
        
        var timeLbl = ""
        let dayInWeek = weekDayFormatter.string(from: date)
        if dayInWeek == weekDayFormatter.string(from: Date()) {
            timeLbl = timeFormatter.string(from: date)
        } else {
            timeLbl = dayInWeek
        }
        cell.cellMessageTimeLbl.text = "\(timeLbl)"
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedConversation = searchConversations[indexPath.row]
        
        if let recipientRef = selectedConversation?.recipient {
            recipientRef.getDocument { (document, error) in
                if let document = document {
                    let name = document.data()!["firstName"] as? String
                    self.selectedConversationRecipient = name ?? ""
                }
            }
        }
        
        performSegue(withIdentifier: "messengerSegue", sender: nil)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondViewController = segue.destination as! MessengerVC
        secondViewController.conversation = selectedConversation
        secondViewController.title = selectedConversationRecipient
    }
}
