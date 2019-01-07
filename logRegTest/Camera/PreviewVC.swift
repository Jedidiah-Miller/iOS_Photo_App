//
//  PreviewVC.swift
//  
//
//  Created by jed on 12/8/18.
//

import Foundation
import UIKit


class PreviewVC: UIViewController {

    lazy var dismissButton: UXButton = {
        let button = UXButton()
        button.setImage(#imageLiteral(resourceName: "closeIcon"), for: .normal)
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return button
    }()

    lazy var textButton: UXButton = {
        let button = UXButton()
        button.setImage(#imageLiteral(resourceName: "textIcon"), for: .normal)
        button.addTarget(self, action: #selector(textTap), for: .touchUpInside)
        return button
    }()

    lazy var scaleImageGesture: UIPinchGestureRecognizer = {
        return  UIPinchGestureRecognizer(target: self, action: #selector(scaleImage))
    }()

    var submitButtonBottomConstraint: NSLayoutConstraint!

    lazy var submitButton: UXButton = {
        let button = UXButton()
        button.setImage(#imageLiteral(resourceName: "submitIcon"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        button.layer.cornerRadius = 20
        button.backgroundColor = #colorLiteral(red: 1, green: 0.5212877989, blue: 0, alpha: 1)
        button.addTarget(self, action: #selector(submitTap), for: .touchUpInside)
        return button
    }()

    lazy var saveButton: UXButton = {
        let button = UXButton()
        button.setImage(#imageLiteral(resourceName: "icons8-share_2"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        button.layer.cornerRadius = 20
        button.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        button.addTarget(self, action: #selector(saveImageTap), for: .touchUpInside)
        return button
    }()

    let textGradient: Gradient = {
        let gradient = Gradient()
        gradient.backgroundColor = .clear
        gradient.FirstColor = .clear
        gradient.SecondColor = UIColor(white: 0, alpha: 0.5)
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.clipsToBounds = true
        return gradient
    }()

    var textHeightConstraint: NSLayoutConstraint!
    var textBottomConstraint: NSLayoutConstraint!

    lazy var textView: UITextView! = {
        let view = UITextView()
        view.delegate = self
        view.returnKeyType = .next
        view.font = UIFont.systemFont(ofSize: 18)
        view.textColor = .white
        view.backgroundColor = .clear
        return view
    }()

    lazy var imageBottomConstraint: NSLayoutConstraint = {
        return imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    }()

    lazy var imageTrailingConstraint: NSLayoutConstraint = {
        return imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
    }()

    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()

    lazy var editTextViewTap: UITapGestureRecognizer! = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(shouldEditTextView))
        tap.delegate = imageView as? UIGestureRecognizerDelegate
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        return tap
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setNotificationCenter()
    }


    @objc func textTap(_ sender: UXButton) {

        if textGradient.alpha != 1 {

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {

                self.textGradient.alpha = 1

            })

        }

        textView.becomeFirstResponder()

    }


    @objc func scaleImage(_ gesture: UIPinchGestureRecognizer) {

        guard gesture.state == .began || gesture.state == .changed else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.imageView.transform = .identity
            })
            return
        }

        let scale = max(gesture.scale, 0.8)

        let center =  CGPoint(x: gesture.location(in: imageView).x - imageView.bounds.midX, y: gesture.location(in: imageView).y - imageView.bounds.midY)

        imageView.transform = CGAffineTransform(translationX: center.x, y: center.y).scaledBy(x: scale, y: scale).translatedBy(x: -center.x, y: -center.y)

    }

    @objc func saveImageTap(_ sender: UIButton) {

        print("gonna save this image")

    }


    @objc func submitTap(_ sender: UXButton) {

        guard let image = imageView.image else { return }

        sender.isEnabled = false

        let text = textView.text

        // TODO: when the add image funciton first runs, dissmiss the view controller and upload the image, have a little status animationg thing using the percentage

        ImageService.addImage(image,loc: "Memories", progressBlock: { (percentage) in
            print("uploading - ", percentage)
        }, completion: { (url, error) in

            if let url = url {
                MemoryService.createMemory(text: text!, imageUrl: url)
                self.dismissView(sender)
            }

            if let error = error {
                print("finished - ", error)
                sender.isEnabled = true
            }

            print("finished - ", error as Any)
            sender.isEnabled = true

        })

    }


    @objc func dismissView(_ sender: UXButton) {

        view.endEditing(true)

        self.dismiss(animated: sender == submitButton) // dismiss animated if an upadte was made to delay it kinda

    }

    @objc func shouldEditTextView() {

        if textView.isFirstResponder {
            textView.resignFirstResponder()
        } else {
            textView.becomeFirstResponder()
        }

    }



    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)

    }

}



// MARK ! - adjusting size for keyboard

extension PreviewVC: UITextViewDelegate {

    func adjustTextViewHeight() {

        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))

        guard newSize.height + 24 != textHeightConstraint.constant else { return }

        let diff = (newSize.height + 24) - textHeightConstraint.constant

        textHeightConstraint.constant = newSize.height + 24

        submitButtonBottomConstraint.constant = submitButtonBottomConstraint.constant - diff

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        })


    }


    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            view.endEditing(true)
            return false
        }

        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 90
    }

    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight()
    }


    func setNotificationCenter() {

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)

    }

    @objc func adjustForKeyboard(notification: Notification) {

        let userInfo = notification.userInfo!,
        keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue,
        keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {

            !textView.hasText ? textGradient.alpha = 0 : nil

            textBottomConstraint.constant = 0

            if textView.hasText, textHeightConstraint.constant > view.safeAreaInsets.bottom {
                let newConstant = -(textHeightConstraint.constant - view.safeAreaInsets.bottom)
                submitButtonBottomConstraint.constant = newConstant - 4
            } else {
                submitButtonBottomConstraint.constant = 0
            }


        } else {

            textGradient.alpha = 1
            textBottomConstraint.constant = -keyboardViewEndFrame.height
            submitButtonBottomConstraint.constant = -(keyboardViewEndFrame.height + textHeightConstraint.constant) - 4

        }


        UIView.animate(withDuration: 0.2, delay: 0,options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        })


    }





}


// MARK ! - adding views and constraints
// initial imageView setup

extension PreviewVC {


    func setupUI() {

        view.backgroundColor = .black
        view.tintColor = .white

        // tap gestures

        imageView.addGestureRecognizer(editTextViewTap)
        imageView.addGestureRecognizer(scaleImageGesture)

        textGradient.alpha = 0

        [imageView,dismissButton,textButton,submitButton, textGradient].forEach { view in
            self.view.addSubview(view)
        }

        textGradient.addSubview(textView)

        textView.translatesAutoresizingMaskIntoConstraints = false


        // if there are multiple subviews, enable autolayout this way

        view.subviews.forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
        }

        [dismissButton,submitButton,textButton].forEach { button in

            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 1
            button.layer.shadowRadius = 0.5
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.layer.shadowOffset = .zero

        }


        submitButtonBottomConstraint = submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))

        textHeightConstraint = textGradient.heightAnchor.constraint(equalToConstant: newSize.height + 24)
        textBottomConstraint = textGradient.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        let constraints: [NSLayoutConstraint] = [

            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dismissButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),

            textButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),

            submitButtonBottomConstraint,
            submitButton.trailingAnchor.constraint(equalTo: textButton.trailingAnchor, constant: -4),

            imageBottomConstraint,
            imageTrailingConstraint,

            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),

            textHeightConstraint,
            textBottomConstraint,
            textGradient.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            textGradient.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            textView.topAnchor.constraint(equalTo: textGradient.topAnchor, constant: 8),
            textView.bottomAnchor.constraint(equalTo: textGradient.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: textGradient.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: textGradient.trailingAnchor)

        ]

        NSLayoutConstraint.activate(constraints)

    }

}
