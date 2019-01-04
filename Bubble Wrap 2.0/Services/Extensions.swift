//
//  Extensions.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 6/15/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit

extension UIColor {
    /**
     *  Allow UIColor to be created using hexadecimals instead of regular RGB values
     *      Example: let customColor = UIColor(hex: 0xAABBCC).withAlphaComponent(1.0)
    */
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0, green: CGFloat((hex & 0xFF00) >> 8) / 255.0, blue: CGFloat(hex & 0xFF) / 255.0, alpha: alpha)
    }
}

extension UIViewController {
    /**
     * Easily set up keyboard dismissal by calling hideKeyboardWhenTappedAround() from any controller.
     */
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    /**
     *  This is the objective-c function called by the UITapGestureRecognizer's action in `hideKeyboardWhenTappedAround`.
     */
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension CGImagePropertyOrientation {
    /**
     *  Converts a `UIImageOrientation` to a corresponding `CGImagePropertyOrientation`.
     */
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

class DashedBorderView: UIView {
    
    let _border = CAShapeLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    func setup() {
        _border.strokeColor = UIColor.white.cgColor
        _border.fillColor = nil
        _border.lineDashPattern = [4, 4]
        self.layer.addSublayer(_border)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _border.path = UIBezierPath(roundedRect: self.bounds, cornerRadius:8).cgPath
        _border.frame = self.bounds
    }
}
