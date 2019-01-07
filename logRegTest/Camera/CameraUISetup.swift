//
//  CameraUISetup.swift
//  logRegTest
//
//  Created by jed on 12/13/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import UIKit


// MARK ! - constraints
extension CameraVC {

    func setupUI() {

        view.addSubview(flashButton)

        [swapCameraTapGesture,focusTapGesture].forEach {
            view.addGestureRecognizer($0)
        }

        let safeArea = view.safeAreaLayoutGuide

        [
            flashButton,

            ].forEach {
                $0!.translatesAutoresizingMaskIntoConstraints = false
                $0!.tintColor = .white
                view.addSubview($0!)
                $0!.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        }

        let constraints: [NSLayoutConstraint] = [

            flashButton.widthAnchor.constraint(equalToConstant: 30),
            flashButton.heightAnchor.constraint(equalToConstant: 30),
            flashButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),

            //                        objectLabel.widthAnchor.constraint(equalToConstant: view.frame.width*0.8),
            //                        objectLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            //                        confidenceLabel.widthAnchor.constraint(equalToConstant: view.frame.width*0.2),
            //                        confidenceLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)

        ]


        NSLayoutConstraint.activate(constraints)

    }

}
