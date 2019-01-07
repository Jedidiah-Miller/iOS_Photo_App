//
//  FeedCell.swift
//  logRegTest
//
//  Created by jed on 11/20/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import UIKit
import FirebaseUI
import FirebaseFirestore

class FeedCell: UICollectionViewCell {

    static let ID: String = "trucks"

    var memory: Memory!
    var author: User!
    var usersLike: DocumentReference? {
        didSet {
            likeButton.tintColor = usersLike == nil ? .lightGray : #colorLiteral(red: 1, green: 0, blue: 0.3808195591, alpha: 0.6968642979)
        }
    }

    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()

    let profileImageView: UIImageView = {
        let view = UIImageView()
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 22 // width is 44 rn
        return view
    } ()

    let userNameLabel: UILabel = {
        let button = UILabel()
        button.textColor = .black
        button.textAlignment = .left
        return button
    } ()

    //    font-family: "HiraginoSans-W3"; font-weight: normal; font-style: normal;

    let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont(name: "HiraginoSans-W3", size: 14)
        label.numberOfLines = 0
        label.clipsToBounds = false
        return label
    } ()

    let likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .lightGray
        button.setImage(#imageLiteral(resourceName: "clipart1449830530"), for: .normal)
        return button
    } ()

    let likeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont(name: "HiraginoSans-W3", size: 14)
        label.numberOfLines = 1
        return label
    } ()

    lazy var profileImageTap: UITapGestureRecognizer! = {
        let gesture = UITapGestureRecognizer()
        gesture.delegate = profileImageView as? UIGestureRecognizerDelegate
        gesture.numberOfTapsRequired = 1
        return gesture
    } ()

    lazy var reallyAnnoyingTap: UITapGestureRecognizer! = {
        let gesture = UITapGestureRecognizer()
        gesture.delegate = userNameLabel as? UIGestureRecognizerDelegate
        gesture.numberOfTapsRequired = 1
        return gesture
    } ()

    lazy var imageTap: UITapGestureRecognizer! = {
        let gesture = UITapGestureRecognizer()
        gesture.delegate = imageView as? UIGestureRecognizerDelegate
        gesture.numberOfTapsRequired = 1
        return gesture
    } ()

    var indexPath: IndexPath!


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCell()
    }


    private func setupCell() {

        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        backgroundColor = .white

        layer.cornerRadius = 8
        layer.masksToBounds = false
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)

        [profileImageView,userNameLabel,imageView,
         textLabel,likeButton,likeLabel].forEach { view in
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }

        imageView.addGestureRecognizer(imageTap)
        profileImageView.addGestureRecognizer(profileImageTap)
        userNameLabel.addGestureRecognizer(reallyAnnoyingTap)


        let constraints: [NSLayoutConstraint] = [

            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            profileImageView.widthAnchor.constraint(equalToConstant: 44),
            profileImageView.heightAnchor.constraint(equalToConstant: 44),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),

            userNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            userNameLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0, constant: 20),
            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),

            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 54),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -88),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),

            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            textLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 33),
            textLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 120),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            likeButton.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 8),
            likeButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0, constant: 30),
            likeButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0, constant: 26),
            likeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            likeLabel.topAnchor.constraint(equalTo: likeButton.topAnchor, constant: 0),
            likeLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            likeLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0, constant: 26),
            likeLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -8),

        ]

        NSLayoutConstraint.activate(constraints)

        [imageView,profileImageView,userNameLabel].forEach { view in
            view.isUserInteractionEnabled = true
        }


    }

    func setupData() {

// user data

        UserService.findOrObserve(memory.author) { user in

            self.author = user

            self.userNameLabel.text = user.userName

            if let image = self.author.profileImage {
                let ref = Storage.storage().reference(forURL:image)
                self.profileImageView.sd_setImage(with: ref, placeholderImage: nil)
            }

        }

// memory data
        textLabel.text = memory.text

        let ref = Storage.storage().reference(forURL: memory.imageUrl)
        imageView.sd_setImage(with: ref, placeholderImage: nil)

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

    func animateLikeButton() { // TODO - i made liking really stupid, make it add the users ID

        let color: UIColor!

        if usersLike != nil { // this doesnt work
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

    override func prepareForReuse() {
        super.prepareForReuse()

        [userNameLabel,textLabel,likeLabel].forEach { label in
            label?.text = ""
        }

        likeButton.tintColor = .lightGray

    }

}

