//
//  Extensions.swift
//  logRegTest
//
//  Created by jed on 9/17/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import SceneKit
import ARKit


extension MemoryViewController { // ⟐

    func setupRoom(  ) {

        let node = SCNNode()
        node.position = SCNVector3.init( 0, 0, -1.5 )

        let leftWall = createBox(isDoor: false)
        leftWall.position = SCNVector3.init((-length / 2) + width, 0, 0)
        leftWall.eulerAngles = SCNVector3.init(0, 180.0.degressToRadians, 0)

        let rightWall = createBox(isDoor: false)
        rightWall.position = SCNVector3.init((length / 2) - width, 0, 0)

        let topWall = createBox(isDoor: false)
        topWall.position = SCNVector3.init(0, (height / 2) - width, 0)
        topWall.eulerAngles = SCNVector3.init(0, 0, 90.0.degressToRadians)

        let bottomWall = createBox(isDoor: false)
        bottomWall.position = SCNVector3.init(0, (-height / 2) + width, 0)
        bottomWall.eulerAngles = SCNVector3.init(0, 0, -90.0.degressToRadians)

        let backWall = createBox(isDoor: false)
        backWall.position = SCNVector3.init(0, 0, (-length / 2) + width)
        backWall.eulerAngles = SCNVector3.init(0, 90.0.degressToRadians, 0)

        let leftDoorSide = createBox(isDoor: true)
        leftDoorSide.position = SCNVector3.init((-length / 2 + width) + (doorLength / 2), 0, (length / 2) - width)
        leftDoorSide.eulerAngles = SCNVector3.init(0, -90.0.degressToRadians, 0)

        let rightDoorSide = createBox(isDoor: true)
        rightDoorSide.position = SCNVector3.init((length / 2 - width) - (doorLength / 2), 0, (length / 2) - width)
        rightDoorSide.eulerAngles = SCNVector3.init(0, -90.0.degressToRadians, 0)


        // lighting

        let light = SCNLight()
        light.type = .spot
        light.spotInnerAngle = 70
        light.spotOuterAngle = 120
        light.zNear = 0.00001
        light.zFar = 5
        light.castsShadow = true
        light.shadowRadius = 100
        light.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        light.shadowMode = .deferred
        let constraint = SCNLookAtConstraint(target: bottomWall)
        constraint.isGimbalLockEnabled = true

        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3.init(0, 0.5, 0)
        lightNode.constraints = [constraint]
        node.addChildNode(lightNode)

        //Adding Nodes to Main Node
        node.addChildNode(leftWall)
        node.addChildNode(rightWall)
        node.addChildNode(topWall)
        node.addChildNode(bottomWall)
        node.addChildNode(backWall)
        node.addChildNode(leftDoorSide)
        node.addChildNode(rightDoorSide)

        // places it in front of you // takes the root node, the first one added when the camera loaded

        self.sceneView.scene.rootNode.addChildNode(node)

    }



}


var width  : CGFloat = 0.02
var height : CGFloat = 1
var length : CGFloat = 1

var doorLength : CGFloat = 0.3

func createBox(isDoor: Bool) -> SCNNode {
    let node = SCNNode()
    // first box
    let firstBox = SCNBox(width: width, height: height, length: isDoor ? doorLength : length, chamferRadius: 0)
    firstBox.firstMaterial?.diffuse.contents = UIColor.white
    let firstBoxNode = SCNNode(geometry: firstBox)
    firstBoxNode.renderingOrder = 200
    node.addChildNode(firstBoxNode)
    // add inner box
    let maskedBox = SCNBox(width: width, height: height,  length: isDoor ? doorLength : length, chamferRadius: 0)
    maskedBox.firstMaterial?.diffuse.contents = UIColor.white
    maskedBox.firstMaterial?.transparency = 0.000000000000000001
    
    let maskedBoxNode = SCNNode(geometry: maskedBox)
    maskedBoxNode.renderingOrder = 100
    maskedBoxNode.position = SCNVector3.init(width, 0 , 0 )
    node.addChildNode(maskedBoxNode)
    
    return node
}

extension FloatingPoint {
    var degressToRadians : Self {
        return self * .pi / 180
    }
    var radiansToDregress : Self {
        return self * 180 / .pi
    }
    
}
