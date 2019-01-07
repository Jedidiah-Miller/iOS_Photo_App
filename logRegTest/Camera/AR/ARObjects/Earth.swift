//
//  Earth.swift
//  logRegTest
//
//  Created by jed on 9/18/18.
//  Copyright © 2018 jed. All rights reserved.
//

import SceneKit

class EarthNode: SCNNode {
    override init() {
        super.init()

        self.geometry = SCNSphere(radius: 0.05)

        self.geometry?.firstMaterial?.diffuse.contents = UIImage(named:"day")
        self.geometry?.firstMaterial?.specular.contents = UIImage(named:"Specular")
        self.geometry?.firstMaterial?.emission.contents = UIImage(named:"night")
        self.geometry?.firstMaterial?.normal.contents = UIImage(named:"Normal")
        self.geometry?.firstMaterial?.isDoubleSided = true

        self.geometry?.firstMaterial?.transparency = 1
        self.geometry?.firstMaterial?.shininess = 2

        let action = SCNAction.rotate(by: 360 * CGFloat((Double.pi)/180), around: SCNVector3(x:0, y:1, z:0), duration: 18)

        let repeatAction = SCNAction.repeatForever(action)

        self.runAction(repeatAction)

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

class BeachNode: SCNNode {
    override init() {
        super.init()

        self.geometry = SCNSphere(radius: 50 )

        self.geometry?.firstMaterial?.diffuse.contents = UIImage(named:"third")
        self.geometry?.firstMaterial?.isDoubleSided = true

        self.geometry?.firstMaterial?.transparency = 1
        self.geometry?.firstMaterial?.shininess = 0



    }

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

}


class HaloNode: SCNNode {
    override init() {
        super.init()

//        let light = SCNLight()
//        light.type = .ambient
////        light.spotInnerAngle = 70
////        light.spotOuterAngle = 120
//        light.zNear = 0.00001
//        light.zFar = 5
//
//        let lightNode = SCNNode()
//        lightNode.light = light
//        lightNode.position = SCNVector3.init(0, 0.5, 0)
//
//        self.addChildNode(lightNode)

        self.geometry = SCNTorus(ringRadius: 0.075, pipeRadius: 0.025)
        self.position = SCNVector3Zero
        self.position.y = 0.3
        self.position.z = -0.05
        self.geometry?.firstMaterial?.specular.contents = UIColor.yellow
        self.geometry?.firstMaterial?.diffuse.contents = UIColor.white


    }

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

}


// earth things below


//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch = touches.first
//        let location = touch?.location(in: sceneView)
//
//        addNodeAtLocation(location: location!)
//
//    }
//
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        if let estimate = self.sceneView.session.currentFrame?.lightEstimate {
//            sceneLight.intensity = estimate.ambientIntensity
//        }
//    }
//
//
////      Override to create and configure nodes for anchors added to the view's session.
//
//     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        var node:SCNNode?
//
//        if let planeAnchor = anchor as? ARPlaneAnchor {
//            node = SCNNode()
//
//            // plane size and color
//
//            planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x),height: CGFloat(planeAnchor.extent.z))
//
//            // makes vertical and horizontal different colors
//
//            planeGeometry.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.2)
//
//            let planeNode =  SCNNode(geometry: planeGeometry)
//
//            planeNode.position = SCNVector3(x: planeAnchor.center.x, y:0, z: planeAnchor.center.z)
//            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
//
//            updateMaterial()
//
//            node?.addChildNode(planeNode)
//            anchors.append(planeAnchor)
//
//        }
//
//     return node
//
//     }
//
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        if let planeAnchor = anchor as? ARPlaneAnchor {
//            if anchors.contains(planeAnchor) {
//                if node.childNodes.count > 0 {
//
//                    let planeNode = node.childNodes.first!
//                    planeNode.position = SCNVector3( x: planeAnchor.center.x, y:0, z: planeAnchor.center.z )
//
//                    if let plane = planeNode.geometry as? SCNPlane {
//
//                        plane.width = CGFloat(planeAnchor.extent.x)
//                        plane.height = CGFloat(planeAnchor.extent.z)
//
//                        updateMaterial()
//                    }
//                }
//            }
//        }
//
//    }
//
//    func updateMaterial() {
//
//        let material = self.planeGeometry.materials.first!
//
//        material.diffuse.contentsTransform = SCNMatrix4MakeScale(Float( self.planeGeometry.width), Float(self.planeGeometry.height), 1 )
//
//    }
//
//    func addNodeAtLocation (location: CGPoint) {
//        guard anchors.count > 0 else {print("no anchors yet lol"); return}
//
//        let hitResults = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
//
//        if hitResults.count > 0 {
//            let result = hitResults.first!
//            let newLocation = SCNVector3(x: result.worldTransform.columns.3.x, y: result.worldTransform.columns.3.y + 0.15, z: result.worldTransform.columns.3.z )
//            let newEarth = EarthNode()
//            newEarth.position = newLocation
//
//            sceneView.scene.rootNode.addChildNode(newEarth)
//        }
//    }

