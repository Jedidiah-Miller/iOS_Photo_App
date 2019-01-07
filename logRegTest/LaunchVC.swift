//
//  LaunchVC.swift
//  logRegTest
//
//  Created by jed on 11/18/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit


class LaunchVC: UIViewController {

    let shapeLayer = CAShapeLayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        let center = view.center
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = #colorLiteral(red: 1, green: 0.410415411, blue: 0, alpha: 1)
        shapeLayer.lineWidth = 10
        view.layer.addSublayer(shapeLayer)


    }



}
