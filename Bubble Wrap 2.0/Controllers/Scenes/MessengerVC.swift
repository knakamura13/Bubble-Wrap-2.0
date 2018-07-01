//
//  MessengerVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit

class MessengerVC: UIViewController {
    
    // Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContainerView: UIView!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    let numBubbles = 50
    let bubbleHeightMultiplyer = 87
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize.height = CGFloat(numBubbles * bubbleHeightMultiplyer)
        
        displayTestMessages()
    }
    
    // Layout a series of test messages
    func displayTestMessages() {
        var prevChatBubble: UIImageView!
        for i in 0 ... numBubbles {
            let newChatBubble = UIImageView()
            let superView = scrollContainerView!
            superView.addSubview(newChatBubble)
            
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
                newChatBubble.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: CGFloat(numBubbles * bubbleHeightMultiplyer)).isActive = true         // Anchor bottom to superview
            }
            
            // Constant width and height, slightly randomized
            newChatBubble.heightAnchor.constraint(equalToConstant: CGFloat.random(in: 50 ... 80)).isActive = true
            newChatBubble.widthAnchor.constraint(equalToConstant: CGFloat.random(in: 150 ... 200)).isActive = true
            
            prevChatBubble = newChatBubble
        }
        var offset = scrollView.contentOffset
        offset.y = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.size.height + CGFloat(-80)    // Manually scroll to bottom
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
}
