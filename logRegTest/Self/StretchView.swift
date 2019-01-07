//
//  StretchProfileView.swift
//  logRegTest
//
//  Created by jed on 11/10/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import UIKit


class StretchView: Gradient {

    var profileImageGradient: UIView!

    var bottomConstraint: NSLayoutConstraint!,
        profileImageBottomConstraint: NSLayoutConstraint!

    lazy var panRecognizer: UIPanGestureRecognizer! = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:) ))
        recognizer.minimumNumberOfTouches = 1
        recognizer.maximumNumberOfTouches = 1
        return recognizer
    } ()


    var mediumHeightSet: Bool = false {
        didSet {
            panRecognizer.isEnabled = !mediumHeightSet
        }
    }
    var adjustsView: Bool = false

    var fullHeight: CGFloat!{
        didSet {
            mediumHeight = fullHeight/3
        }
    }
    var mediumHeight: CGFloat!,
        smallHeight: CGFloat = 80,
        YZero: CGFloat!

/* functions  */

    override init(frame: CGRect) {
        super.init(frame: frame)
    } //// END
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        //custom logic goes here

        self.backgroundColor = .clear
        self.addGestureRecognizer(panRecognizer)

    }

//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let view = super.hitTest(point, with: event)
//
//        guard mediumHeightSet else { return view }
//
//        return view == self ? nil : view
//    }


    func setupForController() {

        profileImageGradient = UIView(frame: CGRect(x: 0, y: superview!.center.y, width: superview!.bounds.width, height: fullHeight/2)) // change this to constraints
        profileImageGradient.isUserInteractionEnabled = false
        profileImageGradient.clipsToBounds = true
        profileImageGradient.backgroundColor = .clear
        profileImageGradient.addGradident(colors: [ #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0).cgColor , #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor ])

//        self.addSubview(profileImageGradient)
        self.insertSubview(profileImageGradient, at: 1)

    }

    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) { // is not disabled on drag down with multi touch

        let translationY = sender.translation(in: self).y

        bottomConstraint.constant = translationY * 0.3

        if sender.state == .ended {
            translationY < -175 ? setSize(constant: mediumHeight - fullHeight) : setSize(constant: 0)
        }

    }


    func adjustConstraints(offset:CGFloat) {

        if YZero == nil {
            YZero = offset // MAGIC // no clue why this only works here
        }

        let diffY = YZero - offset

        guard diffY >= smallHeight - fullHeight else {
            if bottomConstraint.constant != smallHeight - fullHeight {
                bottomConstraint.constant = smallHeight - fullHeight
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: [.curveEaseInOut], animations: {
                    self.superview!.layoutIfNeeded()
                }, completion: nil )
            }
            return
        }

        bottomConstraint.constant = diffY

    }


    func setSize(constant: CGFloat) {

        mediumHeightSet = constant == mediumHeight - fullHeight
        adjustsView = mediumHeightSet
        bottomConstraint.constant = constant

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.superview?.layoutIfNeeded()
        }) { (completion) in
            self.adjustsView = false
        }

    }





}
