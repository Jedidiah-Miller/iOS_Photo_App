//
//  TrackingState.swift
//  logRegTest
//
//  Created by jed on 10/22/18.
//  Copyright © 2018 jed. All rights reserved.
//

import ARKit
import SceneKit


public extension MemorySceneView {
    

    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {

        switch camera.trackingState {

        case .limited(.insufficientFeatures):
            print("camera did change tracking state: limited, insufficient features")

        case .limited(.excessiveMotion):
            print("camera did change tracking state: limited, excessive motion")

        case .limited(.initializing):
            print("camera did change tracking state: limited, initializing")

        case .normal:
            print("camera did change tracking state: normal")

        case .notAvailable:
            print("camera did change tracking state: not available")

        case .limited(.relocalizing):
            print("camera did change tracking state: limited, relocalizing")

        }

    }


}
