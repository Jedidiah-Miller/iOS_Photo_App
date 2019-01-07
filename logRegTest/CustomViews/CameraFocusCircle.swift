//
//  CameraFocusCircle.swift
//  logRegTest
//
//  Created by jed on 12/5/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import UIKit

class FocusCircle: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.alpha = 0
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 0.5
        self.layer.borderWidth = 4
        self.backgroundColor = .clear
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        var size: CGFloat!
        if let width = superview?.frame.width {
            size = width*0.15
        } else {
            size = 50
        }
        self.frame.size = CGSize(width: size, height: size)
        self.layer.cornerRadius = size/2
        for i in 1...8 {
            let view = UIView()
            view.bounds = bounds
            view.clipsToBounds = true
            view.center = CGPoint(x: frame.width/2, y: frame.width/2)
            view.layer.borderWidth = CGFloat(i/2)
            view.layer.borderColor = self.layer.borderColor
            view.layer.cornerRadius = layer.cornerRadius
            view.layer.shadowOffset = .zero
            view.layer.shadowOpacity = 0.8
            view.layer.shadowRadius = 0.5
            addSubview(view)
        }
        self.transform = CGAffineTransform(scaleX: 2, y: 2)
        display()
    }


    func display() {
        animateSubviews()
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
            self.alpha = 0.8
            self.transform = .identity
        })
    }

    func animateSubviews() {

        var i = 0

        for view in subviews {
            UIView.animate(withDuration: 0.3, delay: Double(i)/10, options: .curveEaseInOut, animations: {
                view.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }) { completion in
                i == self.subviews.count ? self.hide() : nil
            }
            i += 1
        }


    }


    func hide() {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
            self.alpha = 0
//            self.transform = .identity
        }) { (hidden) in
            if (hidden) == true {
                self.removeFromSuperview()
            }
        }

    }




    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
