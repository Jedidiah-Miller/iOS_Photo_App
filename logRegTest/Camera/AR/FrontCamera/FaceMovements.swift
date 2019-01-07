//
//  FaceMovements.swift
//  logRegTest
//
//  Created by jed on 9/20/18.
//  Copyright © 2018 jed. All rights reserved.
//

import ARKit
import SceneKit

public extension MemorySceneView {

    // add a node for each major feature

//    private lazy var jawNode = childNode(withName: "jaw", recursively: true)!
//    private lazy var eyeLeftNode = childNode(withName: "eyeLeft", recursively: true)!
//    private lazy var eyeRightNode = childNode(withName: "eyeRight", recursively: true)!

    // face anchor - // also pass the faceNode here //


    public func update(withFaceAnchor faceAnchor: ARFaceAnchor) {

        var blendShapes:[ARFaceAnchor.BlendShapeLocation:Any] = faceAnchor.blendShapes

        guard
            // left eye
//            let eyeBlinkLeft = blendShapes[.eyeBlinkLeft  ] as? Float,
//            let eyeLookDownLeft = blendShapes[.eyeLookDownLeft ] as? Float,
//            let eyeLookInLeft = blendShapes[.eyeLookInLeft ] as? Float,
//            let eyeLookOutLeft = blendShapes[.eyeLookOutLeft] as? Float,
//            let eyeLookUpLeft = blendShapes[ .eyeLookUpLeft ] as? Float,
//            let eyeSquintLeft = blendShapes[ .eyeSquintLeft ] as? Float,
//            let eyeWideLeft = blendShapes[ .eyeWideLeft ] as? Float,
//
//            // right eye
//            let eyeBlinkRight = blendShapes[.eyeBlinkLeft  ] as? Float,
//            let eyeLookDownRight = blendShapes[.eyeLookDownRight ] as? Float,
//            let eyeLookInRight = blendShapes[.eyeLookInRight ] as? Float,
//            let eyeLookOutRight = blendShapes[.eyeLookOutRight] as? Float,
//            let eyeLookUpRight = blendShapes[ .eyeLookUpRight ] as? Float,
//            let eyeSquintRight = blendShapes[ .eyeSquintRight ] as? Float,
//            let eyeWideRight = blendShapes[ .eyeWideRight ] as? Float,

//            // eyebrows
//            let browDownLeft = blendShapes[.browDownLeft] as? Float,
//            let browDownRight = blendShapes[.browDownRight] as? Float,
//            let browInnerUp = blendShapes[.browInnerUp] as? Float,
//            let browOuterUpLeft = blendShapes[.browOuterUpLeft] as? Float,
//            let browOuterUpRight = blendShapes[.browOuterUpRight] as? Float,
//
//            // cheeks
//            let cheekPuff = blendShapes[.cheekPuff] as? Float,
//            let cheekSquintLeft = blendShapes[.cheekSquintLeft] as? Float,
//            let cheekSquintRight = blendShapes[.cheekSquintRight] as? Float,
//
//            // nose
//            let noseSneerLeft = blendShapes[.noseSneerLeft] as? Float,
//            let noseSneerRight = blendShapes[.noseSneerRight] as? Float,
//
//            // jaw
//            let jawForward = blendShapes [.jawForward] as? Float,
//            let jawLeft = blendShapes [.jawLeft] as? Float,
//            let jawRight = blendShapes [.jawRight] as? Float,
//            let jawOpen = blendShapes [.jawOpen] as? Float,
//
//            // mouth
//            let mouthClose = blendShapes[.mouthClose] as? Float,
//            let mouthFunnel = blendShapes[.mouthFunnel] as? Float,
//            let mouthPucker = blendShapes[.mouthPucker] as? Float,
//            let mouthLeft = blendShapes[.mouthLeft] as? Float,
//            let mouthRight = blendShapes[.mouthRight] as? Float,
//            let mouthSmileLeft = blendShapes[.mouthSmileLeft] as? Float,
//            let mouthSmileRight = blendShapes[.mouthSmileRight] as? Float,
//            let mouthFrownLeft = blendShapes[.mouthFrownLeft] as? Float,
//            let mouthFrownRight = blendShapes[.mouthFrownRight ] as? Float,
//            let mouthDimpleLeft = blendShapes[.mouthDimpleLeft ] as? Float,
//            let mouthDimpleRight = blendShapes[.mouthDimpleRight] as? Float,
//            let mouthStretchLeft = blendShapes[.mouthStretchLeft] as? Float,
//            let mouthStretchRight = blendShapes[.mouthStretchRight] as? Float,
//            let mouthRollLower = blendShapes[.mouthRollLower] as? Float,
//            let mouthRollUpper = blendShapes[.mouthRollUpper] as? Float,
//            let mouthShrugLower = blendShapes[.mouthShrugLower] as? Float,
//            let mouthShrugUpper = blendShapes[.mouthShrugUpper] as? Float,
//            let mouthPressLeft = blendShapes[.mouthPressLeft] as? Float,
//            let mouthPressRight = blendShapes[.mouthPressRight] as? Float,
//            let mouthLowerDownLeft = blendShapes[.mouthLowerDownLeft] as? Float,
//            let mouthLowerDownRight = blendShapes[.mouthLowerDownRight] as? Float,
//            let mouthUpperUpLeft = blendShapes[.mouthUpperUpLeft] as? Float,
//            let mouthUpperUpRight = blendShapes[.mouthUpperUpRight] as? Float,

            // toungue
            let tongueMove = blendShapes[.tongueOut] as? Float

        else { return } // end of guard

        if tongueMove > 0.01 {

            print("you moved your tongue", tongueMove)

        }










    }



}
