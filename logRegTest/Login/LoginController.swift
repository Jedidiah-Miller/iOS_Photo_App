//
//  LoginController.swift
//  logRegTest
//
//  Created by jed on 7/1/18.
//  Copyright © 2018 jed. All rights reserved.

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import LocalAuthentication


class LoginViewController: UIViewController {

    let logoView: UIImageView! = {
        let view = UIImageView()
        return view
    }()

    @IBOutlet var userNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var userNameField: UITextField!

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var login: UIButton! // disable the buttons if blank

    @IBOutlet weak var gradientView: Gradient!

    lazy var resetButton: UXButton! = {
        let button = UXButton()
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("forgot email or password", for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.setTitle("send password reset", for: .disabled)
        button.titleEdgeInsets = UIEdgeInsets(top: 35, left: 35, bottom: 35, right: 35)
        button.addTarget(self, action: #selector(startPasswordReset), for: .touchUpInside)
        return button
    }()

    lazy var passwordResetLabel: UILabel! = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "enter your email you created your account with"
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    lazy var errorView: MessageBlurView! = {
        let view = MessageBlurView(effect: UIBlurEffect(style: .light))
        view.messageBoxSize = CGSize(width: self.view.frame.width*0.7, height: self.view.frame.width*0.5)
        view.alpha = 0
        return view
    }()

    var signUpSelected: Bool = false
    var resettingPassword: Bool = false

    var gradientColorsIndex: Int = -1
    var gradientColors: [ (color1: UIColor, color2: UIColor) ] = []

    let allowedChars: CharacterSet = {
        return NSCharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_!$?@.").inverted
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(errorView)
        view.addSubview(resetButton)

        setupConstraints()

        userNameTopConstraint.constant = view.frame.height/5

        [login,signUp].forEach {
            $0?.setTitle($0?.currentTitle, for: .disabled)
            $0?.setTitleColor(.lightGray, for: .disabled)
            $0?.layer.borderColor = nil
            $0?.layer.borderWidth = 0
        }

        signUp.layer.shadowOpacity = 0
        signUp.backgroundColor = UIColor(white: 1, alpha: 0.3)
        signUp.addTarget(self, action: #selector(swapLogin), for: .touchDown)

        view.bringSubviewToFront(login)
        login.isEnabled = false
        login.backgroundColor = UIColor(white: 1, alpha: 0.5)
        login.layer.cornerRadius = login.frame.height/2

        [userNameField, emailField, passwordField].forEach {
            $0?.delegate = self
            $0?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            $0?.returnKeyType = .next
            $0?.enablesReturnKeyAutomatically = true
            $0?.borderStyle = .none
            $0?.autocorrectionType = .no
            $0?.autocapitalizationType = .none
            $0?.clearButtonMode = .whileEditing
        }

        userNameField.transform = CGAffineTransform(scaleX: 0, y: 0)

        setNotificationCenter()

        gradientView.isUserInteractionEnabled = false
        resetButton.isUserInteractionEnabled = true

    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }

    @objc func loginTapped(_ sender: UIButton) {
        guard !signUpSelected, let email = emailField.text?.lowercased(),
            let password = passwordField.text, password.count > 7
            else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if user != nil && error == nil {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.displayMessage(error!.localizedDescription, for: .loginError)
            }
        }
    }


    @objc func signUpTapped(_ sender: UIButton) {

        guard signUpSelected,
            let userName = userNameField.text, userName.count > 2,
            let email = emailField.text?.lowercased(),
            let password = passwordField.text, password.count > 7
            else { return }

        UserService.checkUserName(userName) { (exists) in

            guard !exists else {
                self.displayMessage("", for: .userNameTaken)
                return
            }

            createNewUser()

        }



        func createNewUser() {

            print("got here")

            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if user != nil {

                    guard let uid = Auth.auth().currentUser?.uid else { return }

                    let user = User( ref: nil, uid: nil,
                                     email: email, userName: userName,
                                     bio: nil, profileImage: nil,
                                     accountCreatedAt: Date()
                    )

                    UserService.ref.document(uid).setData(user.dict) { error in

                        if let error = error {
                            self.displayMessage(error.localizedDescription, for: .signupError)
                        } else {

                            UserService.update(["lowercasedName": userName.lowercased()], completion: { (error) in

                                if let error = error {
                                    self.displayMessage(error.localizedDescription, for: .signupError)
                                } else {
                                    self.dismiss(animated: true, completion: nil)
                                }

                            })

                        }

                    }

                } else {
                    self.displayMessage(error!.localizedDescription, for: .signupError)
                }
            }

        }


    }





    @objc func checkIfValid() {

        let validEmail = emailIsValid(emailField.text!)

        guard resetButton.currentTitle != "send password reset" else {
            // check things
            resetButton.isEnabled = validEmail
            return
        }

        let button: UIButton! = signUpSelected ? signUp : login

        guard validEmail, passwordField.text!.count > 7 else {
                if button.isEnabled {
                    let selector = signUpSelected ? #selector(signUpTapped) : #selector(loginTapped)
                    button.removeTarget(self, action: selector, for: .touchUpInside)
                    button.isEnabled = false
                }
                return
            }

        let alreadyEnabled = button.isEnabled

        switch signUpSelected {

        case true:
            button.isEnabled = userNameField.text!.count > 2
            if !alreadyEnabled, button.isEnabled {
                button.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
            } else if !button.isEnabled, alreadyEnabled {
                button.removeTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
            }

        case false:
            if alreadyEnabled {
                return
            }
            button.isEnabled = true
            button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        }
    }

    func emailIsValid(_ emailID:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailID)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let view = touches.first?.view
        self.view.endEditing(!(view is UITextField))
    }


    func animateGradient() {

        gradientColorsIndex = gradientColorsIndex == (gradientColors.count - 1) ? 0 : gradientColorsIndex + 1

        UIView.transition(with: gradientView, duration: 2, options: [.transitionCrossDissolve], animations: {

            self.gradientView.FirstColor = self.gradientColors[self.gradientColorsIndex].color1
            self.gradientView.SecondColor = self.gradientColors[self.gradientColorsIndex].color2
            
        }) { (success) in
            self.animateGradient()
        }

    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        resetButton.frame = passwordField.frame
        resetButton.layer.cornerRadius = resetButton.frame.height/2
        adjustTextFields()

        guard signUpSelected else { return }

        gradientColors.append((color1: gradientView.FirstColor, color2: gradientView.SecondColor))
        gradientColors.append((color1: #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1), color2: #colorLiteral(red: 0.5082274675, green: 0, blue: 1, alpha: 1)))
        gradientColors.append((color1: #colorLiteral(red: 1, green: 0.549480319, blue: 0, alpha: 1), color2: #colorLiteral(red: 1, green: 0, blue: 0.9390402436, alpha: 1)))
        gradientColors.append((color1: #colorLiteral(red: 0.7014248967, green: 0, blue: 0, alpha: 1), color2: #colorLiteral(red: 0.3557421565, green: 0, blue: 1, alpha: 1)))
        gradientColors.append((color1: #colorLiteral(red: 1, green: 0.4007393122, blue: 0, alpha: 1), color2: #colorLiteral(red: 0.7322204709, green: 0, blue: 1, alpha: 1)))
        gradientColors.append((color1: #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1), color2: #colorLiteral(red: 0.5082274675, green: 0, blue: 1, alpha: 1)))
        gradientColors.append((color1: #colorLiteral(red: 1, green: 0.2674711049, blue: 0, alpha: 1), color2: #colorLiteral(red: 0.5795089602, green: 0, blue: 1, alpha: 1)))
        gradientColors.append((color1: #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1), color2: #colorLiteral(red: 0.5082274675, green: 0, blue: 1, alpha: 1)))
        gradientColors.append((color1: #colorLiteral(red: 0.7014248967, green: 0, blue: 0, alpha: 1), color2: #colorLiteral(red: 0.3557421565, green: 0, blue: 1, alpha: 1)))

        animateGradient()
    }


}

extension LoginViewController { // constraints

    func setupConstraints() {
        let loginHeight = login.frame.height
        let signUpHeight = view.frame.height/7


        [userNameField,emailField,passwordField, resetButton].forEach {
            $0?.heightAnchor.constraint(equalToConstant: loginHeight*0.8).isActive = true
            $0?.widthAnchor.constraint(equalToConstant: view.frame.width*0.7).isActive = true
            $0?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }

        [login,signUp].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
            $0?.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        }

        let constraints: [NSLayoutConstraint] = [

            login.widthAnchor.constraint(equalToConstant: view.frame.width*0.6),
            login.heightAnchor.constraint(equalToConstant: loginHeight),
            login.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(signUpHeight+16)),

            signUp.widthAnchor.constraint(equalToConstant: view.frame.width),
            signUp.heightAnchor.constraint(equalToConstant: signUpHeight),
            signUp.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // hatred

            errorView.topAnchor.constraint(equalTo: self.view.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),

        ]

        NSLayoutConstraint.activate(constraints)

    }


}

extension LoginViewController { // password reset


    @objc func startPasswordReset() {

        login.isEnabled = false
        signUp.isEnabled = false

        userNameField.text = ""
        passwordField.text = ""

        resetButton.removeTarget(self, action: #selector(startPasswordReset), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(attemptPasswordReset), for: .touchUpInside)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.setTitle("send password reset", for: .normal)

        checkIfValid()
        emailField.becomeFirstResponder()

        passwordResetLabel.frame = emailField.frame
        passwordResetLabel.alpha = 0
        passwordResetLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

        view.subviews.contains(passwordResetLabel) ? nil : view.addSubview(passwordResetLabel)

        let cancelButton = UXButton()
        cancelButton.tag = 987
        cancelButton.addTarget(self, action: #selector(cancelPasswordReset), for: .touchUpInside)
        cancelButton.setTitle("cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.frame.size = CGSize(width: resetButton.frame.width*0.5, height: resetButton.frame.height*0.5)
        cancelButton.center = CGPoint(x: resetButton.center.x, y: resetButton.center.y + resetButton.frame.height)
        cancelButton.layer.cornerRadius = cancelButton.frame.height/2
        cancelButton.layer.borderWidth = resetButton.layer.borderWidth
        cancelButton.layer.borderColor = resetButton.layer.borderColor
        cancelButton.alpha = 0
        cancelButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

        view.addSubview(cancelButton)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.adjustForPasswordReset()
            self.login.transform = .identity
            cancelButton.transform = .identity
            cancelButton.alpha = 1
        })
    }

    @objc func cancelPasswordReset() {

        guard let cancelButton = view.viewWithTag(987) else { return }

        resetButton.removeTarget(self, action: #selector(attemptPasswordReset), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(startPasswordReset), for: .touchUpInside)

        resetButton.setTitleColor(.white, for: .normal)
        resetButton.setTitle("forgot email or password", for: .normal)

        let button = !signUpSelected ? signUp : login
        button!.isEnabled = true

        checkIfValid()

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.adjustForPasswordResetCancel()
            cancelButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            cancelButton.alpha = 0
        }) { (completion) in
            self.resetButton.isSelected = false
            self.resetButton.isEnabled = true
//            self.passwordResetLabel.text = "enter your email you created your account with"
//            self.passwordResetLabel.textColor = .white
            cancelButton.removeFromSuperview()

            if self.emailField.isEditing {
                self.emailField.resignFirstResponder()
                self.emailField.becomeFirstResponder()
            }
        }

    }



    @objc func attemptPasswordReset() {

        guard let email = emailField.text, emailIsValid(email) else { return }

        resetButton.isEnabled = false

        UserService.resetPassword(email) { (error) in
            if let error = error {
                self.displayMessage(error.localizedDescription, for: .passwordResetError)
                self.resetButton.isEnabled = true
            } else {
//                let message = "email sent, check email for a reset link or somthing"
                self.displayMessage("yay", for: .passwordResetSuccess)
                self.cancelPasswordReset()
            }
        }
    }


    func displayMessage(_ message: String, for popupMessage: PopupMessage) {

        errorView.popupMessage = popupMessage

        switch popupMessage {

        default: errorView.messageLabel.text = message

        }

        view.bringSubviewToFront(errorView)
        errorView.present()

        view.endEditing(true)

    }

}


extension LoginViewController: UITextFieldDelegate {

    func setNotificationCenter() {

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(checkIfValid), name: UITextField.textDidChangeNotification , object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)

    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let allowed = string == string.components(separatedBy: allowedChars).joined(separator: "")

        guard allowed else { return false }


        // allow @ and . only for email field // annoying

        let isOK = string != "." || string != "@"

        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)

        return textField != emailField ? isOK && newText.count < 23 : newText.count < 31

    }


    func textFieldShouldClear(_ textField: UITextField) -> Bool {

        let button: UIButton! = signUpSelected ? signUp : login

        if button.isEnabled {
            let selector = signUpSelected ? #selector(signUpTapped) : #selector(loginTapped)
            button.removeTarget(self, action: selector, for: .touchUpInside)
            button.isEnabled = false
        }
        return true
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case userNameField:
            if userNameField.text!.count > 4 {
                emailField.becomeFirstResponder()
            }
        case emailField:
            if emailField.text!.count > 7  {
                passwordField.becomeFirstResponder()
            }
        case passwordField: signUpSelected ? signUpTapped(signUp) : loginTapped(login)

        default: print("IDK BRO")
        }
        return true
    }


    @objc func adjustForKeyboard(notification: Notification) {

        guard view.viewWithTag(987) == nil else { return }

        let userInfo = notification.userInfo!,
            keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue,
            keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        let button: UIButton = signUpSelected ? signUp : login

        if notification.name == UIResponder.keyboardWillHideNotification {

            UIView.animate(withDuration: 0.2, delay: 0,options: .curveEaseInOut, animations: {

                button.transform = .identity
            })

        } else {

            let newY = -keyboardViewEndFrame.height + (button.frame.height*2)

            UIView.animate(withDuration: 0.2, delay: 0,options: .curveEaseInOut, animations: {
                button.transform = CGAffineTransform(translationX: 0, y: newY)
            })

        }


    }

}

