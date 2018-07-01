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
        
//        let image: UIImage = UIImage(named: "chat_bubble_sent")!
//        let imageView = UIImageView(image: image)
//        self.view.addSubview(imageView)
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//
////        let topConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 50)
//        let rightConstraint = NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: imageView.superview, attribute: .trailing, multiplier: 1, constant: -25)
//        let bottomConstraint = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: -25)
//        view.addConstraints([bottomConstraint, rightConstraint])
//
//        let heightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
//        let widthConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
//        heightConstraint.constant = CGFloat.random(in: 45 ... 70)
//        widthConstraint.constant = CGFloat.random(in: 180 ... 220)
//        imageView.addConstraints([heightConstraint, widthConstraint])
        
        createSentMessage()
    }
    
    func createSentMessage() {
//        changeImage("chat_bubble_sent")
//        bubbleImageView.tintColor = UIColor(named: "chat_bubble_color_sent")
        
        let image: UIImage = UIImage(named: "chat_bubble_sent")!
        var prevImgView: UIImageView!
        for i in 1 ... 3 {
            if i == 1 {
                let newImgView = UIImageView(image: image)
                
                self.view.addSubview(newImgView)
                newImgView.translatesAutoresizingMaskIntoConstraints = false
                
                let rightConstraint = NSLayoutConstraint(item: newImgView, attribute: .trailing, relatedBy: .equal, toItem: newImgView.superview, attribute: .trailing, multiplier: 1, constant: -25)
                let bottomConstraint = NSLayoutConstraint(item: newImgView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: -25)
                view.addConstraints([bottomConstraint, rightConstraint])
                
                let heightConstraint = NSLayoutConstraint(item: newImgView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
                let widthConstraint = NSLayoutConstraint(item: newImgView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
                heightConstraint.constant = CGFloat.random(in: 45 ... 70)
                widthConstraint.constant = CGFloat.random(in: 180 ... 220)
                newImgView.addConstraints([heightConstraint, widthConstraint])
                
                prevImgView = newImgView
            } else {
                let newImgView = UIImageView(image: image)
                
                self.view.addSubview(newImgView)
                newImgView.translatesAutoresizingMaskIntoConstraints = false
                
                let rightConstraint = NSLayoutConstraint(item: newImgView, attribute: .trailing, relatedBy: .equal, toItem: newImgView.superview, attribute: .trailing, multiplier: 1, constant: -25)
                newImgView.bottomAnchor.constraint(equalTo: prevImgView.topAnchor, constant: -20.0).isActive = true
                view.addConstraints([rightConstraint])
                
                let heightConstraint = NSLayoutConstraint(item: newImgView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
                let widthConstraint = NSLayoutConstraint(item: newImgView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
                heightConstraint.constant = CGFloat.random(in: 45 ... 70)
                widthConstraint.constant = CGFloat.random(in: 180 ... 220)
                newImgView.addConstraints([heightConstraint, widthConstraint])
                
                prevImgView = newImgView
            }
        }
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
