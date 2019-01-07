//
//  CoolMenuView.swift
//  logRegTest
//
//  Created by jed on 11/29/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import UIKit


class FoldingMenuView: UIView {



    var size: CGSize = CGSize(width: 40, height: 40)
    var color: UIColor = .white
    var isOpen: Bool!

    lazy var topBar: UIView = {
        let view = UIView()
        return view
    }()

    lazy var middleBar: UIView = {
        let view = UIView()
        return view
    }()

    lazy var bottomBar: UIView = {
        let view = UIView()
        return view
    }()

    var topBarCenter: CGPoint!
    var bottomBarCenter: CGPoint!

    lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.numberOfTapsRequired = 1
        gesture.delegate = self as? UIGestureRecognizerDelegate
        gesture.addTarget(self, action: #selector(tapped))
        return gesture
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {

        addGestureRecognizer(tapGesture)
        isOpen = true

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        layer.borderColor = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1) // TEMP
        layer.borderWidth = 0.7 // TEMP

        [topBar,
         //         middleBar,bottomBar
            ].forEach {

                addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.layer.cornerRadius = 2
                $0.backgroundColor = color

                // $0.frame.size = CGSize(width: size.width*0.9, height: size.height/5)

                $0.widthAnchor.constraint(equalToConstant: size.width*0.9).isActive = true
                $0.heightAnchor.constraint(equalToConstant: size.height/5)
                $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        }


        let constraints: [NSLayoutConstraint] = [

            //            topBar.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            topBar.centerYAnchor.constraint(equalTo: centerYAnchor),
            //            bottomBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1)

        ]

        NSLayoutConstraint.activate(constraints)

        topBarCenter = topBar.center
        bottomBarCenter = bottomBar.center

    }


    @objc func tapped() {
        isOpen ? animateOpen() : animateClosed()
    }



    func animateOpen() {

        print("OPENING")

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.topBar.center = self.middleBar.center
            self.bottomBar.center = self.middleBar.center
        }) { (completion) in
            self.middleBar.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.topBar.transform = CGAffineTransform(rotationAngle: 45)
                self.bottomBar.transform = CGAffineTransform(rotationAngle: -45)
            })
        }

        isOpen = false

    }


    func animateClosed() {

        print("CLOSING")

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

            self.topBar.transform = .identity
            self.bottomBar.transform = .identity

        }) { (next) in
            self.middleBar.alpha = 1
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

                self.topBar.center = self.topBarCenter
                self.bottomBar.center = self.bottomBarCenter

            })
        }

        isOpen = true


    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}
