//
//  ConvoVC.swift
//  logRegTest
//
//  Created by jed on 11/1/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit
import FirebaseFirestore


struct SelectedConvo {
    var convo: Convo,
    members: [User],
    userLabel: String
}


class ConvoVC: UIViewController, UITableViewDelegate, UITextViewDelegate {

    var newConvo: Bool = false

    // rn there are only two possible senders so I used a bool
    var sentFromMessages: Bool!

    var selectedConvo: SelectedConvo! {
        didSet {
            guard !newConvo, selectedConvo.convo.ref != nil else { return }
            self.query = baseQuery()
            loadMessages()
        }
    }

    var listener: ListenerRegistration!
    func baseQuery() -> Query {
        return Firestore.firestore().collection("Convos")
    }

    var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
            }
        }
    }

    deinit {
        if let listener = listener {
            listener.remove()
        }
    }

    var messages: [[Message]] = []

    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var convoBanner: UIView!
    @IBOutlet weak var messageView: UITableView!

    var lastIndexPath: IndexPath! {
        get {
            return IndexPath(row: messages[messages.count - 1].count - 1, section: messages.count - 1)
        }
    }

    let inset: UIEdgeInsets = UIEdgeInsets(top: 45, left: 0, bottom: 44, right: 0)

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!

    let textView: UITextView! = {
        let textView = UITextView()
        textView.textColor = .black
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textContainerInset.left = 4
        textView.textContainerInset.right = 4
        textView.backgroundColor = #colorLiteral(red: 1, green: 0.5212877989, blue: 0, alpha: 1)
        textView.layer.masksToBounds = false
        textView.layer.shadowOpacity = 0.4
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowRadius = 3
        textView.layer.shadowOffset = .zero
        textView.keyboardDismissMode = .none
        textView.returnKeyType = .send
        textView.enablesReturnKeyAutomatically = true
        textView.isScrollEnabled = false
        textView.keyboardAppearance = .default
        return textView
    }()

    let smallTextViewColor: UIColor = #colorLiteral(red: 1, green: 0.5212877989, blue: 0, alpha: 1)

    let smallTextViewSize: CGSize! = {
        return CGSize(width: 44, height: 44)
    }()

    var textViewBottomConstraint: NSLayoutConstraint!
    var textViewHeightConstraint: NSLayoutConstraint!
    var textViewWidthConstraint: NSLayoutConstraint!

    var lastTextViewHeight: CGFloat = 44
    var wasScrollEnabled: Bool = false

    let textViewImage: UIImageView! = {
        let image = UIImageView(image: #imageLiteral(resourceName: "addIcon"))
        image.tintColor = .white
        image.backgroundColor = .clear
        image.clipsToBounds = true
        return image
    }()


    lazy var screenEdgePan: UIScreenEdgePanGestureRecognizer! = {
        let pan = UIScreenEdgePanGestureRecognizer()
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        pan.edges = .left
        pan.delegate = view as? UIGestureRecognizerDelegate
        pan.addTarget(self, action: #selector(handScreenPan))
        return pan
    }()

    lazy var endEditingTap: UITapGestureRecognizer! = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(shouldEndEditing))
        tap.numberOfTapsRequired = 1
        tap.delegate = self.view as? UIGestureRecognizerDelegate
        return tap
    }()


    var keyboardHeight: CGFloat!

    let messageCellID: String = "MessageCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        setupConstraints()

        if sentFromMessages {
            textView.layer.cornerRadius = NavView.cameraButtonFrame.width/2
            setTextViewForCameraButton()
        }

        backButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        userNameLabel.text = ""

        adjustTextViewHeight()

        view.addGestureRecognizer(endEditingTap)
        view.addGestureRecognizer(screenEdgePan)
        view.backgroundColor = .white

        textView.delegate = self

        messageView.register(MessageCell.self, forCellReuseIdentifier: messageCellID)
        messageView.backgroundColor = view.backgroundColor
        messageView.contentInset = inset
        messageView.keyboardDismissMode = .none


        [userNameLabel,infoButton,backButton,messageView].forEach {

            $0?.layer.masksToBounds = false
            $0!.layer.shadowOpacity = 1
            $0!.layer.shadowColor = UIColor.black.cgColor
            $0!.layer.shadowRadius = 0.5
            $0!.layer.shadowOffset = .zero

        }


        userNameLabel.layer.shadowRadius = 0.8

        [backButton,infoButton].forEach {
            $0?.contentVerticalAlignment = .fill
            $0?.contentHorizontalAlignment = .fill
            $0?.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }


        setNotificationCenter()

        guard selectedConvo != nil else { return }
        userNameLabel.text = selectedConvo.userLabel

    }




    @objc func shouldEndEditing(_ tap: UITapGestureRecognizer) {

        view.endEditing(isEditing)

    }



    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        if (text == "\n") { // return key - send key
            self.sendMessage()
            return false // keeps the return key from making a new line
        }
        
        return true
    }


    func textViewDidChange(_ textView: UITextView) {

        self.adjustTextViewHeight()
    }


    func adjustTextViewHeight() { // also does width if you want

        let fixedWidth = textView.frame.size.width,
            newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)),
            newHeight = newSize.height

        guard newHeight != textViewHeightConstraint.constant, newHeight < (view.bounds.height / 6) else {
            textView.isScrollEnabled = newHeight >= (view.bounds.height / 6)
            return
        }


        textView.isScrollEnabled = false

        lastTextViewHeight = newHeight

        if textView.frame.width == view.frame.width {

            textViewHeightConstraint.constant = newSize.height

        }

        if keyboardHeight != nil {
            messageView.contentInset.bottom = (textViewHeightConstraint.constant + keyboardHeight) - 30 // <- IDK
            self.scrollToBottom(animated: true)
        }

        self.view.layoutIfNeeded()

    }



    func newConvoMessage(message: Message) {

        let members: [String] = selectedConvo.members.map { $0.uid }

        ConvoService.newConvo(members: members, message: message) // return the ref

        self.newConvo = false
        // add completion block to return the convo ref and stuff // rn it just stays in an empty screen
        // temporarily, ill just close this as soon as its sent tho

        textView.text = nil
        adjustTextViewHeight()

    // temporary
        self.dismiss(animated: true)

    }


    @objc func sendMessage() {

        guard let sender = UserService.currUser.uid, !textView.text.isEmpty else { return }

        let message = Message(id: nil, sender: sender, content: textView.text, createdAt: Date())

        guard !newConvo, selectedConvo.convo.ref != nil else {
            newConvoMessage(message: message)
            return
        }


        ConvoService.newMessage(docRef: selectedConvo.convo.ref, message: message)
        // add a completion block for when the message is sent

        textView.text = ""
        adjustTextViewHeight()


    }



    @IBAction func infoButtontap(_ sender: UIButton) {

        print("info does nothing")

    }


    @objc func handScreenPan(_ pan: UIScreenEdgePanGestureRecognizer) {

        guard let view = sentFromMessages ? messageView : self.view else { return }

        let translation = pan.translation(in: view)

//        view.center.x = translation.x

        view.transform = CGAffineTransform(translationX: translation.x , y: 0)

        let alpha = 1 - (translation.x * 0.005)

        self.view.backgroundColor = UIColor.init(white: 1, alpha: alpha)


        func resetForPanGesture() {

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {

                view.transform = .identity

                self.view.backgroundColor = self.messageView.backgroundColor

            })

        }


        if pan.state == .ended {

            translation.x > 100 ? closeTapped(pan) : resetForPanGesture()

        }


    }







    @objc func closeTapped(_ sender: Any) {

        view.endEditing(true)

        let translation = view.frame.width/2

        let viewToTranslate = sentFromMessages ? messageView : view

        if sentFromMessages {

            setTextViewForCameraButton()

        }


        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {

            self.view.layoutIfNeeded()
            self.view.alpha = 0

            viewToTranslate?.center.x += translation

            if self.sentFromMessages {

                self.textView.layer.cornerRadius = NavView.cameraButtonFrame.width/2

            }

        }) { (completion) in

            self.dismiss(animated: false)

        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }


}


// constraints

extension ConvoVC {

    func setupConstraints() {


        textView.translatesAutoresizingMaskIntoConstraints = false
        textViewImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        textView.addSubview(textViewImage)

        textViewWidthConstraint = textView.widthAnchor.constraint(equalToConstant: 44)
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: 44)

        textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -smallTextViewSize.height)

        NSLayoutConstraint.activate([

            textViewWidthConstraint,
            textViewHeightConstraint,
            textViewBottomConstraint,
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            textViewImage.widthAnchor.constraint(equalToConstant: 22),
            textViewImage.heightAnchor.constraint(equalToConstant: 22),
            textViewImage.centerXAnchor.constraint(equalTo: textView.centerXAnchor),
            textViewImage.centerYAnchor.constraint(equalTo: textView.centerYAnchor)

        ])

        textView.layer.cornerRadius = smallTextViewSize.width/2

    }


    func setTextViewToSmallSize() {

        [textViewWidthConstraint,textViewHeightConstraint].forEach { constraint in
            constraint?.constant = smallTextViewSize.width
        }

        textViewBottomConstraint.constant = -smallTextViewSize.height

//        textView.layer.cornerRadius = smallTextViewSize.width/2

    }



    // makes the textview have the same dimentions and position of the camera button

    func setTextViewForCameraButton() {

        let width = NavView.cameraButtonFrame.width

        textViewWidthConstraint.constant = width
        textViewHeightConstraint.constant = width

        textViewBottomConstraint.constant = -32 // works but I don't like it

//        textView.layer.cornerRadius = width/2

    }


}
