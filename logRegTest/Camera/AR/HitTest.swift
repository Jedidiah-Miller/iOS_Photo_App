//
//  HitTest.swift
//  logRegTest
//
//  Created by jed on 10/24/18.
//  Copyright © 2018 jed. All rights reserved.
//

import SceneKit


extension MemoryViewController {


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        let touch = touches.first
        let location = touch?.location(in: sceneView)

        print("Memory view - screen touch location -", location!)

        guard let touchLocation = touches.first?.location(in: sceneView),

            let tappedNode = sceneView.hitTest(touchLocation, options: nil).first?.node

            else { return }

        if tappedNode.isKind(of: PostNode.self) {

            alignToScreen(postNode: tappedNode)

        }

        if tappedNode.isKind(of: FloatingPhoto.self) {

            hightlightSelected(selectedNode: tappedNode)

        }




        print("Memory view - node touch location -", touchLocation)

        for node in tappedNode.childNodes {

            if let nodeName = node.name {

                print("Memory view - this node was tapped - ", nodeName)

            }

        }

        // use this location to set the location node or anchor for the photo when the photo is taken


    }



//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesMoved(touches, with: event)
//
//        switch touchAction {
//
//        case .None: break
//
//        case .EditNodeLocation: print("editing node")
//
//        case .Draw: draw(touch: touches.first!)
//
//
//        }
//
//    }



    func draw(touch: UITouch) {

        var node = SCNNode(geometry: SCNSphere(radius: 0.003)),
            translation = node.simdTransform
            translation.columns.3.z = -0.2

            node.geometry?.firstMaterial?.diffuse.contents = drawingColor
            node.geometry?.firstMaterial?.specular.contents = drawingColor

        addNodeAtTouchLocation(location: touch.location(in: sceneView), node: node)


    }



    func addNodeAtTouchLocation (location: CGPoint, node: SCNNode?) {

        let hitResults = sceneView.hitTest(location, types: .featurePoint )

        if hitResults.count > 0 {

            let result = hitResults.first!

            let position = SCNVector3 (
                x: result.worldTransform.columns.3.x,
                y: result.worldTransform.columns.3.y,
                z: result.worldTransform.columns.3.z
            )

            node?.position = position

            sceneView.scene.rootNode.addChildNode(node!)

        }

    }





}
