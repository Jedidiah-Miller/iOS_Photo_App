//
//  LoginAnimations.swift
//  logRegTest
//
//  Created by jed on 12/2/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit

extension LoginViewController {


    @objc func swapLogin(_ sender: UIButton) {
        // MARK !- notSender is whichever button is going to be inactive
        guard let notSender = sender == login ? signUp : login else { return }
        signUpSelected = sender == signUp

        sender.removeTarget(self, action: #selector(swapLogin), for: .touchDown)
        notSender.addTarget(self, action: #selector(swapLogin), for: .touchDown)

        if notSender.isEnabled {
            let selector = signUpSelected ? #selector(loginTapped) : #selector(signUpTapped)
            notSender.removeTarget(self, action: selector, for: .touchUpInside)
        }

        notSender.isEnabled = true

        checkIfValid()

        // temp store things
        let senderFrame = sender.frame
//        let senderFont = sender.titleLabel!.font
        let senderColor = sender.backgroundColor

        if !sender.translatesAutoresizingMaskIntoConstraints {
            [login,signUp].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = true
            }
        }

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.9,options: .curveEaseInOut, animations: {

            sender.frame = notSender.frame
            sender.layer.cornerRadius = notSender.layer.cornerRadius
//            sender.titleLabel?.font = notSender.titleLabel?.font
            sender.backgroundColor = notSender.backgroundColor
            self.view.bringSubviewToFront(sender)

            notSender.frame = senderFrame
            notSender.layer.cornerRadius = 0
//            notSender.titleLabel?.font = senderFont
            notSender.backgroundColor = senderColor

            self.adjustTextFields()

        })

    }


    func adjustTextFields() {
        // MARK ! - this is being called inside an animation block
        // still animates // neat
        if !emailField.translatesAutoresizingMaskIntoConstraints {
            [userNameField,emailField,passwordField].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = true
            }
        }
        if signUpSelected {
            userNameField.transform = .identity
            userNameField.alpha = 1
            emailField.center = passwordField.center
            passwordField.center = resetButton.center
            resetButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            resetButton.alpha = 0
        } else {
            resetButton.transform = .identity
            resetButton.alpha = 1
            passwordField.center = emailField.center // emailCenter
            emailField.center = userNameField.center
            userNameField.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            userNameField.alpha = 0
        }
    }



    func adjustForPasswordReset() {

        passwordResetLabel.alpha = 1
        passwordResetLabel.transform = .identity
        emailField.center = passwordField.center
        passwordField.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        passwordField.alpha = 0

    }

    func adjustForPasswordResetCancel() {

        emailField.center = passwordResetLabel.center
        passwordField.transform = .identity
        passwordField.alpha = 1
        passwordResetLabel.alpha = 0
        passwordResetLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

    }


}
