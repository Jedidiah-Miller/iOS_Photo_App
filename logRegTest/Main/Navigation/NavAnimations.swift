//
//  NavAnimations.swift
//  logRegTest
//
//  Created by jed on 10/23/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit

extension NavView {


    func animate(to percent: CGFloat) {
        let offset = abs(percent)
        animateButtonPosition(with: offset)
        layoutIfNeeded()
    }


    func animateButtonPosition(with offset: CGFloat) {
        // have the bottom constraint end up equalling 0
        print(offset)
        let finalDistance: CGFloat = -cameraButton.frame.height*0.6
        let distance = cameraButtonBottomConstraint.constant - finalDistance
        cameraButtonBottomConstraint.constant = cameraButtonBottomConstraint.constant - (distance * offset)
    }






    func adjustNav(_ cameraOpen: Bool) {

        let duration = SwipeViewController.transitionDuration.rawValue/3

        let navButtons = [selfButton,chatButton,connectButton,discoverButton]

        if self.cameraButton.transform == .identity && !cameraOpen {

            cameraButtonBottomConstraint.constant = 0
            cameraButtonWidthConstraint.constant = 55

            UIView.animate(withDuration: duration, delay: 0, options:[.allowUserInteraction, .curveEaseInOut], animations: {

                self.layoutIfNeeded()

                navButtons.forEach { button in
                    button?.alpha = 1
                }


            }, completion: nil )

        } else if cameraOpen {

            cameraButtonBottomConstraint.constant = cameraButtonBottomConstraintConstant
            cameraButtonWidthConstraint.constant = 82

            UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: {

                self.layoutIfNeeded()

                navButtons.forEach { button in
                    button?.alpha = 0.7
                }


            }, completion: nil )

        }

    }





    public func _fadeNav(toAlpha alpha: CGFloat) {

        // not great

        let delay = 0.05

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {

            self.cameraButton.alpha = alpha

        })

        UIView.animate(withDuration: 0.2, delay: delay, options: .curveEaseInOut, animations: {

            self.chatButton.alpha = alpha
            self.connectButton.alpha = alpha

        })

        UIView.animate(withDuration: 0.2, delay: delay*2, options: .curveEaseInOut, animations: {

            self.selfButton.alpha = alpha
            self.discoverButton.alpha = alpha

        })


    }

    
    // stupid AF

    public static func fadeNav(toAlpha alpha: CGFloat) {

        guard let mainVC = UIApplication.shared.keyWindow?.rootViewController as? MainViewController,
            let nav = mainVC.navView else { return }


        nav._fadeNav(toAlpha: alpha)

    }



    public func showNav() {

        let navButtons = [selfButton,chatButton,connectButton,discoverButton]

        var i: Double = 0

        navButtons.forEach { button in

            UIView.animate(withDuration: 0.2, delay: i, options: [.allowUserInteraction ],  animations: {

                button?.alpha = 1

            })

            i += 0.05

        }


    }



}

