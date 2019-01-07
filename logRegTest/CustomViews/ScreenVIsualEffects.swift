//
//  ScreenVIsualEffects.swift
//  logRegTest
//
//  Created by jed on 10/7/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit

class GradientView: UIView {





}

extension UIView {

    var roundedView: UIView {
        let maskLayer = CAShapeLayer(layer: self.layer)
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x:0, y:0))
        bezierPath.addLine(to: CGPoint(x:self.bounds.size.width, y:0))
        bezierPath.addLine(to: CGPoint(x:self.bounds.size.width, y:self.bounds.size.height))
        bezierPath.addQuadCurve(to: CGPoint(x:0, y:self.bounds.size.height), controlPoint: CGPoint(x:self.bounds.size.width/2, y:self.bounds.size.height-self.bounds.size.height*0.3))
        bezierPath.addLine(to: CGPoint(x:0, y:0))
        bezierPath.close()
        maskLayer.path = bezierPath.cgPath
        maskLayer.frame = self.bounds
        maskLayer.masksToBounds = true
        self.layer.mask = maskLayer
        return self
    }

}

extension UIView {

    // this can be used on buttons and views

    // also there can be as many colors as I want

    func addGradident(colors: [Any]) {

        let gradient = CAGradientLayer()

        gradient.frame = bounds
        gradient.masksToBounds = true
        gradient.colors = colors
        gradient.locations = [ 0.0, 1.0 ]
        gradient.startPoint = CGPoint(x: 0.0 , y: 0.0 )
        gradient.endPoint = CGPoint(x: 0.0 , y: 1.0 )
        gradient.opacity = 1
        //        gradient.backgroundFilters

        layer.insertSublayer(gradient, at: UInt32(0.0) )

    }

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {

        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)),
            mask = CAShapeLayer()
            mask.path = path.cgPath

        layer.mask = mask
        
    }

    func anchorX() {

    }

    func anchorY(top: NSLayoutYAxisAnchor?, bottom: NSLayoutYAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {

        translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }

        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: padding.bottom).isActive = true
        }

        if size.width != 0 {
            self.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }

        if size.height != 0 {
            self.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }

    }

    func anchor(top: NSLayoutYAxisAnchor?, bottom: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero ) {


        translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }

        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: padding.bottom).isActive = true
        }

        if let leading = leading {
            self.leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }

        if let trailing = trailing {
            self.trailingAnchor.constraint(equalTo: trailing, constant: padding.right).isActive = true
        }

        if size.width != 0 {
            self.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }

        if size.height != 0 {
            self.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }



    }



}


@IBDesignable class Gradient: UIView {

    @IBInspectable var FirstColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }

    @IBInspectable var SecondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }


//    @IBInspectable var Locations: [NSNumber] = [] {
//        didSet {
//            updateView()
//        }
//    }

    @IBInspectable var startPoint: CGPoint = ( .zero ) {
        didSet {
            updateView()
        }
    }

    @IBInspectable var endPoint: CGPoint = ( .zero ) {
        didSet {
            updateView()
        }
    }

    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }

    func updateView() {

        let layer = self.layer as! CAGradientLayer
            layer.colors = [ FirstColor.cgColor, SecondColor.cgColor]

            layer.locations = [ 0.0, 1.0 ]

            layer.startPoint = startPoint
            layer.endPoint = endPoint

    }


}


