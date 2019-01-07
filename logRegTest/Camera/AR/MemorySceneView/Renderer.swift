//
//  Renderer.swift
//  logRegTest
//
//  Created by jed on 10/22/18.
//  Copyright © 2018 jed. All rights reserved.
//

import ARKit
import SceneKit

public extension MemorySceneView {


    // MARK: - ARSCNViewDelegate

    public func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {

    }


    // Runs if an ARAnchor from the real world is recognized - then adds it

    public func createPlaneNode(planeAnchor: ARPlaneAnchor) -> SCNNode { // plane detection

        let scenePlaneGeometry = ARSCNPlaneGeometry(device: metalDevice!)
            scenePlaneGeometry?.update(from: planeAnchor.geometry)

        let planeNode = SCNNode(geometry: scenePlaneGeometry)
            planeNode.name = "\(currPlaneId)"
            planeNode.opacity = 0.2

        if DEVELOPMENT {

            if planeAnchor.alignment == .horizontal {
                planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            } else {
                planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            }

        } else {

            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear

        }

        currPlaneId += 1
        return planeNode

    }

    // AR Image anchor // make both of these work for front and back camera

    public func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        guard let device = self.device else { return nil }
        let imgNode = SCNNode()

        if let imageAnchor = anchor as? ARImageAnchor {

            addImageAnchor(imageAnchor: imageAnchor, imgNode: imgNode) // theres a %50 chance this wont work right away

        }


        if let faceAnchor = anchor as? ARFaceAnchor { // move this into the session update func

            print("face anchor")

//            let faceGeometry = ARSCNFaceGeometry(device: device)
//            let faceNode = SCNNode(geometry: faceGeometry)
//
//            faceNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green // makes it trsansparent
//
//            faceNode.geometry?.firstMaterial?.fillMode = .lines
//
//            update(withFaceAnchor: faceAnchor)
//
//            return faceNode

        }

        return imgNode

    }



    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        guard let planeAnchor = anchor as? ARPlaneAnchor else { print("did add - not a plane anchor"); return }

        //        print("adding plane anchor", temp); temp = temp + 1

        let planeNode = createPlaneNode(planeAnchor: planeAnchor)

        node.addChildNode(planeNode)

    }

    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        node.enumerateChildNodes { (childNode, _) in childNode.removeFromParentNode() }
        let planeNode = createPlaneNode(planeAnchor: planeAnchor)
        node.addChildNode(planeNode)

    }

    // runs always, returns when switched to front camera - front = true
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {

        guard let _ = anchor as? ARPlaneAnchor else { print("did remove - not a plane anchor"); return }

        print("Removing plane anchor")

        node.enumerateChildNodes { (childNode, _) in childNode.removeFromParentNode()

        }

    }


}
