//
//  ConvoTableViewCell.swift
//  logRegTest
//
//  Created by jed on 11/1/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit
import FirebaseUI

class ConvoTableViewCell: UITableViewCell {

    @IBOutlet var profileImage: UIImageView!

    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var newMessageLabel: UIView!
    @IBOutlet weak var timestampLabel: UILabel!

    var convo: Convo! {
        didSet {
            timestampLabel.text = convo.updatedAt.calenderTimeSinceNow()
        }
    }

    var members: [User] = [] {
        didSet {
            if convo.members.count < 3 {
                setupProfileImage()
            }
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = .white

        newMessageLabel.roundCorners(corners: [.allCorners], radius: newMessageLabel.frame.height / 1.333)

        profileImage.tintColor = #colorLiteral(red: 1, green: 0.5212877989, blue: 0, alpha: 1)
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = profileImage.frame.height/2

        userNameLabel.textColor = .darkText
        userNameLabel.text = ". . ."
        timestampLabel.textColor = .darkGray

    }


    func setupLabel() {

        members = []

        convo.members.forEach {

            if $0 == UserService.currUser.uid {
                self.members.append(UserService.currUser)
            } else {
                UserService.findOrObserve($0, completion: { (user) in
                    self.members.append(user)
                    let text = StringFormatter.userLabelText(self.members.map { $0.userName })
                    self.userNameLabel.text = text
                })
            }

        }

    }


    func setupProfileImage() {

        guard let i = members.index(where: { $0.uid != UserService.currUser.uid}) else { return }

        let user = members[i]

        if let image = user.profileImage {
            let ref = Storage.storage().reference(forURL:image)
            self.profileImage.sd_setImage(with: ref, placeholderImage: #imageLiteral(resourceName: "brainIcon"))

        }



    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.image = nil

        [userNameLabel,timestampLabel].forEach { label in
            label?.text = ""
        }

    }

    
}
