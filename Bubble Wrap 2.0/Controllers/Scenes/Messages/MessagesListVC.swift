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
    
    
    // MARK: Properties
    
    var allConversations: [Conversation] = []
    var searchConversations: [Conversation] = []
    var allMessageContents: [Message] = []
    var allThumbnails: [UIImage] = []
    var searchThumbnails: [UIImage] = []
    var selectedConversationRecipient: String = ""
    private(set) var datasource = DataSource()  // Datasource for data listener
    
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    // MARK: View load and appear
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = Constants.Colors.appPrimaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        fetchAllConversations()
        // NavBar title color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:Constants.Colors.TextColors.primaryWhite, NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 21)!]
    }
    
    
    // MARK: Custom functions
    
    // Data listener for current user's conversations
    func fetchAllConversations() {
        if let userID = Auth.auth().currentUser?.uid {
            // SELECT * FROM conversations
            let collection = Firestore.firestore().collection("conversations")
            // WHERE
            // (person1.id = userID AND person1.didDelete = false)
            collection
                .whereField("person1.id", isEqualTo: userID)
                .whereField("person1.didDelete", isEqualTo: false)
                .getDocuments { (snapshot, error) in
                if let documents = snapshot?.documents {
                    for document in documents {
                        print(document.data()["person1"])
//                        if let conversation = Conversation(document: document) {
//                            self.allConversations.append(conversation)
//                            self.searchConversations = self.allConversations
//                            self.tableView.reloadData()
//                        }
                    }
                }
            }
            // OR
            // (person2.id = userID AND person2.didDelete = false)
            collection
                .whereField("person2.id", isEqualTo: userID)
                .whereField("person2.didDelete", isEqualTo: false)
                .getDocuments { (snapshot, error) in
                if let documents = snapshot?.documents {
                    for document in documents {
                        if let conversation = Conversation(document: document) {
                            self.allConversations.append(conversation)
                            self.searchConversations = self.allConversations
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: Table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text?.count == 0 {
            searchConversations = allConversations
        }
        
        return searchConversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesCell", for: indexPath as IndexPath) as! MessagesCell
        
        let person1 = searchConversations[indexPath.item].person1
        let person2 = searchConversations[indexPath.item].person2
        
        if Auth.auth().currentUser?.uid == person1!["id"] as! String {
            
        } else if Auth.auth().currentUser?.uid == person2!["id"] as! String {
            
        }
        
        if let recipientRef = searchConversations[indexPath.item].person1 as! DocumentReference {
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
    
    
    // MARK: Search bar
    
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
    
    
    // MARK: Segues and VC loading
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondViewController = segue.destination as! MessengerVC
        secondViewController.conversation = selectedConversation
        secondViewController.title = selectedConversationRecipient
    }
}
