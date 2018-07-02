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

class MessengerVC: UIViewController {
    
    //
    /*  TODO:
     *   - Set self.title to user name of recipient.
     *   - Create a function that adds a single chat bubble given a String and time stamp.
     *   - Move the view upwards when keyboard is shown.
     *   - Scroll to bottom when text field is tapped.
     *   - Set keyboard return key to create a new message.
     *   - Fix slightly off-set scrollToBottom function
     *   - Implement FirebaseMessaging?
    */
    
    // Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContainerView: UIView!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    var prevChatBubble: UIImageView!
    
    let numBubbles = 50
    let bubbleHeightMultiplyer = 87     // Does not account for dynamic bubble sizes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() // Hide keyboard on background tap
        scrollView.contentSize.height = CGFloat(numBubbles * bubbleHeightMultiplyer)
        
        displayTestMessages()
        scrollToBottom()
    }
    
    // Layout a series of test messages
    func displayTestMessages() {
        for _ in 1 ... numBubbles {
            createChatBubbble()
        }
    }
    
    // Create a single chat bubble
    func createChatBubbble() {
        let newChatBubble = UIImageView()
        let superView = scrollContainerView!
        superView.addSubview(newChatBubble)
        newChatBubble.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a label within the bubble, bound to top, right, bottom, left
        let chatLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 21))
        newChatBubble.addSubview(chatLabel)
        chatLabel.textAlignment = .left
        chatLabel.text = ["Random text.",
                          "Some text and more text.",
                          "Let's try something a bit longer this time.",
                          "This is a really long string of text, perhaps three or four lines long, that will test the limits of this feature."].randomElement()
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
        
        if prevChatBubble != nil {
            // Anchor new bubble to previous chat bubble.top
            newChatBubble.bottomAnchor.constraint(equalTo: prevChatBubble.topAnchor, constant: -20.0).isActive = true
        } else {
            // Anchor new bubble to bottom of scrollViewContainer
            newChatBubble.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: CGFloat(numBubbles * bubbleHeightMultiplyer)).isActive = true
        }
        
        // Constant width and height, slightly randomized
        let randHeight = CGFloat.random(in: 50 ... 80)
        let randWidth = CGFloat.random(in: 150 ... 200)
        newChatBubble.heightAnchor.constraint(equalToConstant: chatLabel.frame.size.height + CGFloat(30)).isActive = true
        newChatBubble.widthAnchor.constraint(equalToConstant: chatLabel.frame.size.width + CGFloat(100)).isActive = true
//        chatLabel.frame.size.height = randHeight
        
        prevChatBubble = newChatBubble
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
        offset.y = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.size.height + CGFloat(-80)
        scrollView.setContentOffset(offset, animated: true)
    }
}
