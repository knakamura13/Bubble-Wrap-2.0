//
//  MessengerVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging

class MessengerVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textFieldContainerView: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    
    // MARK: Properties
    
    var prevChatBubble: UIImageView!
    var conversation: Conversation?
    var allMessages: [Message] = []
    var isFirstLoad: Bool = true
    
    // MARK: View Load and Appear
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageTextField.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.hideKeyboardWhenTappedAround()     // Hide keyboard on background tap
        
        self.customizeViews()
        
        self.fetchAllMessages()
        
        // Get recipient's name for nav bar title
        if let recipientRef = conversation?.recipient {
            recipientRef.getDocument { (document, error) in
                if let document = document {
                    self.title = document.data()!["firstName"] as? String
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Set up keyboard show-hide notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(with:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(with:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.tableView.contentInset.top = 20
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    
    // Set up the styles for this view
    func customizeViews() {
        self.messageTextField.layer.cornerRadius = 15.0
        self.messageTextField.layer.borderWidth = 1.5
        self.messageTextField.layer.borderColor = UIColor.lightGray.cgColor
        self.messageTextField.clipsToBounds = true
    }
    
    
    // MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageBubbleCell", for: indexPath as IndexPath) as! MessageBubbleCell
        let message = allMessages[indexPath.row]
        
        cell.messageBubble.translatesAutoresizingMaskIntoConstraints = false

        // Create a label within the bubble, bound to top, right, bottom, left of the cell's container view
        cell.messageLbl.text = message.contents
        cell.messageLbl.textAlignment = .left
        cell.messageLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.messageLbl.sizeToFit()
        cell.messageLbl.translatesAutoresizingMaskIntoConstraints = false

        // Randomly switch between sent and received style messages
        if message.senderIsCurrUser {
            // Image should be stuck to right
            switchImage(imageView: cell.messageBubble, to: "sent")
            cell.messageLbl.textColor = UIColor.white
            
            cell.messageLbl.leftAnchor.constraint(equalTo: cell.messageBubble.leftAnchor, constant: 30).isActive = true
            cell.messageLbl.rightAnchor.constraint(equalTo: cell.messageBubble.rightAnchor, constant: -50).isActive = true
            
            cell.messageBubble.leftAnchor.constraint(equalTo: cell.messageBubble.leftAnchor, constant: 50).isActive = true
            cell.messageBubble.rightAnchor.constraint(equalTo: cell.messageBubble.rightAnchor, constant: 0).isActive = true
        } else {
            // Image should be stuck to left
            switchImage(imageView: cell.messageBubble, to: "received")
            cell.messageLbl.textColor = UIColor.black
            
            cell.messageLbl.leftAnchor.constraint(equalTo: cell.messageBubble.leftAnchor, constant: 50).isActive = true
            cell.messageLbl.rightAnchor.constraint(equalTo: cell.messageBubble.rightAnchor, constant: -30).isActive = true
            
            cell.messageBubble.leftAnchor.constraint(equalTo: cell.messageBubble.leftAnchor, constant: 0).isActive = true
            cell.messageBubble.rightAnchor.constraint(equalTo: cell.messageBubble.rightAnchor, constant: -50).isActive = true
        }
        
        cell.messageBubble.heightAnchor.constraint(equalToConstant: cell.messageLbl.frame.size.height + CGFloat(40)).isActive = true
        cell.messageBubble.widthAnchor.constraint(equalToConstant: cell.messageLbl.frame.size.width + CGFloat(50)).isActive = true
        
        return cell
    }
    
    func scrollToBottom(animated: Bool) {
        self.tableView.scrollToRow(at: IndexPath(row: self.allMessages.count - 1, section: 0), at: .bottom, animated: animated)
    }
    
    
    // MARK: Actions
    @IBAction func newSendBtnPressed(_ sender: Any) {
        self.createUserTypedMessage()
    }
    
    
    // MARK: Messages
    
    func createUserTypedMessage() {
        if let messageText = self.messageTextField.text {
            if messageText.count > 0 {
                let newMessage = Message(contents: messageText, senderIsCurrUser: true, timeSent: Date())
                self.allMessages.append(newMessage)
                self.tableView.reloadData()
                
                let ref = Firestore.firestore().collection("users").document((Auth.auth().currentUser?.uid)!).collection("conversations").document((self.conversation?.itemID)!).collection("messages")
                ref.addDocument(data: [
                    "senderIsCurrUser" : true,
                    "contents" : newMessage.contents,
                    "timeSent" : Date()
                ])
            }
        }

        messageTextField.text = ""
    }
    
    func fetchAllMessages() {
        conversation?.messages.order(by: "timeSent", descending: true).limit(to: 5000).addSnapshotListener { (snapshot, err) in
            if let documents = snapshot?.documents {
                self.allMessages.removeAll()
                
                for document in documents {
                    if let newMessage = Message(dictionary: document.data(), itemID: document.documentID) {
                        self.allMessages.append(newMessage)
                    }
                }
                
                self.allMessages.reverse()              // Reverse the messages array to show them in ascending order
                self.tableView.reloadData()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.scrollToBottom(animated: !self.isFirstLoad)
                self.isFirstLoad = false
            })
        }
    }
    
    // Choose either "sent" or "received" for each new chat bubble
    func switchImage(imageView: UIImageView, to type: String) {
        if type == "sent" {
            imageView.image = UIImage(named: "chat_bubble_sent")
        } else {
            imageView.image = UIImage(named: "chat_bubble_received")
        }
    }
    
    
    // MARK: Keyboard
    
    @objc func keyboardWillShow(with notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject],
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            else {
                return
        }
        
        for constraint in self.view.constraints {
            if constraint.identifier == "textFieldContainerViewBottom" {
                constraint.constant = -(keyboardFrame.height - 50)
                self.view.layoutIfNeeded()
            }
        }
        
        self.tableView.scrollToRow(at: IndexPath(row: self.allMessages.count - 1, section: 0), at: .top, animated: false)
    }
    
    @objc func keyboardWillHide(with notification: Notification) {
        for constraint in self.view.constraints {
            if constraint.identifier == "textFieldContainerViewBottom" {
                constraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension MessengerVC {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = Constants.Colors.appPrimaryColor.cgColor
        textField.layer.borderWidth = 3.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1.5
    }
    
//    // If keyboard is shown move the view up to show text and the rest of the view
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBEndUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y == 0{
//                self.view.frame.origin.y -= keyboardSize.height
//            }
//        }
//    }
//
//    // Put view and rest of keyboard shown back to normal without keyboard
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y == 0{
//                self.view.frame.origin.y -= keyboardSize.height
//            }
//        }
//    }
    @objc
    func keyboardWillShowNotification(_ notification: NSNotification) {}
    
    @objc
    func keyboardWillHideNotification(_ notification: NSNotification) {}
}
