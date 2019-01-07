//
//  SelfViewController.swift
//  logRegTest
//
//  Created by jed on 10/25/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseFirestore
import FirebaseStorage


class SelfViewController: UIViewController {

    var primaryVC: Bool!

    var count: Int = 1

    var user: User! {
        didSet {
            count += 1
            print("set data this many times", count)
        }
    }

    var userImage: UIImage!

    @IBOutlet var userCard: StretchView!


    lazy var profileImageCenterXConstraint: NSLayoutConstraint = {
        return profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    }()

    @IBOutlet var profileImageBottomConstraint: NSLayoutConstraint!


    lazy var userNameLabelBottomConstraint: NSLayoutConstraint = {
        return userNameLabel.bottomAnchor.constraint(equalTo: userCard.bottomAnchor, constant: highUserNameLabelBottomConstraintConstant)
    }()

    lazy var userNameLabelCenterX: NSLayoutConstraint! = {
        return userNameLabel.centerXAnchor.constraint(equalTo: userCard.centerXAnchor)
    }()

    lazy var userNameLabelLeadingConstraint: NSLayoutConstraint! = {
        return userNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: menuButton.frame.width + 8)
    }()

    lazy var highUserNameLabelBottomConstraintConstant: CGFloat! = {
        return -(view.frame.height/3)
    }()


    @IBOutlet weak var profileImage: UIImageView!

    var frameForDismiss: CGRect!, imageViewToReset: UIImageView!

    lazy var profileImageTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.numberOfTapsRequired = 2
        gesture.delegate = profileImage as? UIGestureRecognizerDelegate
        gesture.addTarget(self, action: #selector(adjustOffsetUp))
        return gesture
    }()


    @IBOutlet weak var userNameLabel: UILabel!

    var bioLabel: UILabel!
    var followButton: UXButton!, dismissButton: UXButton!, messageButton: UXButton!

    @IBOutlet var profileImageTopConstraint: NSLayoutConstraint!
    var memories: [Memory] = []
    @IBOutlet weak var collectionView: UICollectionView!
    var flowLayout: UICollectionViewFlowLayout!
    var gridLayout: GridLayout!

    // MENU
    @IBOutlet var menuBlurView: UIVisualEffectView!
    @IBOutlet var menuView: UIView!
    @IBOutlet var menuButton: DesignableButton!
    lazy var menuWidth: CGFloat = {
        return menuView.frame.width
    }()

    @IBOutlet var closeMenu: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var friendsButton: UIButton!
    @IBOutlet var addUserButton: UIButton!


    let cellID: String = "MediaCell"

    var listener: ListenerRegistration!

    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("Memories")
    }

    var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
            }
        }
    }

    deinit {
        listener.remove()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        closeMenuView(duration: 0)
        setup()

        setUpUserData()
        observeUser()

        optionalSetup()
        self.query = baseQuery()
        loadMemories()

    }

    func setup() {

        [profileImageCenterXConstraint,
         userNameLabelBottomConstraint,
         userNameLabelLeadingConstraint].forEach { constraint in
                constraint?.isActive = true
            }


        userNameLabel.text = ""
        userNameLabel.font = UIFont.systemFont(ofSize: 28)
        userNameLabel.adjustsFontSizeToFitWidth = true
        userNameLabel.adjustsFontForContentSizeCategory = true
        userNameLabel.minimumScaleFactor = 0.2
        //        userNameLabel.backgroundColor = .red // so i can see wtf is going on

        userCard.backgroundColor = #colorLiteral(red: 1, green: 0.5212877989, blue: 0, alpha: 1) // temporary

        userCard.FirstColor = .clear // couljdnt get the animation to not look jumpy
        userCard.SecondColor = .clear // really upset

        userCard.clipsToBounds = false // allows the profile image to animate properly on dismiss
        userCard.fullHeight = view.frame.height
        userCard.bottomConstraint = userCard.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        userCard.bottomConstraint.isActive = true
        userCard.setupForController()

        gridLayout = GridLayout(numberOfColumns: 3, cellPadding: 0.5)
        collectionView.collectionViewLayout = gridLayout

        flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout!.sectionInset = UIEdgeInsets(top: view.frame.height, left: 0, bottom: 60, right: 0)
        flowLayout?.invalidateLayout()

        collectionView.backgroundColor = .white
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true

        profileImageTopConstraint.constant = 0 // different from storyBoard

        profileImage.backgroundColor = .clear
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = (userCard.mediumHeight-view.safeAreaInsets.top)/2 // so proud

//        profileImage.layer.cornerRadius = (userCard.mediumHeight-profileImageTopConstraint.constant)/2 // so proud

        [profileImage,userNameLabel].forEach { view in
            view!.layer.shadowOpacity = 1
            view!.layer.shadowColor = #colorLiteral(red: 0.1877565682, green: 0.1910342872, blue: 0.2052289844, alpha: 0.6705639983)
            view!.layer.shadowRadius = 2
            view!.layer.shadowOffset = CGSize(width: 0, height: 1)
        }



//        MotionEffect.addDeviceTilt(toView: userNameLabel, magnitude: 5)


    }



    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        profileImage.addGestureRecognizer(profileImageTapGesture)
        profileImage.isUserInteractionEnabled = true

    }

    func observeUser() {

        UserService.observe(user.uid) { (user) in

            if user != nil {
                self.user = user!
                self.setUpUserData()
            }
        }

    }


    func setUpUserData() {

        userNameLabel.text = user.userName // has been nil twice // only when the app wasnt open
        user.bio != nil ? setupBioLabel() : nil

        if let image = userImage {
            profileImage.image = image
        }

        guard profileImage.image == nil else { return }

        if let imageUrl = user.profileImage {

            if primaryVC == true {

                profileImage.image = UserService.getCurrUserImage()

            } else {

                let ref = Storage.storage().reference(forURL: imageUrl)
                profileImage.sd_setImage(with: ref, placeholderImage: nil)

            }
        }


    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NavView.fadeNav(toAlpha: 1)
    }


}


extension SelfViewController { // optional things

    func optionalSetup() {

        if primaryVC == true {

            // show the buttons

            menuBlurView.isUserInteractionEnabled = true

        } else {

            dismissButton = UXButton(frame: menuButton.frame)

            menuBlurView.removeFromSuperview()
            menuButton.removeFromSuperview()

            dismissButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            dismissButton.tintColor = .white
            dismissButton.backgroundColor = .clear
            dismissButton.setImage(#imageLiteral(resourceName: "leftArrowIcon"), for: .normal)
            dismissButton.addTarget(self, action: #selector(dismissButtonTap), for: .touchUpInside)
            dismissButton.layer.shadowOpacity = 1
            dismissButton.layer.shadowRadius = 0.7
            dismissButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            dismissButton.layer.shadowOffset = .zero
            view.addSubview(dismissButton)

            guard UserService.currUser.uid != user.uid else { return }

            followButton = UXButton()

            messageButton = UXButton()

            followButton.alpha = 0
            followButton.isEnabled = false

            followButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)

            followButton.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: .disabled)
            followButton.setTitle("hold up . . .", for: .disabled)

            followButton.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: .selected)
            followButton.setTitle("remove -", for: .selected)

            followButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            followButton.setTitle("add +", for: .normal)

            followButton.addTarget(self, action: #selector(followButtonTap), for: .touchUpInside)

            followButton.layer.cornerRadius = 13
            followButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            followButton.layer.borderWidth = 0.2
            followButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

            followButton.isSelected = UserService.following?.contains(user.uid) ?? false
            followButton.isEnabled = true

            messageButton.setImage(#imageLiteral(resourceName: "newMessageIcon"), for: .normal)
            messageButton.addTarget(self, action: #selector(messageButtonTap), for: .touchUpInside)
            messageButton.layer.shadowOpacity = 1
            messageButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.7208369007)
            messageButton.layer.shadowRadius = 0.7
            messageButton.layer.shadowOffset = .zero

            [followButton,messageButton].forEach { button in
                userCard.addSubview(button!)
                button?.translatesAutoresizingMaskIntoConstraints = false
            }


            let constraints: [NSLayoutConstraint] = [

                messageButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                messageButton.widthAnchor.constraint(equalToConstant: 30),
                messageButton.heightAnchor.constraint(equalToConstant: 30),
                messageButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),

                followButton.topAnchor.constraint(equalTo: messageButton.topAnchor),
                followButton.heightAnchor.constraint(equalToConstant: 26),
                followButton.trailingAnchor.constraint(equalTo: messageButton.leadingAnchor, constant: -4),


            ]


            NSLayoutConstraint.activate(constraints)

        }

    }

    func setupBioLabel() {

        guard bioLabel == nil else { // if the label has been set up but the bio chaged
            bioLabel.text = user.bio
            return
        }

        bioLabel = UILabel()
        bioLabel.text = ""
        view.insertSubview(bioLabel, belowSubview: menuBlurView)
        bioLabel.translatesAutoresizingMaskIntoConstraints = false

        let constraints: [NSLayoutConstraint] = [

            bioLabel.widthAnchor.constraint(lessThanOrEqualToConstant: view.frame.width*0.8),
            bioLabel.topAnchor.constraint(equalTo: userNameLabel.topAnchor, constant: userNameLabel.frame.height*2),
            bioLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor)


        ]

        NSLayoutConstraint.activate(constraints)

        bioLabel.numberOfLines = 0

        bioLabel.textAlignment = .left

        bioLabel.font = userNameLabel.font.withSize(19)
        bioLabel.textColor = userNameLabel.textColor

        bioLabel.layer.shadowOpacity = 1
        bioLabel.layer.shadowColor = #colorLiteral(red: 0.1877565682, green: 0.1910342872, blue: 0.2052289844, alpha: 0.6705639983)
        bioLabel.layer.shadowRadius = 2
        bioLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        bioLabel.text = user.bio!

        MotionEffect.addDeviceTilt(toView: bioLabel, magnitude: 2.5)

    }

    @objc func dismissButtonTap(button: UIButton) {

        guard primaryVC != true else { return }

        view.isUserInteractionEnabled = false

        let duration: Double = 0.3

        hideViewsForTransition(animated: true)

        setMainViewsClear(duration*0.9)

        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {

            // README ! - if the imageView.frame goes outside the userCard then it dissapears
            self.profileImage.frame = self.frameForDismiss

            // assuming you want a circle, I might change this later
            self.profileImage.layer.cornerRadius = self.frameForDismiss.width/2

        }) { (completion) in

            if let imageViewToReset = self.imageViewToReset {

                imageViewToReset.image = self.profileImage.image

            }

            self.dismiss(animated: false)

        }


    }



    func setMainViewsClear(_ x: Double) {

        UIView.animate(withDuration: x, delay: 0, options: .curveEaseInOut, animations: {

            self.userCard.backgroundColor = .clear
            self.view.backgroundColor = .clear
            self.collectionView.alpha = 0

        })

    }



    func hideViewsForTransition(animated: Bool) {

        let duration: Double = animated ? 0.2 : 0

        var i: Double = 0

        for view in [userCard.profileImageGradient,userNameLabel,bioLabel,dismissButton,followButton,messageButton] {

            let Y = userNameLabel.frame.height
            let transform = CGAffineTransform(translationX: 0, y: view is UIButton ? -Y : Y)

            UIView.animate(withDuration: duration, delay: i, options: .curveEaseInOut, animations: {

                view?.transform = transform
                view?.alpha = 0

            })

            // do delay
            if animated {
                i += 0.05
            }

        }

        print("total transition time is like", i + duration, " or something")

    }




    func showViewsForTransition() {

        var i: Double = 0

        for view in [userCard.profileImageGradient,userNameLabel,bioLabel,dismissButton,messageButton] {

            UIView.animate(withDuration: 0.2, delay: i, options: .curveEaseInOut, animations: {

                view?.transform = .identity
                view?.alpha = 1

            })

            i += 0.05

        }

        followButton?.transform = .identity

    }



    @objc func messageButtonTap(button: UIButton) {

        ConvoService.checkIfExists(users: [UserService.currUser.uid, user.uid]) { convo in

            VCService.presentConvoVC(users: [UserService.currUser, self.user], fromVC: self, convo: convo)

        }

    }

    @objc func followButtonTap(button: UIButton) {

        guard UserService.following?.contains(user.uid) ?? false else {
            UserService.follow(user: user) { (error) in
                if let error = error {
                    print("ERROR - \(error.localizedDescription)")
                } else {
                    self.followButton.isSelected = true
                }
            }
            return
        }

        UserService.unFollow(user: user) { (error) in
            if let error = error {
                    print("ERROR - \(error.localizedDescription)")
            } else {
                self.followButton.isSelected = false
            }
        }
    }







}


/* MARK -  scroll adjusting things  */
// very many things are going on here

extension SelfViewController: UICollectionViewDelegate {

/* I want this to work so badly but it adjusts improperly, always, every time */

//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        if userCard.mediumHeightSet && profileImage.frame.width >= view.frame.width * 0.8 {
//            adjustOffsetUp()
//        }
//    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        profileImageTapGesture.isEnabled = false
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        profileImageTapGesture.isEnabled = true
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        userCard.adjustConstraints(offset: collectionView.contentOffset.y)

        if userCard.frame.height == userCard.smallHeight && profileImage.layer.cornerRadius != profileImage.frame.height/2 {
            UIView.animate(withDuration: 0.3) {
                self.profileImage.layer.cornerRadius = self.profileImage.frame.height/2
            }
        }

    }


    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        userCard.adjustsView ? adjustOffsetDown() : nil

        if userCard.mediumHeightSet {

            profileImage.layer.cornerRadius = profileImage.frame.height/2

        }

    }



    func adjustOffsetDown() {

        UIView.animate(withDuration: 0.2) {
            self.bioLabel?.alpha = 0
            self.userCard.profileImageGradient.alpha = 0
        }

        profileImageTopConstraint.constant = view.safeAreaInsets.top
        profileImageBottomConstraint.constant = userNameLabel.frame.height

        userNameLabelBottomConstraint.constant = -4
        userNameLabelLeadingConstraint.isActive = false
        userNameLabelCenterX.isActive = true

        UIView.animate(withDuration: 0.5, delay: 0.1, options: [.curveEaseInOut,.layoutSubviews], animations: {

            self.view.layoutIfNeeded()
            self.collectionView.contentInset.top = -(self.userCard.mediumHeight * 2)
            self.userNameLabel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7) // this does cause issues when animating frames
            self.followButton?.alpha = 1

        })

    }

    @objc func adjustOffsetUp() {

        collectionView.contentInset.top = 0 // I hate it
        collectionView.setContentOffset(CGPoint(x: self.collectionView.contentOffset.x, y: -self.view.safeAreaInsets.top), animated: true) // hate this too

        profileImageTopConstraint.constant = 0
        profileImageBottomConstraint.constant = 0

        userNameLabelLeadingConstraint.isActive = true
        userNameLabelCenterX.isActive = false
        userNameLabelBottomConstraint.constant = highUserNameLabelBottomConstraintConstant

        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .layoutSubviews], animations: {

            self.view.layoutIfNeeded()
            self.userNameLabel.transform = .identity
            self.followButton?.alpha = 0
            self.bioLabel?.alpha = 1
            self.userCard.profileImageGradient.alpha = 1

        })

        userCard.mediumHeightSet = false

    }

}



// MARK! - menu actions

extension SelfViewController {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard primaryVC == true, menuView.transform == .identity else { return }
        touches.first?.view != menuView ? closeMenuView(duration: 0.3) : nil

    }


    @IBAction func menuTap(_ sender: Any) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.menuBlurView.alpha = 1
            self.menuView.transform = .identity
        })
    }

    @IBAction func closeMenuTap(_ sender: Any) {
        closeMenuView(duration: 0.3)
    }

    func closeMenuView(duration: Double) {
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            self.menuBlurView?.alpha = 0
            self.menuView?.transform = CGAffineTransform(translationX: -self.menuWidth, y: 0)
        })
    }


    @IBAction func settingsTap(_ sender: UIButton) {

        let settingsVC = storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SomeSettingsViewController
            settingsVC.savedImage = profileImage.image
            settingsVC.modalPresentationStyle = .overCurrentContext
            self.present(settingsVC, animated: true, completion: nil)

    }



    @IBAction func friendsTap(_ sender: Any) {
        VCService.presentFollowVC(fromVC: self, for: .followers)
    }

    @IBAction func addUserTap(_ sender: Any) {
        VCService.presentFollowVC(fromVC: self, for: .search)
    }

}
