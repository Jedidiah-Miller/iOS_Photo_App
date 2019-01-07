//
//  ProfileService.swift
//  logRegTest
//
//  Created by jed on 11/14/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit


class VCService: NSObject {

    static let SB: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)


    static func presentSelfVC(user: User?, fromVC: UIViewController, with imageView: UIImageView?, transitionFrame: CGRect) {

        guard let selfVC = SB.instantiateViewController(withIdentifier: "SelfViewController") as? SelfViewController else { return }

        selfVC.modalPresentationStyle = .overCurrentContext

        let image = imageView?.image

        // setup data

        selfVC.user = user
        selfVC.userImage = image
        selfVC.frameForDismiss = transitionFrame
        selfVC.imageViewToReset = imageView


        // setup transition

        selfVC.view.alpha = 0

        // tempoary for transition, not super memory efficient but looks super good

        let transitionImageView = UIImageView(image: image) // set the image = to the imageView.image
        transitionImageView.frame = transitionFrame
        transitionImageView.contentMode = .scaleAspectFill
        transitionImageView.clipsToBounds = imageView?.clipsToBounds ?? true
        transitionImageView.layer.cornerRadius = imageView?.layer.cornerRadius ?? 0

        fromVC.view.addSubview(transitionImageView)

        imageView?.image = nil

        fromVC.present(selfVC, animated: false, completion: {

            selfVC.hideViewsForTransition(animated: false)

            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {

                transitionImageView.frame = selfVC.profileImage.frame
                transitionImageView.layer.cornerRadius = selfVC.profileImage.layer.cornerRadius

            }) { (completion) in

                selfVC.view.alpha = 1
                selfVC.showViewsForTransition()

                transitionImageView.removeFromSuperview()

            }

        })


    }






    static func presentMediaVC(imageView: UIImageView, imageViewFrame: CGRect,
                               profileImageView: UIImageView?, profileImageViewFrame: CGRect?,
                               userNameLabel: UILabel?, userNameLabelFrame: CGRect?,
                               memory: Memory, author: User?, fromVC: UIViewController) {

        guard let mediaVC = SB.instantiateViewController(withIdentifier: "MediaVC") as? MediaViewController else { return }

        mediaVC.modalPresentationStyle = .overCurrentContext
        mediaVC.view.alpha = 0

        // setup data
        mediaVC.hasProfileImage = profileImageView != nil

        mediaVC.memory = memory
        mediaVC.author = author

        mediaVC.labelToReset = userNameLabel
        mediaVC.dismissLabelFrame = userNameLabelFrame

        mediaVC.profileImageViewToReset = profileImageView
        mediaVC.dismissProfileImageFrame = profileImageViewFrame

        mediaVC.dismissImageFrame = imageViewFrame
        mediaVC.imageViewToReset = imageView


        // transition things

        let transitionContainer = UIView(frame: UIScreen.main.bounds)
        transitionContainer.backgroundColor = .clear

        let transitionUserNameLabel = UILabel(frame: userNameLabelFrame ?? CGRect(origin: .zero, size: .zero))

        if let label = userNameLabel {

            // stuff I knew that I needed

//            transitionUserNameLabel.backgroundColor = .blue // so i can see wtf is going on

            transitionUserNameLabel.text = label.text
            transitionUserNameLabel.font = label.font
            transitionUserNameLabel.textColor = label.textColor
            transitionUserNameLabel.textAlignment = label.textAlignment
            transitionUserNameLabel.clipsToBounds = label.clipsToBounds
//            transitionUserNameLabel.transform = label.transform

            [transitionUserNameLabel,mediaVC.userNameLabel].forEach { newLabel in

                newLabel?.layer.shadowColor = label.layer.shadowColor
                newLabel?.layer.shadowRadius = label.layer.shadowRadius
                newLabel?.layer.shadowOpacity = label.layer.shadowOpacity
                newLabel?.layer.shadowOffset = label.layer.shadowOffset

//                newLabel?.textAlignment = label.textAlignment
                newLabel?.clipsToBounds = label.clipsToBounds

            }

            // stuff that I guess I need but don't know why
            // or might need but don't know for sure

            transitionUserNameLabel.semanticContentAttribute = label.semanticContentAttribute
            transitionUserNameLabel.preferredMaxLayoutWidth = label.preferredMaxLayoutWidth
            transitionUserNameLabel.numberOfLines = label.numberOfLines
            transitionUserNameLabel.baselineAdjustment = label.baselineAdjustment
            transitionUserNameLabel.allowsDefaultTighteningForTruncation = label.allowsDefaultTighteningForTruncation
            transitionUserNameLabel.adjustsFontSizeToFitWidth = label.adjustsFontSizeToFitWidth
            transitionUserNameLabel.adjustsFontForContentSizeCategory = label.adjustsFontForContentSizeCategory
            transitionUserNameLabel.lineBreakMode = label.lineBreakMode
            transitionUserNameLabel.autoresizingMask = label.autoresizingMask

        }



        let profileImage = profileImageView?.image
        let transitionProfileImageView = UIImageView(image: profileImage)

        transitionProfileImageView.frame = profileImageViewFrame ?? CGRect(origin: .zero, size: .zero)
        transitionProfileImageView.contentMode = .scaleAspectFill
        transitionProfileImageView.clipsToBounds = profileImageView?.clipsToBounds ?? true
        transitionProfileImageView.layer.cornerRadius = profileImageView?.layer.cornerRadius ?? 0

        let image = imageView.image
        let transitionImageView = UIImageView(image: image)
        transitionImageView.frame = imageViewFrame
        transitionImageView.contentMode = .scaleAspectFill
        transitionImageView.clipsToBounds = imageView.clipsToBounds
        transitionImageView.layer.cornerRadius = imageView.layer.cornerRadius

        [transitionImageView, transitionProfileImageView, transitionUserNameLabel].forEach { view in
            transitionContainer.addSubview(view)
        }


        fromVC.view.addSubview(transitionContainer)

        userNameLabel?.text = nil
        profileImageView?.image = nil
        imageView.image = nil


        fromVC.present(mediaVC, animated: false) {

            if let profileImage = profileImage, mediaVC.profileImageView.image == nil {

                mediaVC.profileImageView.image = profileImage

            }

            mediaVC.imageView.image = image

            if !(fromVC is SelfViewController) {

                mediaVC.userNameLabel.addGestureRecognizer(mediaVC.userNameTapGesture)
                mediaVC.profileImageView.addGestureRecognizer(mediaVC.profileImageTapGesture)
                mediaVC.profileImageView.isUserInteractionEnabled = true

            } else if let selfVC = fromVC as? SelfViewController, selfVC.primaryVC == true {

                mediaVC.setupDelete()

            }

            // has to be called after the delte button is or isn't set up
            mediaVC.hideViews(animated: false, hideUser: !mediaVC.hasProfileImage)

            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {


                if userNameLabel != nil {

                    let targetOrigin = mediaVC.userNameLabel.frame.origin
                    transitionUserNameLabel.frame.origin = targetOrigin

                    transitionUserNameLabel.frame = mediaVC.userNameLabel.frame
                    transitionUserNameLabel.textColor = mediaVC.userNameLabel.textColor

                    let scale = mediaVC.userNameLabel.font.pointSize / transitionUserNameLabel.font.pointSize

//                    transitionUserNameLabel.frame.size =

                    let transform = transitionUserNameLabel.transform.scaledBy(x: scale, y: scale)

                    transitionUserNameLabel.transform = transform
                }

                if profileImageView != nil {

                    transitionProfileImageView.frame = mediaVC.profileImageView.frame
                    transitionProfileImageView.layer.cornerRadius = mediaVC.profileImageView.layer.cornerRadius

                }

                transitionImageView.frame = mediaVC.imageView.frame
                transitionImageView.layer.cornerRadius = mediaVC.imageView.layer.cornerRadius

                transitionContainer.backgroundColor = .black

            }) { (completion) in

                mediaVC.view.alpha = 1
                mediaVC.showViews()

                transitionContainer.removeFromSuperview()


            }


        }



    }

    


    // CHANGE THIS TO LOOK LIKE AN EXPANDABLE CELL

    // Better yet, make each cell the actuall convo and make them expanable


    static func presentConvoVC(users: [User], fromVC: UIViewController, convo: Convo?) { // change to mulitple users

        guard let convoVC = SB.instantiateViewController(withIdentifier: "ConvoVC") as? ConvoVC else { return }

        convoVC.modalPresentationStyle = .overCurrentContext

        // set all of the data it need

        let convoToOpen: Convo!

        if convo?.ref == nil {

            convoVC.newConvo = true
            convoToOpen = Convo(ref: nil, id: nil, members: users.map { $0.uid }, updatedAt: Date(), createdAt: Date())

        } else {

            convoToOpen = convo

        }

        // assuming you're excluding the currUser
        let stringArr = StringFormatter.userLabelText(users.map { $0.userName })

        let selectecConvo = SelectedConvo(convo: convoToOpen, members: users, userLabel: stringArr)

        convoVC.selectedConvo = selectecConvo

        convoVC.sentFromMessages = fromVC is MessageViewController


        // animate the transition

        convoVC.view.alpha = 0
        let viewToTransform = fromVC is SelfViewController ? convoVC.view : convoVC.messageView

        fromVC.present(convoVC, animated: false) {

            if fromVC is MessageViewController {
                convoVC.setTextViewToSmallSize()
            }


            if convoVC.newConvo {
                newConvoLabel()
            }

            viewToTransform?.transform = CGAffineTransform(translationX: convoVC.view.frame.width/2, y: 0)

            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {

                convoVC.view.layoutIfNeeded()
                convoVC.view.alpha = 1

                viewToTransform?.transform = .identity

                convoVC.textView.layer.cornerRadius = convoVC.smallTextViewSize.width/2

            }) { (completion) in
                // things ?
            }

        }



        func newConvoLabel() {

            convoVC.userNameLabel.alpha = 0

            UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseInOut, animations: {
                convoVC.userNameLabel.alpha = 1
            })

        }




    }






    static func presentFollowVC(fromVC: UIViewController, for state: FollowVCState) {

        let followVC = FollowVC(collectionViewLayout: UICollectionViewLayout().self)
        followVC.state = state
        followVC.modalPresentationStyle = .overCurrentContext

        if fromVC is SelfViewController {
            followVC.setupFromSelf()
        }

        fromVC.present(followVC, animated: true)



    }


    static func fadeInPanUp(_ controller: UIViewController, from: UIViewController) {

        controller.view.alpha = 0

        from.present(controller, animated: false) {

            controller.view.transform = CGAffineTransform(translationX: 0, y: controller.view.frame.height/4)

            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut,.showHideTransitionViews], animations: {

                controller.view.alpha = 1
                controller.view.transform = .identity

            }) { (completion) in

                print("presented")

            }

        }

    }


    static func dismissFadeOutPanDown(_ controller: UIViewController) {

        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut,.showHideTransitionViews], animations: {

            controller.view.alpha = 0
            controller.view.transform = CGAffineTransform(translationX: 0, y: controller.view.frame.height/4)

        }) { (completion) in

            controller.dismiss(animated: false)

        }

    }




}




class StringFormatter: NSObject {

    static func userLabelText(_ strings: [String]) -> String {

        var textArr = [String]()
        for string in strings {
            if string != UserService.currUser.userName {
                textArr.append(string)
            }
        }

        if textArr.count > 1 {
            return textArr.joined(separator: ", ") // group
        } else {
            return textArr.joined() // one user
        }

    }

}

