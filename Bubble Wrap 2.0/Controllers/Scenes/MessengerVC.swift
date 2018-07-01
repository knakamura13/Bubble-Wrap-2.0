//
//  MessengerVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit

class MessengerVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayTestMessages()
    }
    
    // Layout a series of test messages
    func displayTestMessages() {
        var prevChatBubble: UIImageView!
        for _ in 0 ... 7 {
            let newChatBubble = UIImageView()
            self.view.addSubview(newChatBubble)
            
            newChatBubble.translatesAutoresizingMaskIntoConstraints = false
            
            // Randomly switch between sent and received style messages
            let div2: Bool = Int.random(in: 0 ... 100) % 2 == 0
            let div3: Bool = Int.random(in: 0 ... 100) % 3 == 0
            if div2 || div3 {
                switchImage(imageView: newChatBubble, to: "sent")
            } else {
                switchImage(imageView: newChatBubble, to: "received")
            }
            
            if prevChatBubble != nil {
                newChatBubble.bottomAnchor.constraint(equalTo: prevChatBubble.topAnchor, constant: -20.0).isActive = true   // Anchor bottom to previous bubble
            } else {
                // newChatBubble is first/only bubble on the screen
                newChatBubble.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100.0).isActive = true         // Anchor bottom to superview
            }
            
            // Constant width and height, slightly randomized
            newChatBubble.heightAnchor.constraint(equalToConstant: CGFloat.random(in: 50 ... 80)).isActive = true
            newChatBubble.widthAnchor.constraint(equalToConstant: CGFloat.random(in: 150 ... 200)).isActive = true
            
            prevChatBubble = newChatBubble
        }
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
}
