//
//  MediaViewController.swift
//  logRegTest
//
//  Created by jed on 10/25/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit
import AVKit
import FirebaseFirestore
import FirebaseUI

class MediaViewController: UIViewController  {

    @IBOutlet var profileImageView: UIImageView!
    var dismissProfileImageFrame: CGRect!, profileImageViewToReset: UIImageView!
    var hasProfileImage: Bool!

    @IBOutlet weak var imageView: UIImageView!
    var dismissImageFrame: CGRect!, imageViewToReset: UIImageView!

    @IBOutlet weak var userNameLabel: UILabel!
    var dismissLabelFrame: CGRect!, labelToReset: UILabel!

    @IBOutlet weak var timeStampLabel: UILabel!

    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!

    var textView: Gradient!


    @IBOutlet var imagePanGesture: UIPanGestureRecognizer!

    var show: Bool = true

    var memory: Memory!

    var author: User!

    var usersLike: DocumentReference? { // CHANGE THIS TO USERS UID !
        didSet {
            likeButton.tintColor = usersLike == nil ? .gray : #colorLiteral(red: 1, green: 0, blue: 0.3808195591, alpha: 0.6968642979)
        }
    }

    private var listener: ListenerRegistration!

    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("Memories").document(memory.id).collection("Likes")
    }

    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
            }
        }
    }

    deinit {
        listener?.remove()
    }

    lazy var userNameTapGesture: UITapGestureRecognizer! = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(showProfile))
        gesture.numberOfTapsRequired = 1
        return gesture
    } ()

    lazy var profileImageTapGesture: UITapGestureRecognizer! = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(showProfile))
        gesture.numberOfTapsRequired = 1
        return gesture
    } ()

    lazy var imageTapGesture: UITapGestureRecognizer! = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        gesture.numberOfTapsRequired = 1
        gesture.delegate = imageView as? UIGestureRecognizerDelegate
        return gesture
    } ()


    var deleteButton: UXButton!
    var didDeleteMemory: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()

        [userNameLabel,likeLabel,timeStampLabel].forEach { label in
            label.text = ""
        }

        userNameLabel.textAlignment = .center
//        userNameLabel.backgroundColor = .green

        timeStampLabel.font = UIFont.systemFont(ofSize: 16)

        imageView.backgroundColor = .clear
        imageView.addGestureRecognizer(imageTapGesture)

        likeButton.tintColor = .gray

        profileImageView.layer.cornerRadius = profileImageView.frame.height/2

        [imageView,profileImageView].forEach { image in
            image?.clipsToBounds = true
            image?.contentMode = .scaleAspectFill
            image?.backgroundColor = .clear
        }


        view.backgroundColor =  UIColor(white: 0, alpha: 1)


    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if author == nil {

            observeUser()

        } else {

            userNameLabel.text = author.userName

            if !hasProfileImage, author.profileImage != nil {

                self.getUserImage()

            }

        }


        setupMemory()

        if let label = self.labelToReset { // just gets the font style

            let size = userNameLabel.font.pointSize
            userNameLabel.font = label.font.withSize(size)

        }

    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        imagePanGesture.isEnabled = true

    }

/* LOGIC */

    func setupMemory() {

        userNameLabel.isUserInteractionEnabled = true
        timeStampLabel.text = memory.createdAt.calenderTimeSinceNow()

        if memory.text != nil {
            setupTextLabel()
        }

        MemoryService.getLikes(with: memory.ref!, completion: { (likes) in

            if let likes = likes {

                self.memory.likes = likes
                self.likeLabel.text = String(likes.count)

            } else { // no likes

                self.likeLabel.text = "0"

            }

        }) { (usersLike) in

            if let like = usersLike {

                self.usersLike = like

            }

        }

    }


    func observeUser() {

        UserService.findOrObserve(memory.author) { (user) in

            self.author = user
            self.userNameLabel.text = user.userName

            if user.profileImage != nil {

                self.getUserImage()

            }

        }

    }

    func getUserImage() {

        let ref = Storage.storage().reference(forURL: author.profileImage!)
        self.profileImageView.sd_setImage(with: ref, placeholderImage: nil)

    }


    func setupTextLabel() {

        guard let text = memory.text else { return }

        textView = Gradient()
        textView.FirstColor = UIColor.init(white: 0, alpha: 0)
        textView.SecondColor = UIColor.init(white: 0, alpha: 0.67)
        textView.startPoint = CGPoint(x: 0, y: 0)
        textView.endPoint = CGPoint(x: 0, y: 1)
        textView.translatesAutoresizingMaskIntoConstraints = false
//        textView.backgroundColor = .clear

        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.numberOfLines = 0
        textLabel.textColor = .white
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.textAlignment = .left
        textLabel.text = text

        view.addSubview(textView)
        textView.addSubview(textLabel)

        let fixedWidth = view.frame.size.width,
        newSize = textLabel.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))

        let constraints: [NSLayoutConstraint] = [

            textView.heightAnchor.constraint(equalToConstant: newSize.height*1.5),
            textView.widthAnchor.constraint(equalToConstant: view.frame.width),
            textView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),

            textLabel.bottomAnchor.constraint(equalTo: textView.bottomAnchor),
            textLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 4),
            textLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -4),

        ]

        NSLayoutConstraint.activate(constraints)

    }





    @objc func showProfile() {

        VCService.presentSelfVC(user: author, fromVC: self, with: profileImageView, transitionFrame: profileImageView.frame)

    }


    @IBAction func likeButtonTap(_ sender: UIButton) { // add the error messsages to the completion

        guard let ref = memory.ref else { return }

        if let likeRef = usersLike {
            MemoryService.unlike(with: likeRef) { (completion) in
                self.usersLike = completion
            }
        } else {
            MemoryService.like(with: ref) { (usersLike) in
                self.usersLike = usersLike
                self.animateLikeButton()
            }
        }

        animateLikeButton()

    }




    func setupDelete() {

        deleteButton = UXButton()
        view.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

        deleteButton.tintColor = .red
        deleteButton.setImage(#imageLiteral(resourceName: "icons8-delete_filled"), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteTap), for: .touchUpInside)

        let contraints: [NSLayoutConstraint] = [

            deleteButton.topAnchor.constraint(equalTo: likeButton.topAnchor, constant: 0),
            deleteButton.widthAnchor.constraint(equalTo: likeButton.widthAnchor, multiplier: 1),
            deleteButton.heightAnchor.constraint(equalTo: likeButton.heightAnchor, multiplier: 1),
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4)

        ]

        NSLayoutConstraint.activate(contraints)

    }



    @objc func deleteTap() {

        guard memory.author == UserService.currUser.uid else { return }

        let message = "if you delete this memory you won't be able to get it back"

        let alert = UIAlertController(title: "are you sure?", message: message, preferredStyle: .alert)

        let delete = UIAlertAction(title: "delete", style: .destructive) { (action) in

            self.deleteMemory()

        }

        let cancel = UIAlertAction(title: "cancel", style: .cancel)

        [delete,cancel].forEach { action in
            alert.addAction(action)
        }

        self.present(alert, animated: true)


    }


    func deleteMemory() {

        MemoryService.delete(with: memory.ref!) { (error) in

            if let error = error {

                print(error)

            } else {

                self.didDeleteMemory = true
                self.dismissView()

            }

        }

    }


/* ANIMATIONS */

    @objc func imageTap(_ sender: UITapGestureRecognizer) {
        show = !show
        show ? showViews() : hideViews(animated: true, hideUser: true)
    }

    func animateLikeButton() {

        let color: UIColor!

        if usersLike != nil {
            color = #colorLiteral(red: 1, green: 0, blue: 0.3808195591, alpha: 0.6968642979)
        } else {
            color = .gray
        }

        self.likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        UIView.animate(withDuration: 0.333, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.3, options: [.allowUserInteraction], animations: {
            self.likeButton.tintColor = color
            self.likeButton.transform = CGAffineTransform.identity
        }, completion: nil)

    }


    @IBAction func followButtonTap(_ sender: Any) {

//        guard UserService.following?.contains(author.uid) ?? false else {
//
//            UserService.follow(user: author) { (error) in
//                if let error = error {
//                    print("ERROR - \(error.localizedDescription)")
//                } else {
//                    self.followButton.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: .selected)
//                    self.followButton.setTitle("remove -", for: .selected)
//                    self.followButton.isSelected = true
//                }
//            }
//            return
//        }
//
//        UserService.unFollow(user: author) { (error) in
//            if let error = error {
//                print("ERROR - \(error.localizedDescription)")
//            } else {
//                self.followButton.isSelected = false
//            }
//        }

    }


    @IBAction func panImage(_ sender: UIPanGestureRecognizer) {

        let point = sender.translation(in: view)

        if sender.state == .changed, point.y > 2 {
            sender.isEnabled = false
            dismissView()
        }

    }




    func showViews() {

        // main things
        let duration:Double = 0.2
        let delay = 0.05

        // upper views
        var i: Double = 0

        for view in [profileImageView,userNameLabel,timeStampLabel] {
            UIView.animate(withDuration: duration, delay: i, options: .curveEaseInOut, animations: {
                view?.transform = .identity
                view?.alpha = 1
            })
            i += delay
        }


        // lower views
        var j: Double = 0

        for view in [deleteButton,likeLabel,likeButton] {
            UIView.animate(withDuration: duration, delay: j, options: .curveEaseInOut, animations: {
                view?.transform =  .identity
                view?.alpha = 1
            })
            j += delay
        }


        // there isn't always text
        if let textView = textView {
            UIView.animate(withDuration: duration) {
                textView.transform = self.likeButton.transform
                textView.alpha = 1
            }
        }


    }


    func hideViews(animated: Bool, hideUser: Bool) {

        // main things
        let duration:Double = animated ? 0.2 : 0
        let delay = 0.05
        let Y = profileImageView.frame.height

        // upper views
        var topViews:[UIView] = [timeStampLabel]

        if hideUser || profileImageViewToReset == nil {
            topViews.insert(profileImageView, at: 0)
        }

        if hideUser || labelToReset == nil {
            topViews.insert(userNameLabel, at: 1)
        }

        var i: Double = 0

        for view in topViews {

            UIView.animate(withDuration: duration, delay: i, options: .curveEaseInOut, animations: {

                view.transform = CGAffineTransform(translationX: 0, y: -Y)
                view.alpha = 0

            })

            if animated {
                i += delay
            }

        }


        // lower views
        var j: Double = 0

        for view in [deleteButton,likeLabel,likeButton] {

            UIView.animate(withDuration: duration, delay: j, options: .curveEaseInOut, animations: {

                view?.transform =  CGAffineTransform(translationX: 0, y: Y)
                view?.alpha = 0

            })

            if animated {
                j += delay
            }

        }

        if let textView = textView {
            UIView.animate(withDuration: duration) {
                textView.transform = self.likeButton.transform
                textView.alpha = 0
            }
        }


    }



    // animates the frames

    func dismissView() {

        hideViews(animated: true, hideUser: false)

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

            // set alphas to 0 if there isnt a dismiss frame to animate

            // set the alphas to 1 if they're hidden and need to animate

            // profile image
            if let profileImageViewToReset =  self.profileImageViewToReset {
                self.profileImageView.alpha = 1
                self.profileImageView?.frame = self.dismissProfileImageFrame
                self.profileImageView?.layer.cornerRadius = profileImageViewToReset.layer.cornerRadius
            } else {
                self.profileImageView.alpha = 0
            }


            // label
            if let labelFrame = self.dismissLabelFrame {

//                self.userNameLabel.backgroundColor = .blue
                self.userNameLabel.alpha = 1
                self.userNameLabel.frame = labelFrame
                self.userNameLabel.textColor = self.labelToReset.textColor

                let scale = self.labelToReset.font.pointSize / self.userNameLabel.font.pointSize

                let transform = self.userNameLabel.transform.scaledBy(x: scale, y: scale)

                self.userNameLabel.transform = transform

            } else {
                self.userNameLabel.alpha = 0
            }

            // image
            if !self.didDeleteMemory {
                self.imageView.frame = self.dismissImageFrame
                self.imageView.layer.cornerRadius = self.imageViewToReset.layer.cornerRadius
            } else {
                self.imageView.alpha = 0
            }



            self.textView?.transform = self.likeLabel.transform
            self.textView?.alpha = 0

            self.view.backgroundColor = .clear

        }) { (completion) in

            self.resetSenderViewController()

            self.dismiss(animated: false)

        }

    }


    func resetSenderViewController() {

        labelToReset?.text = userNameLabel?.text

        profileImageViewToReset?.image = profileImageView.image

        if !didDeleteMemory {

            imageViewToReset.image = imageView.image

        }


    }


    func resetView() {

        UIView.animate(withDuration: 0.2, animations: {

            self.imageView.transform = .identity
            self.textView?.transform = .identity
            self.view.backgroundColor = UIColor(white: 0, alpha: 1)

        })

        showViews()
        show = true

    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NavView.fadeNav(toAlpha: 1)

        // this is cool
        // rn if you open the mediaViewController and then the selfViewController, then dismiss the selfVC, the navView will show back up, which would normally be fine if there was only one controller to dismiss

    }



}

