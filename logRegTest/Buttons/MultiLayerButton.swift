//
//  MultiLayerButton.swift
//  logRegTest
//
//  Created by jed on 12/5/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import UIKit

class MultiLayerButton: UIButton {

    lazy var redView: UIImageView! = {
        let view = UIImageView()
        view.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.4645139575, alpha: 0.6709118151)
        return view
    }()

    lazy var blueView: UIImageView! = {
        let view = UIImageView()
        view.tintColor = #colorLiteral(red: 0, green: 0.7297316194, blue: 1, alpha: 0.67)
        return view
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }


    func setup() {
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 0.3
        self.backgroundColor = .clear
        insertSubview(redView, at: 0)
        insertSubview(blueView, at: 1)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        [redView,blueView].forEach {
            $0?.bounds = bounds
            $0?.center = CGPoint(x: frame.width/2, y: frame.height/2)
            $0?.image = imageView?.image
        }
    }


    func select() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {

            self.redView.transform = CGAffineTransform(translationX: -3, y: -3)
            self.blueView.transform = CGAffineTransform(translationX: 3, y: -5)

        })
    }



    func unselect() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {

            self.redView.transform = .identity
            self.blueView.transform = .identity

        })
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}
