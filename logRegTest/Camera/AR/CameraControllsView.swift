//
//  CameraControllsView.swift
//  logRegTest
//
//  Created by jed on 10/20/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit


class CameraControlsView: UIView {

    @IBOutlet weak var stopVideoButton: DesignableButton!
    @IBOutlet weak var stopVideoView: UIView!




//    var controls: CameraControlsView!

    var allCenter: CGPoint! // center the buttons
    var resetCenter: CGPoint!
    var drawCenter: CGPoint!
    var undoCenter: CGPoint!
    var textCenter: CGPoint!

    var artMenuOpen: Bool = false

    override func layoutSubviews() {
        super.layoutSubviews()
        // do nothing
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }

    func layoutButtons(){
        self.stopVideoView.alpha = 0
        hideVideoControlls()


    }

    func showVideoControlls() {
        UIView.animate(withDuration: 0.333, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .allowUserInteraction,
                       animations: {

                        self.stopVideoButton.transform = .identity
                        self.stopVideoView.transform = CGAffineTransform(translationX: -100, y: 0)
                        self.stopVideoView.alpha = 1

        }, completion: nil)
    }

    func hideVideoControlls() {
        UIView.animate(withDuration: 0.333, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .allowUserInteraction,
                animations: {

                    self.stopVideoButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    self.stopVideoView.transform = .identity
                    self.stopVideoView.alpha = 0

        }, completion: nil)
    }






}

