//
//  NavigationViewController.swift
//  logRegTest
//
//  Created by jed on 10/10/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit


class NavView: UIView {

    @IBOutlet weak var cameraButton: MindButton!
    var cameraButtonColor: CGColor!

    lazy var cameraButtonBottomConstraint: NSLayoutConstraint = {
        return cameraButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: cameraButtonBottomConstraintConstant)
    }()

    lazy var cameraButtonBottomConstraintConstant: CGFloat = {
        return -(frame.height*0.25)
    }()

    lazy var cameraButtonWidthConstraint: NSLayoutConstraint = {
        return cameraButton.widthAnchor.constraint(equalToConstant: 78)
    }()

    @IBOutlet weak var cameraHoldGesture: UILongPressGestureRecognizer!
    @IBOutlet weak var cameraTapGesture: UITapGestureRecognizer!

    @IBOutlet weak var selfButton: MultiLayerButton!
    @IBOutlet weak var chatButton: MultiLayerButton!
    @IBOutlet weak var connectButton: MultiLayerButton!
    @IBOutlet weak var discoverButton: MultiLayerButton!

    public var selectedButton: MultiLayerButton!

    static var disabled: Bool = false // always returns nil in hit test

    static var heightForInset: CGFloat!

    static var cameraButtonFrame: CGRect!

    override func awakeFromNib() {
        super.awakeFromNib()

        [selfButton, chatButton, connectButton, discoverButton].forEach {
            $0?.alpha = 0.7
        }

        cameraButtonBottomConstraint.isActive = true
        cameraButtonWidthConstraint.isActive = true

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cameraButton.cornerRadius = cameraButton.frame.height/2
        NavView.cameraButtonFrame = cameraButton.frame
    }


    func setupView() {

        NavView.disabled = false

        [selfButton, chatButton, connectButton, discoverButton].forEach {
            $0?.alpha = 0.7
        }

        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }

        cameraButton.animate()

        cameraHoldGesture.isEnabled = false // temporary
        cameraButtonColor = cameraButton.borderColor.cgColor

//        A_Button.layer.cornerRadius = A_Button.frame.height/4

    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self || NavView.disabled ? nil : view
    }

}


extension MainViewController {


    @IBAction func cameraButtonTouched(_ sender: UIButton) {
        !cameraOpen ? reOpenCamera(navView.cameraButton) : nil
    }

    @IBAction func cameraButtonTapped(_ sender: UITapGestureRecognizer) {
        cameraOpen ? cameraVC.capture(navView.cameraButton) : nil
    }



//    @objc func capture() {
//        cameraVC.capture(navView.cameraButton)
//    }

    @objc func reOpenCamera(_ sender: UIButton) {

        swipeViewController.setController(to: cameraVC, animated: true)

        navView.cameraButton.shouldAnimate = true
        navView.cameraButton.animate()

        navView.cameraTapGesture.isEnabled = true
        cameraOpen = true
        navView.adjustNav(true)

        if let button = navView.selectedButton {
            button.unselect()
            navView.selectedButton = nil
        }

    }



    @IBAction func cameraHold(_ sender: UILongPressGestureRecognizer) {
        sender.state == .began ? cameraVC.startRecording() : nil
        sender.state == .ended ? cameraVC.startRecording() : nil
    }


    @IBAction func shrinkNavItems(_ sender: MultiLayerButton) {

        if let button = navView.selectedButton {
            button.unselect()
        }
        navView.selectedButton = sender
        sender.select()

        guard cameraOpen else { return }

        navView.cameraTapGesture.isEnabled = false
        navView.cameraButton.stopAnimation()

        cameraOpen = false
        navView.adjustNav(false)

    }


    @IBAction func chatTapped(_ sender: Any) {
        swipeViewController.setController(to: messageViewController, animated: true)
    }

    @IBAction func atapped(_ sender: Any) {
        swipeViewController.setController(to: selfViewController, animated: true)
    }

    @IBAction func collabTapped(_ sender: Any ) {
        swipeViewController.setController(to: connectVC, animated: true)
    }

    @IBAction func discoverTapped(_ sender: Any) {
        swipeViewController.setController(to: discoverViewController, animated: true)
    }



}
