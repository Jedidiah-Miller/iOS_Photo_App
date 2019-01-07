//
//  SomeSettingsViewController.swift
//  logRegTest
//
//  Created by jed on 10/2/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit
import Photos
import FirebaseFirestore

class SomeSettingsViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var userNameText: UITextField! // look in login vc to see how to add observer
    @IBOutlet weak var bioText: UITextView!
    @IBOutlet weak var navSwitch: UISwitch!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!

    lazy var imageTapGesture: UITapGestureRecognizer! = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(editImage))
        tap.numberOfTapsRequired = 1
        tap.delegate = profileImage as? UIGestureRecognizerDelegate
        return tap
    }()

    lazy var alertView: MessageBlurView! = {
        let view = MessageBlurView(effect: UIBlurEffect(style: .dark))
        view.messageBoxSize = CGSize(width: self.view.frame.width*0.7, height: self.view.frame.width*0.5)
        view.alpha = 0
        return view
    }()

    @IBOutlet var userNameLabel: UILabel!

    lazy var userNameErrorLabel: UILabel! = {
        let label = UILabel()
        label.font = userNameLabel.font
        label.textColor = .red
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var changesMade: Bool! {
        get {
            return savedUserName != userNameText.text || savedBio != bioText.text || savedImage != profileImage.image
        }
    }

    var savedImage: UIImage?
    var savedUserName: String!
    var savedBio: String?

    let allowedChars: CharacterSet = NSCharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_!$?").inverted



    override func viewDidLoad() {
        super.viewDidLoad()

        bioText.text = ""

        [alertView,userNameErrorLabel].forEach { view in
            view?.translatesAutoresizingMaskIntoConstraints = false
            view?.alpha = 0
            self.view.addSubview(view!)
        }

        setupConstraints()
        setNotificationCenter()
        navSwitch.isOn = SwipeViewController.transitionDuration == .quick

        userNameText.delegate = self
        userNameText.returnKeyType = .done

        bioText.delegate = self
        bioText.returnKeyType = .done
        bioText.layer.borderWidth = 1
        bioText.layer.borderColor = UIColor.lightGray.cgColor

        submitButton.isEnabled = false
        submitButton.setTitleColor(#colorLiteral(red: 1, green: 0.5212877989, blue: 0, alpha: 1), for: .normal)
        submitButton.setTitle("update", for: .normal)
        submitButton.setTitleColor(.gray, for: .disabled)
        submitButton.setTitle("update", for: .disabled)
        submitButton.addTarget(self, action: #selector(submitButtonTap), for: .touchUpInside)

        closeButton.addTarget(self, action: #selector(dismissTap), for: .touchUpInside)

        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(imageTapGesture)
        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true
        profileImage.image = savedImage
        profileImage.backgroundColor = #colorLiteral(red: 0.3046833277, green: 0.302877903, blue: 0.3060749173, alpha: 0.4855789812)

        userNameText.text = UserService.currUser.userName
        savedUserName = userNameText.text

        if let bio = UserService.currUser.bio {
            bioText.text = bio
            savedBio = bioText.text
        }

    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard string == string.components(separatedBy: allowedChars).joined(separator: "") else { return false }

        let newText = (userNameText.text! as NSString).replacingCharacters(in: range, with: string)
        let numberOfChars = newText.count
        return numberOfChars < 22

    }


    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        guard text != "\n" else {
            view.endEditing(true)
            return false
        }

        let newText = (bioText.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count

        return numberOfChars < 90
    }

    func textViewDidChange(_ textView: UITextView) {
        validate()
    }


    @objc func validate() { // add a sender to this so it will only validate for one specific thing

        let tooShort = userNameText.text!.count < 3

        // dont check if its too short or the name hasnt changed

        let shouldCheckName = userNameText.text?.lowercased() != savedUserName.lowercased()

        if shouldCheckName && !tooShort {

            UserService.checkUserName(userNameText.text!) { (exists) in

                self.submitButton.isEnabled = self.changesMade && !exists

                self.userNameErrorLabel.text = "this userName has been taken"
                self.showNameErrorLabel(exists)

            }

        } else {

            tooShort ? userNameErrorLabel.text = "too short" : nil

            showNameErrorLabel(tooShort)

            submitButton.isEnabled = changesMade && !tooShort
        }


    }


    func showNameErrorLabel(_ show: Bool) {

        userNameErrorLabel.alpha = show ? 1 : 0

    }



    func displayAlert(_ message: String, for popupMessage: PopupMessage) {

        alertView.popupMessage = popupMessage

        switch popupMessage {

        case .discardChanges:
            alertView.continueButton.setTitle("I'm ok with this", for: .normal)
            alertView.continueButton.addTarget(self, action: #selector(dismissTap), for: .touchUpInside)

        case .logout:
            alertView.continueButton.setTitle("yes log me out", for: .normal)
            alertView.continueButton.addTarget(self, action: #selector(logout), for: .touchUpInside)

        default: alertView.messageLabel.text = message

        }

        view.bringSubviewToFront(alertView)
        alertView.present()

        view.endEditing(true)


    }



    @objc func submitButtonTap(_ sender: UIButton) {

        guard changesMade, let userName = userNameText.text else { return }

        var updates: [(String, Any)] = []

        var updatedImage: Bool = false

        savedUserName != userName ? updates.append(("userName", userName)) : nil

        if savedUserName != userName {

            updates.append(("userName", userName))
            updates.append(("lowercasedName", userName.lowercased()))

        }


        if savedImage != profileImage.image {

            profileImage.image != nil ? updateProfileImage() : updates.append(("profileImage", FieldValue.delete()))

            updatedImage = true

        }


        if let bioText = bioText.text, bioText != savedBio {

            let bioUpdate: Any = bioText.isEmpty ? FieldValue.delete() : bioText

            updates.append(("bio", bioUpdate))

        }


        guard !updates.isEmpty else { // if the only update is a new profile image
            updatedImage ? self.dismiss(animated: true) : nil
            return
        }


        let dict: [String: Any] = updates.reduce(into: [:]) { $0[$1.0] = $1.1}

        UserService.update(dict) { (error) in
            if error != nil {
                self.displayAlert(error!.localizedDescription, for: .signupError)
                print("ERROR ", error!.localizedDescription)
            } else {
                self.dismiss(animated: true)
            }
        }

    }


    func updateProfileImage() {

        if let image = profileImage.image {
            ImageService.addImage(image, loc: "ProfileImages", progressBlock: { (percentage) in

                print("uploading - ", percentage)


            }, completion: { (url, error) in
                if error != nil {
                    print("ERROR - SELF Image ", error as Any)
                } else {
                    if let url = url {
                        UserService.setProfileImage(imageUrl: url) { error in

                            error == nil ? print("success") : print("did not upload")

                        }
                    }
                }
            })
        }

    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        let view = touches.first?.view

        if !( view is UITextView ) || !( view is UITextField ) {
            view?.endEditing(true)
        }

    }


    @IBAction func transitionDurationSwitch(_ sender: UISwitch) {
        SwipeViewController.transitionDuration = sender.isOn ? .quick : .normal
        UserDefaults.standard.set(SwipeViewController.transitionDuration.rawValue, forKey: SwipeViewController.userTransitionDuration)
    }


    @IBAction func logoutTapped(_ sender: Any) {
        displayAlert("logout ?", for: .logout)
    }


    @objc func logout() {

        UserService.signOut() // {  (error) in

//            guard error == nil else {
//                print(error!.localizedDescription)
//                self.displayAlert("Error signing out", for: .loginError)
//                return
//            }

            self.dismiss(animated: false, completion: nil)

//        }

    }


    @objc func dismissTap(_ sender: UIButton) {

        changesMade && sender == closeButton ? displayAlert("dont", for: .discardChanges) : dismiss(animated: true)

    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)

        // if the name or photo was updated // make it update those thigns everyehere, rn it doesn not do that


    }

}


extension SomeSettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    @objc func editImage() { // TODO - make this a custom view, not the default one

        let alert = UIAlertController(title: "Profile Image", message: "what do you want to do?", preferredStyle: .alert)

        if profileImage.image != nil {

            alert.addAction(UIAlertAction(title: "remove current image", style: .destructive) {action in
                self.profileImage.image = nil
                self.validate()
            })

        }

        alert.addAction(UIAlertAction(title: "choose an image", style: .default) { (action) in
            self.checkImagePicker()
        })

        alert.addAction(UIAlertAction(title: "cancel", style: .cancel))

        present(alert, animated: true)

    }


    fileprivate func presentPickerController() {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = self
        pickerController.modalPresentationStyle = .overCurrentContext
        self.present(pickerController, animated: true, completion: nil)
    }


    fileprivate func showAlert(title: String, message: String, settings: Bool) {


        // add my custom alert

        let alert = UIAlertController(title: "Photo Library \(title)", message: message, preferredStyle: .alert)

        if settings {
            alert.addAction(UIAlertAction(title: "Go to Settings", style: .default ) { (action) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:])
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        } else {
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
        }

        present(alert, animated: true)

    }


    @objc private func checkImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .authorized: self.presentPickerController()
                case .denied:
                    self.showAlert(title: "Photo Library Access Denied", message: "Photo Library access was denied. Update your settings to change this", settings: true)
                case .notDetermined:
                    if status == .authorized {
                        self.presentPickerController()
                    }
                case .restricted:
                    self.showAlert(title: "Photo Library Access Denied", message: "Photo Library access was restricted. Update your settings to change this", settings: false)
                }
            }
        }
    }






    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

            if savedImage == nil {

                self.savedImage = self.profileImage.image // only set it once

            }

            self.profileImage.image = image
            self.validate()
        }


        dismiss(animated: true, completion: nil)

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        // set the image back if needed

        dismiss(animated: true, completion: nil)

    }



}


extension SomeSettingsViewController { // keyboard


    func setNotificationCenter() {

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(validate), name: UITextField.textDidChangeNotification , object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }

    @objc func adjustForKeyboard(notification: Notification) {

        let userInfo = notification.userInfo!,
        keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue,
        keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)


        if notification.name == UIResponder.keyboardWillHideNotification {

            view.transform = .identity

        } else {

            let lowerPos = (view.frame.height/2) - bioText.frame.height

            if keyboardViewEndFrame.height > lowerPos {

                let diffY = (view.center.y - bioText.frame.minY) - 4 // 4 is extra padding

                 view.transform = CGAffineTransform(translationX: 0, y: diffY)

            }

        }

    }



}

// MARK ! - constraints
extension SomeSettingsViewController {

    func setupConstraints() {

        // lol at this
        // 90 W's is to set the size of the textView for the max charcters

        for _ in 1...90 {
            bioText.text.append("W")
        }

        let fixedWidth = bioText.frame.size.width
        let newSize = bioText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))

        bioText.text = ""


        NSLayoutConstraint.activate([

            userNameErrorLabel.bottomAnchor.constraint(equalTo: userNameLabel.bottomAnchor),
            userNameErrorLabel.leadingAnchor.constraint(equalTo: userNameLabel.trailingAnchor, constant: 4),

            bioText.heightAnchor.constraint(equalToConstant: newSize.height),

            alertView.topAnchor.constraint(equalTo: self.view.topAnchor),
            alertView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            alertView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            alertView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),

        ])

    }

}
