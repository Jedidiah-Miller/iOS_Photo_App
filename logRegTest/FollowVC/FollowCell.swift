//
//  FollowCell.swift
//  logRegTest
//
//  Created by jed on 11/26/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import UIKit
import FirebaseUI
import FirebaseFirestore


class FollowCell: UICollectionViewCell {

    static let ID: String = "FollowCell"

    var user: User!

    var followsBack: Bool! {
        didSet {
             backgroundColor = followsBack ? .white : #colorLiteral(red: 0.9339728355, green: 0.9382951856, blue: 0.9488603473, alpha: 1)
        }
    }

    let profileImageView: UIImageView = {
        let view = UIImageView()
        view.layer.masksToBounds = true
        view.tintColor = #colorLiteral(red: 1, green: 0.5968740582, blue: 0.03151972219, alpha: 1)
        view.layer.cornerRadius = 22 // width is 44 rn
        view.contentMode = .scaleAspectFill
        return view
    } ()

    let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    } ()

    lazy var followsLabel: UILabel! = {
        let label = UILabel()
        label.textColor = .lightGray
        label.text = "follows you"
        label.font = label.font.withSize(12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var checkBox: Gradient!

    let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9403005242, green: 0.9554075599, blue: 0.9652326703, alpha: 1)
        return view
    } ()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = true
        setupCell()
    }


    fileprivate func setupCell() {

        [profileImageView, userNameLabel, dividerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        let imageSize: CGFloat = 44

        let constraints: [NSLayoutConstraint] = [

            profileImageView.widthAnchor.constraint(equalToConstant: imageSize),
            profileImageView.heightAnchor.constraint(equalToConstant: imageSize),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),

            userNameLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0, constant: 20),
            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: imageSize + 16),
            userNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            dividerView.widthAnchor.constraint(equalToConstant: self.frame.width),
            dividerView.heightAnchor.constraint(equalToConstant: 0.5),
            dividerView.bottomAnchor.constraint(equalTo: bottomAnchor)

        ]


        NSLayoutConstraint.activate(constraints)


    }


    func setupData() {

        guard user != nil else {
            userNameLabel.text = "this shouldnt be here the user is nil"
            profileImageView.image = #imageLiteral(resourceName: "brainIcon")
            return
        }

        userNameLabel.text = user.userName

        if let image = user.profileImage {
            let ref = Storage.storage().reference(forURL:image)
            self.profileImageView.sd_setImage(with: ref, placeholderImage: #imageLiteral(resourceName: "brainIcon"))
        }

    }

    func checkIfFollows() {

        followsBack = UserService.followers?.contains(user.uid) ?? false

        guard followsBack else { return }

        addSubview(followsLabel)

        followsLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4).isActive = true
        followsLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        followsLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor).isActive = true

    }


    func additionalSetup() {

        isUserInteractionEnabled = followsBack

        guard followsBack else { return }

        checkBox = Gradient()
        checkBox.FirstColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        checkBox.SecondColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        checkBox.startPoint = CGPoint(x: 0, y: 0)
        checkBox.endPoint = CGPoint(x: 1, y: 1)
        checkBox.translatesAutoresizingMaskIntoConstraints = false

        addSubview(checkBox)

        checkBox.widthAnchor.constraint(equalToConstant: 18).isActive = true
        checkBox.heightAnchor.constraint(equalToConstant: 18).isActive = true
        checkBox.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        checkBox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true

        checkBox.layer.cornerRadius = 9

    }

    override func prepareForReuse() { // LOOK AT THIS FOR ANYTHING THAT IS REUSABLE !!!!!!!!
        super.prepareForReuse()

        profileImageView.image = nil
        checkBox?.removeFromSuperview()
        followsLabel?.removeFromSuperview()

    }



    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
