//
//  NavigationButtonsController.swift
//  logRegTest
//
//  Created by jed on 10/10/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit

extension NavView {

    func tapAnimation() {

        self.cameraButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)

        UIView.animate(withDuration: 0.999, delay: 0.00, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.3, options: .allowUserInteraction,
                       animations: { self.cameraButton.transform = CGAffineTransform.identity }, completion: nil )

    }

    func videoAnimation(start: Bool) {

        if start {
            UIView.animate(withDuration: 0.999, delay: 0.00, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.2,
                       options: [
                        .allowUserInteraction
            ],
                       animations: {

//                        self.cameraButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                        self.cameraButton.layer.borderColor = UIColor.red.cgColor

            }, completion: nil )

        } else {

            UIView.animate(withDuration: 0.5, delay: 0.00, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1,
                           options: [
                            .allowUserInteraction
                ],
                           animations: {
//                            self.cameraButton.transform = .identity
                            self.cameraButton.layer.borderColor = self.cameraButtonColor

            }, completion: nil )

        }

    }





}

