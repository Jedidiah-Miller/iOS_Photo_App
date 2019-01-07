//
//  MessageOverlay.swift
//  logRegTest
//
//  Created by jed on 12/3/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit


public enum PopupMessage: String {

    // Login / signup

    case passwordResetError
    case loginError
    case signupError

    case userNameTaken = "this username has been taken already, don't worry though, you can call yourself whatever you want"

    case passwordResetSuccess = "email sent, check email for a reset link or somthing"

    // settings
    // updating info

    case discardChanges = "if you leave you'll lose the changes you made"

    case logout = "are you sure?"

    func type() -> (UIColor, String) {
        switch self {

        case .passwordResetError, .loginError, .signupError, .userNameTaken: return (.red, "Error")
        case .passwordResetSuccess: return (.green, "Success")

        case .discardChanges, .logout: return (.black, "Holdup")

        }
    }

}



class MessageBlurView: UIVisualEffectView {


    let messageBox: UIView! = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        return view
    }()

    var messageBoxCenterYConstraint: NSLayoutConstraint!

    lazy var titleLabel: UILabel! = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()

    lazy var messageLabel: UILabel! = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "bummer"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()

    let continueButton: UXButton! = {
        let button = UXButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 8
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("I'm ok with this", for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 35, left: 35, bottom: 35, right: 35)
        return button
    }()

    lazy var dismissButton: UXButton! = {
        let button = UXButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 8
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("got it", for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 35, left: 35, bottom: 35, right: 35)
        button.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        return button
    }()

    var popupMessage: PopupMessage!


    var messageBoxSize: CGSize! {
        didSet {
            activateConstraints()
        }
    }


    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        commonInit()
    }


    func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageBox)
        [titleLabel,messageLabel,dismissButton].forEach {
            messageBox.addSubview($0!)
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
    }



    func activateConstraints() {

        [titleLabel,messageLabel,dismissButton].forEach {
            $0?.widthAnchor.constraint(equalToConstant: messageBoxSize.width*0.9).isActive = true
            $0?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        }

        messageBoxCenterYConstraint = messageBox.centerYAnchor.constraint(equalTo: centerYAnchor)
//        messageBoxCenterYConstraint.constant = -(frame.height/2) // does nothing on init

        let constraints: [NSLayoutConstraint] = [

//            messageBoxCenterYConstraint,
            messageBox.widthAnchor.constraint(equalToConstant: messageBoxSize.width),
            messageBox.heightAnchor.constraint(equalToConstant: messageBoxSize.height),
            messageBox.centerXAnchor.constraint(equalTo: centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: messageBox.topAnchor, constant: 8),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 30),

            dismissButton.heightAnchor.constraint(equalToConstant: messageBoxSize.height/6),
            dismissButton.bottomAnchor.constraint(equalTo: messageBox.bottomAnchor)

        ]

        NSLayoutConstraint.activate(constraints)

        layoutIfNeeded()
        contentView.layoutIfNeeded()

    }


    func extraButtonSetup() {

        dismissButton.setTitle("cancel", for: .normal)

        messageBox.addSubview(continueButton)
        continueButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            continueButton.widthAnchor.constraint(equalTo: dismissButton.widthAnchor, multiplier: 1),
            continueButton.heightAnchor.constraint(equalTo: dismissButton.heightAnchor, multiplier: 1),
            continueButton.bottomAnchor.constraint(equalTo: dismissButton.topAnchor, constant: -4),
            continueButton.centerXAnchor.constraint(equalTo: dismissButton.centerXAnchor),

        ])

    }



    func present() {

        let type = popupMessage.type()

        titleLabel.textColor = type.0
        titleLabel.text = type.1

        let hasSetupExtra = messageBox.subviews.contains(continueButton)

        switch popupMessage {

        case .discardChanges?, .logout?:

            !hasSetupExtra ? extraButtonSetup() : nil

            messageLabel.text = popupMessage.rawValue

        case .userNameTaken?, .passwordResetSuccess?: messageLabel.text = popupMessage.rawValue

        default:

            if hasSetupExtra {
                dismissButton.setTitle("got it", for: .normal)
                continueButton.removeFromSuperview()
            }

        }


        if !messageBoxCenterYConstraint.isActive {
            messageBoxCenterYConstraint.isActive = true
        } else {
            messageBoxCenterYConstraint.constant = 0
        }


        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.layoutIfNeeded()
            self.alpha = 1
        })
    }

    @objc func dismiss() {

        messageBoxCenterYConstraint.constant = -(frame.height/2) // nil

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.layoutIfNeeded()
            self.alpha = 0
        }) { completion in

        }

    }



    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}
