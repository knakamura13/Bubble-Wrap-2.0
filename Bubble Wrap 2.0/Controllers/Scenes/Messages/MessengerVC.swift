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

class MessengerVC: UIViewController, UITextFieldDelegate {
    
    /*  TODO:
     *   - Scroll to bottom when text field is tapped           [MARIO]
     *   - Create Message object when chat bubble created       [KYLE]
     *   - Send new Messages to Firebase Firestore              [KYLE]
    */
    
    // Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContainerView: UIView!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    var prevChatBubble: UIImageView!
    var conversation: Conversation?
    var allMessages: [Message] = []
    var searchMessages: [Message] = []
    
    let bubbleHeightMultiplyer = 100     // Does not account for dynamic bubble sizes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() // Hide keyboard on background tap
        self.messageTextField.delegate = self
        
//        scrollView.contentSize.height = CGFloat(50 * bubbleHeightMultiplyer)
        scrollView.contentSize.height = 800
        print("KYLE \(self.view.frame.size.height)")
//        scrollContainerView.heightAnchor.constraint(equalToConstant: 1800).isActive = true
        messageTextField.layer.borderColor = Constants.Colors.appPrimaryColor.cgColor
        
        // Get recipient's name for nav bar title
        if let recipientRef = conversation?.recipient {
            recipientRef.getDocument { (document, error) in
                if let document = document {
                    self.title = document.data()!["firstName"] as? String
                }
            }
        }
        
        // simulate fetching old messages
        for _ in 1 ... 10 {
            createChatBubbble(message: "HELLO WORLD", timeStamp: Date())   // Single test bubble
        }
        
        // simulate fetching new messages
        fetchAllMessages()
        
        scrollToBottom()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(with:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(with:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardDidShow(with notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject],
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            else {
                return
        }
        
        var contentOffset = self.scrollView.contentOffset
        contentOffset.y += keyboardFrame.height
        
        scrollView.contentOffset = contentOffset
    }
    @objc func keyboardWillHide(with notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject],
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            else {
                return
        }
        
        var contentOffset = self.scrollView.contentOffset
        contentOffset.y -= keyboardFrame.height
        
        scrollView.contentOffset = contentOffset
    }
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        self.createUserTypedMessage()
    }
    
    func createUserTypedMessage() {
        if let messageText = messageTextField.text {
            if messageText.count > 0 {
                createChatBubbble(message: messageText, timeStamp: Date())
            }
        }
        
        messageTextField.text = ""
    }
    
    func fetchAllMessages() {
        // Extract all the attributes from each message object
        for message in (conversation?.messages)! {
            var tmpMessage: Message = Message(contents: "No contents", senderIsCurrUser: false, timeSent: Date())
            
            if let contents = message.value(forKey: "contents") as? String {
                createChatBubbble(message: contents, timeStamp: Date())
                
                if let senderIsCurrUser = message.value(forKey: "senderIsCurrUser") as? Bool {
                    if let timeSent = message.value(forKey: "timeSent") as? Date {
                        tmpMessage = Message(contents: contents, senderIsCurrUser: senderIsCurrUser, timeSent: timeSent)
                    } else {
                        tmpMessage = Message(contents: contents, senderIsCurrUser: senderIsCurrUser, timeSent: Date())
                    }
                } else {
                    tmpMessage = Message(contents: contents, senderIsCurrUser: false, timeSent: Date())
                }
            }
            
            allMessages.append(tmpMessage)
            searchMessages.append(tmpMessage)
        }
    }
    
    // Create a single chat bubble
    func createChatBubbble(message: String, timeStamp: Date) {
        let newChatBubble = UIImageView()
        let superView = scrollContainerView!
        superView.addSubview(newChatBubble)
        newChatBubble.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a label within the bubble, bound to top, right, bottom, left
        let chatLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 21))
        newChatBubble.addSubview(chatLabel)
        chatLabel.text = message
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
        let div2: Bool = Int.random(in: 0 ... 100) % 2 == 0
        let div3: Bool = Int.random(in: 0 ... 100) % 3 == 0
        if div2 || div3 {
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
        
        if prevChatBubble == nil {
            // Anchor new bubble to bottom of scrollViewContainer
            newChatBubble.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: CGFloat(10 * bubbleHeightMultiplyer)).isActive = true
        } else {
            // Anchor new bubble to previous chat bubble.top
            prevChatBubble.bottomAnchor.constraint(equalTo: newChatBubble.topAnchor, constant: -20.0).isActive = true
        }
        
        // Constant width and height, slightly randomized
        newChatBubble.heightAnchor.constraint(equalToConstant: chatLabel.frame.size.height + CGFloat(30)).isActive = true
        newChatBubble.widthAnchor.constraint(equalToConstant: chatLabel.frame.size.width + CGFloat(100)).isActive = true
        
        prevChatBubble = newChatBubble
        
        // Increase content height of scrollView to fit the new message
        self.scrollView.contentSize.height = self.scrollView.contentSize.height + CGFloat(bubbleHeightMultiplyer)
        
        // Scroll back to the bottom after bubble appears
        var offset = scrollView.contentOffset
        offset.y = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.size.height + CGFloat(0)
        scrollView.setContentOffset(offset, animated: true)
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
    
    // Scroll the scrollView to the bottom on page load
    func scrollToBottom() {
        var offset = scrollView.contentOffset
        offset.y = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.size.height + CGFloat(0)
        scrollView.setContentOffset(offset, animated: true)
    }
    
    
    // MARK: TextField
    
    // Jump from usernameField to passwordField, then hide the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.createUserTypedMessage()
        self.messageTextField.resignFirstResponder()
        return true
    }
}