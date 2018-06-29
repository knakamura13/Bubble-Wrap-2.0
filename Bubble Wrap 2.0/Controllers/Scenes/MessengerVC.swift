//
//  MessengerVC.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit
import Firebase

class MessengerVC: UIViewController {
    
    @IBOutlet weak var bubbleImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var image: UIImage = UIImage(named: "chat_bubble_sent")!
        var imageView = UIImageView(image: image)
        self.view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 50)
        let heightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        let widthConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        
        topConstraint.constant = CGFloat.random(in: 20 ... 100)
        view.addConstraint(topConstraint)
        imageView.addConstraints([heightConstraint, widthConstraint])
    }
    
    func createSentMessage() {
        changeImage("chat_bubble_sent")
        bubbleImageView.tintColor = UIColor(named: "chat_bubble_color_sent")
    }
    
    func createReceivedMessage() {
        changeImage("chat_bubble_received")
        bubbleImageView.tintColor = UIColor(named: "chat_bubble_color_received")
    }
    
    func changeImage(_ name: String) {
        guard let image = UIImage(named: name) else { return }
        bubbleImageView.image = image
            .resizableImage(withCapInsets: UIEdgeInsetsMake(17, 21, 17, 21), resizingMode: .stretch)
            .withRenderingMode(.alwaysTemplate)
    }
}
