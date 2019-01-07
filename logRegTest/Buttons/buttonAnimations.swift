//
//  bounceButton.swift
//  logRegTest
//
//  Created by jed on 10/7/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit

class bounceButton: UIButton {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: .allowUserInteraction,
                       animations: { self.transform = CGAffineTransform.identity }, completion: nil )

        super.touchesBegan(touches, with: event)

    }

}

class spinButton: UIButton { // spin animation

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        //do things

        self.transform = CGAffineTransform(rotationAngle: 360.0)

        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: .allowUserInteraction,
                       animations: { self.transform = CGAffineTransform.identity }, completion: nil )

        super.touchesBegan(touches, with: event)

    }

}


class UXButton: UIButton {

    var touchScale: CGFloat = 0.95

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: [.curveEaseInOut ,.allowUserInteraction], animations: {
            self.transform = CGAffineTransform(scaleX: self.touchScale, y: self.touchScale)
        })
        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: [.curveEaseInOut ,.allowUserInteraction], animations: {
            self.transform = .identity
        })
        super.touchesEnded(touches, with: event)
    }

}
