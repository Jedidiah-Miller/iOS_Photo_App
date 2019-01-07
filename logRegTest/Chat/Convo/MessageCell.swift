//
//  MessageCell.swift
//  logRegTest
//
//  Created by jed on 11/2/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit



class MessageCell: UITableViewCell {

    var message: Message!  {
        didSet {
            outgoing = message.sender == UserService.currUser.uid
            messageLabel.text = message.content
        }
    }

    var outgoing: Bool! {
            didSet {
                self.messageView.backgroundColor = outgoing ? #colorLiteral(red: 1, green: 0.5968740582, blue: 0.03151972219, alpha: 1) : #colorLiteral(red: 0.9460399747, green: 0.9404159188, blue: 0.9503628612, alpha: 1)
                self.messageLabel.textColor = outgoing ? .white : .black
                leadingConstraint.isActive = !outgoing
                trailingConstraint.isActive = outgoing
            }
        }


    lazy var leadingConstraint: NSLayoutConstraint = {
        return messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12)
    }()

    lazy var trailingConstraint: NSLayoutConstraint = {
        return messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
    }()

    let messageView = Gradient()
    let messageLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCell()
    }



    func setupCell() {

        self.selectionStyle = .none
        backgroundColor = .clear

        [messageView,messageLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }

        messageView.layer.cornerRadius = 4

        messageLabel.numberOfLines = 0
        messageLabel.font = messageLabel.font.withSize(15)

        let constant: CGFloat = 6
        let constraints: [NSLayoutConstraint] = [

            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: constant),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: frame.width*0.9),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -constant),

            messageView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            messageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            messageView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -constant),
            messageView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: constant),

            ]

        NSLayoutConstraint.activate(constraints)


    }


    override func prepareForReuse() {
        super.prepareForReuse()
        // things ?
    }


}
