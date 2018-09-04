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

/*  TODO:
 *   - Create Message object when chat bubble created       [KYLE]
 *   - Send new Messages to Firebase Firestore              [KYLE]
 */

class MessengerVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    
    // MARK: Properties
    
    var prevChatBubble: UIImageView!
    var conversation: Conversation?
    var allMessages: [Message] = []
    
    
    // MARK: View Load and Appear
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()     // Hide keyboard on background tap
        self.messageTextField.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(with:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(with:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.tableView.contentInset.top = 20
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.scrollToBottom(animated: false)
    }
    
    
    // MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageBubbleCell", for: indexPath as IndexPath) as! MessageBubbleCell
        let message = allMessages[indexPath.row]
        
        // Create an empty chat bubble in the TableView cell
        let newChatBubble = UIImageView()
        let superView = cell.contentView
        superView.addSubview(newChatBubble)
        newChatBubble.translatesAutoresizingMaskIntoConstraints = false

        // Create a label within the bubble, bound to top, right, bottom, left of the cell's container view
        let chatLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 21))
        newChatBubble.addSubview(chatLabel)
        chatLabel.text = message.contents
        chatLabel.textAlignment = .left
        chatLabel.numberOfLines = 5
        chatLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        chatLabel.sizeToFit()
        chatLabel.translatesAutoresizingMaskIntoConstraints = false
        chatLabel.topAnchor.constraint(equalTo: newChatBubble.topAnchor, constant: 12).isActive = true
        chatLabel.leftAnchor.constraint(equalTo: newChatBubble.leftAnchor, constant: 30).isActive = true
        chatLabel.rightAnchor.constraint(equalTo: newChatBubble.rightAnchor, constant: -20).isActive = true
        chatLabel.bottomAnchor.constraint(greaterThanOrEqualTo: newChatBubble.bottomAnchor, constant: -12).isActive = true

        // Randomly switch between sent and received style messages
        if message.senderIsCurrUser {
            switchImage(imageView: newChatBubble, to: "sent")
            chatLabel.textColor = UIColor.white
            chatLabel.leftAnchor.constraint(equalTo: newChatBubble.leftAnchor, constant: 30).isActive = true
            chatLabel.rightAnchor.constraint(equalTo: newChatBubble.rightAnchor, constant: -30).isActive = true
        } else {
            switchImage(imageView: newChatBubble, to: "received")
            chatLabel.textColor = UIColor.black
            chatLabel.leftAnchor.constraint(equalTo: newChatBubble.leftAnchor, constant: 60).isActive = true
            chatLabel.rightAnchor.constraint(equalTo: newChatBubble.rightAnchor, constant: -15).isActive = true
        }
        
        newChatBubble.heightAnchor.constraint(equalToConstant: chatLabel.frame.size.height + CGFloat(30)).isActive = true
        newChatBubble.widthAnchor.constraint(equalToConstant: chatLabel.frame.size.width + CGFloat(100)).isActive = true
        
        superView.heightAnchor.constraint(equalToConstant: chatLabel.frame.size.height + CGFloat(50)).isActive = true
        
        return cell
    }
    
    func scrollToBottom(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let indexPath = NSIndexPath(item: self.allMessages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: animated)
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func sendBtnPressed(_ sender: Any) {
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
        for message in (conversation?.messages)! {
            let contents = message.value(forKey: "contents") as? String ?? ""
            let senderIsCurrentUser = message.value(forKey: "senderIsCurrUser") as? Bool ?? false
            let timeSent = message.value(forKey: "timeSent") as? Date ?? Date()
                
            let newMessage = Message(contents: contents, senderIsCurrUser: senderIsCurrentUser, timeSent: timeSent)
            
            allMessages.append(newMessage)
        }
        
        self.tableView.reloadData()
    }
    
    // Choose either "sent" or "received" for each new chat bubble
    func switchImage(imageView: UIImageView, to type: String) {
        if type == "sent" {
            imageView.image = UIImage(named: "chat_bubble_sent")
            imageView.rightAnchor.constraint(equalTo: imageView.superview!.rightAnchor, constant: -25.0).isActive = true
        } else {
            imageView.image = UIImage(named: "chat_bubble_received")
            imageView.leftAnchor.constraint(equalTo: imageView.superview!.leftAnchor, constant: 25.0).isActive = true
        }
    }
    
    
    // MARK: Keyboard
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.createUserTypedMessage()
        self.messageTextField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardDidShow(with notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject],
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            else {
                return
        }
        
        self.view.frame.origin.y -= (keyboardFrame.height - 50)
        self.tableView.contentInset.top = (keyboardFrame.height - 30)
        self.tableView.contentInset.bottom = (keyboardFrame.height - 30)
        self.scrollToBottom(animated: true)
    }
    
    @objc func keyboardWillHide(with notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject],
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            else {
                return
        }
        
        self.view.frame.origin.y += (keyboardFrame.height - 50)
        self.tableView.contentInset.top = 20
        self.tableView.contentInset.bottom = 0
    }
}
