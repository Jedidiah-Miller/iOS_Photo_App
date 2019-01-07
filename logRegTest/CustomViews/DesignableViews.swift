//
//  Views.swift
//  logRegTest
//
//  Created by jed on 10/8/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit

@IBDesignable class JedsDesignableView: UIView {

    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable var opacity: Float = 0.0 {
        didSet {
            self.layer.opacity = opacity
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }

}



@IBDesignable class DesignableCollectionView: UICollectionView {

    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable var opacity: Float = 0.0 {
        didSet {
            self.layer.opacity = opacity
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }

}



