//
//  ImageDetection.swift
//  logRegTest
//
//  Created by jed on 10/22/18.
//  Copyright © 2018 jed. All rights reserved.
//

import ARKit
import SceneKit

public extension MemorySceneView {


    func addImageAnchor(imageAnchor: ARImageAnchor, imgNode: SCNNode) {


        // eventually test this to put the earth on a face because it would be funny

        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)

        //            plane.firstMaterial?.diffuse.contents = UIColor.green

        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2

        let earthNode = EarthNode()
        earthNode.position = SCNVector3Zero
        earthNode.position.z = 0.05

        planeNode.addChildNode(earthNode) // adds the earth thing

        imgNode.addChildNode(planeNode) // adds the horizontal or vertical plane

        print("added imgNode ")
        //            return imgNode

    }


}
