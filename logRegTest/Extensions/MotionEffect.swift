//
//  MotionEffect.swift
//  logRegTest
//
//  Created by jed on 10/27/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit

class MotionEffect: NSObject {



    static func addDeviceTilt(toView view: UIView, magnitude: Float) {

        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis),
            yMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis),
            group = UIMotionEffectGroup()

        xMotion.minimumRelativeValue = -magnitude
        xMotion.maximumRelativeValue = magnitude

        yMotion.minimumRelativeValue = -magnitude
        yMotion.maximumRelativeValue = magnitude

        group.motionEffects = [xMotion, yMotion]

        view.addMotionEffect(group)

    }


    static func addXTilt(toView view: UIView, magnitude: Float) {

        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        let group = UIMotionEffectGroup()

        xMotion.minimumRelativeValue = -magnitude
        xMotion.maximumRelativeValue = magnitude

        group.motionEffects = [xMotion]

        view.addMotionEffect(group)

    }

    static func addYTilt(toView view: UIView, magnitude: Float) {

        let yMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        let group = UIMotionEffectGroup()

        yMotion.minimumRelativeValue = -magnitude
        yMotion.maximumRelativeValue = magnitude

        group.motionEffects = [ yMotion]

        view.addMotionEffect(group)

    }
    


}
