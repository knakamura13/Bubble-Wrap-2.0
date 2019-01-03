//
//  MessengerVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
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
    
    
    
    // MARK: View loading and appearing
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageTextField.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.hideKeyboardWhenTappedAround()
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
        
        guard let recipientRef = conversation?.recipient else { return }
        recipientRef.getDocument { (document, error) in
            guard let document = document else { return }
            self.title = document.data()!["firstName"] as? String
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
        // NavBar title color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:Constants.Colors.TextColors.primaryWhite, NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 21)!]
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
        
        // Create a label within the bubble, bound to top, right, bottom, left of the cell's container view
        cell.messageLbl.text = message.contents
        cell.messageLbl.lineBreakMode = NSLineBreakMode.byWordWrapping

        if message.senderIsCurrUser {
            // Text should be stuck to right
            cell.messageLbl.textColor = UIColor.white
            cell.messageLbl.textAlignment = .right
            cell.containerView.backgroundColor = UIColor.init(hex: 0x00a4db)
        } else {
            // Text should be stuck to left
            cell.messageLbl.textColor = UIColor.black
            cell.messageLbl.textAlignment = .left
            cell.containerView.backgroundColor = UIColor.init(hex: 0xe0e0e0)
        }
        
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
                
                // Reverse the messages array to show them in ascending order
                self.allMessages.reverse()
                
                // Reload the interface
                self.tableView.reloadData()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.scrollToBottom(animated: !self.isFirstLoad)
                self.isFirstLoad = false
            })
        }
    }
    
    
    
    // MARK: Keyboard
    
    @objc func keyboardWillShow(with notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject],
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else {
                return
        }
        
        for constraint in self.view.constraints {
            if constraint.identifier == "textFieldContainerViewBottom" {
                constraint.constant = 80 - keyboardFrame.height
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



// MARK: Class Extensions

extension MessengerVC {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = Constants.Colors.appPrimaryColor.cgColor
        textField.layer.borderWidth = 3.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1.5
    }
    
    @objc func keyboardWillShowNotification(_ notification: NSNotification) {}
    
    @objc func keyboardWillHideNotification(_ notification: NSNotification) {}
}
