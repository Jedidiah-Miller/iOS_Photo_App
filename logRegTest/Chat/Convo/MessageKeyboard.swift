//
//  MessageKeyboard.swift
//  logRegTest
//
//  Created by jed on 11/2/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit



extension ConvoVC {


    func setNotificationCenter() {

        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)

    }

    @objc func adjustForKeyboard(notification: Notification) {

        let userInfo = notification.userInfo!

        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if keyboardHeight == nil {
            keyboardHeight = keyboardViewEndFrame.height
        }

        let show = notification.name != UIResponder.keyboardWillHideNotification

        adjustTextViewWidth(show, height: keyboardViewEndFrame.height)

        messageView.contentInset.bottom = show ? (keyboardViewEndFrame.height + textViewHeightConstraint.constant) - 30 : inset.bottom

        show ? scrollToBottom(animated: true) : nil

        messageView.scrollIndicatorInsets = messageView.contentInset


    }


    func adjustTextViewWidth(_ show: Bool, height: CGFloat) {

//        print(show ? "SHOWING - " : "HIDING - ", height)

        if !show, textViewWidthConstraint.constant > smallTextViewSize.width {
            lastTextViewHeight = textView.frame.height
            wasScrollEnabled = textView.isScrollEnabled
        }

        textView.isScrollEnabled = show ? self.wasScrollEnabled : false

        textView.textColor = show ? .black : .clear
        textView.tintColor = textView.textColor

        textViewWidthConstraint.constant = show ? view.frame.width : smallTextViewSize.width

        textViewHeightConstraint.constant = show ? lastTextViewHeight : textViewWidthConstraint.constant

        textViewBottomConstraint.constant = show ? -height : -smallTextViewSize.height

//        let tempColor = textView.backgroundColor

        UIView.animate(withDuration: 0, delay: 0, options: [.curveEaseInOut,.transitionCrossDissolve], animations: {

            self.view.layoutIfNeeded()

            self.textView.layer.cornerRadius = show ? 0 : self.smallTextViewSize.width/2
            self.textView.backgroundColor = show ? self.messageView.backgroundColor : self.smallTextViewColor

            self.textViewImage.alpha = show ? -1 : 1
            self.textViewImage.tintColor = !show ? self.messageView.backgroundColor : self.smallTextViewColor
//            self.textViewImage.backgroundColor = self.textView.backgroundColor

        }) { (completion) in

            print("finished doing the things")

        }



    }





}
