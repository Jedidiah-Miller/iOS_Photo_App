//
//  ARSession.swift
//  logRegTest
//
//  Created by jed on 10/22/18.
//  Copyright © 2018 jed. All rights reserved.
//

import ARKit
import SceneKit

public extension MemorySceneView {


    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {

        // runs if your face in view of the front camera
        if let faceAnchor = anchors.first as? ARFaceAnchor {

            update(withFaceAnchor: faceAnchor)
        }

        faceState += 1

    }










    public func sessionWasInterrupted(_ session: ARSession) {

        print("session was interrupted")

    }

    public func sessionInterruptionEnded(_ session: ARSession) {

        print("session interruption ended")
    }

    public func session(_ session: ARSession, didFailWithError error: Error) {

        print("session did fail with error: \(error)")
        
    }





}
