//
//  ScreenAnimations.swift
//  logRegTest
//
//  Created by jed on 10/5/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import ARKit
import SceneKit


// If the memory is showing up at an angle -

// let rotateToScreen: SCNAnimation(rotateTo( X: 0, Y

// save the original SCNVector3 value to rotate back to it

// pass the current camreaRlativePostion to this func

// add the billboard constraints after the animation //
// remove the

// track eye movements to focus on one object
    // if the user is not looking at the screen, the memory doesn't rotate towards them
    // when they look away it rotaes back

// eventually zoom the screen so it looks like the screen edges line up with the real world

// make certain things show up when it comes into focus too, like the text or the uses name who posted it
    // make the earth show up then so that wayy they dont all have an earth all the time


extension MemoryViewController {


    func checkFocus() {

        // check for the post being in focus near the center of the screen

        // check for whether or not the user is looking at the screen also

    }



    func hightlightSelected(selectedNode: SCNNode) {

//        selectedNode.geometry?.firstMaterial?.selfIllumination.

    }



    func alignToScreen( postNode: SCNNode ) {

        guard sceneView.session.currentFrame != nil else { return }

        print("aligning to screen")

        let front = sceneView.pointOfView!.position

        //        let fade = SCNAction.fadeOpacity(by: <#T##CGFloat#>, duration: <#T##TimeInterval#>)



        let postZAxis = postNode.position.z
//
//        let postAxis = postNode.position


        var translation = postNode.simdTransform
        translation.columns.3.z = postZAxis * 1.1 // move the post forward by %10

        // chcek to see which is less of a rotation - 180 degess or 180 ?

        let screenAngle = sceneView.session.currentFrame?.camera.transform // this would make a plane directly in front of the camera

//        let newY = front

        var screenX = screenAngle?.columns.3.x
        screenX = screenX! + 0.0

        var screenY = screenAngle?.columns.3.y
            screenY = screenY! + 0.0

        let screenNode = SCNNode()
            screenNode.position = front



        let billNode = SCNNode(geometry: postNode.geometry)
            billNode.position = postNode.position

        let billboardConstraints = SCNBillboardConstraint()

        billboardConstraints.freeAxes = [
//            SCNBillboardAxis.X,
//            SCNBillboardAxis.Y,
//            SCNBillboardAxis.Z,
            SCNBillboardAxis.all
        ]




        let faceScreen = SCNLookAtConstraint(target: screenNode)
                    faceScreen.isIncremental = true
            faceScreen.influenceFactor = 1.0
            faceScreen.isGimbalLockEnabled = true



//        billNode.constraints = [ faceScreen ]

//        postNode.constraints = [ faceScreen ]
//            postNode.position.y = postNode.position.y * -1

//        let pos = billNode.position

//        postNode.constraints = [faceScreen]

//        let faceUserY = faceScreen.

        let tempNode = SCNNode()
            tempNode.constraints = [faceScreen]

        var thisFront = tempNode.position.y
            thisFront = thisFront * -1



//        let rotateX = SCNBillboardAxis.X
//            print("X - ", rotateX)
//
//        let rotateY = SCNBillboardAxis.Y
//            print("Y - ", rotateY)



//        let action = SCNAction.rotate(by: CGFloat(screenY!) , around: SCNVector3(x:0, y:1, z:0), duration: 0.5)

//        let newAction = SCNAction.rotate


//        let repeatAction = SCNAction.repeatForever(action)

//        let action = SCNAction.rotateTo(x: 0, y: 4 , z: 0, duration: 0.5)

        let action = SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 0.5)
//
//        _ = SCNAction.rotate
//
//
//
//        postNode.runAction(repeatAction)
//
        postNode.runAction(action)




        if billNode.position.y == screenNode.position.y { // add the x axis later

            print("the bill Node lined up for some reason ")



            //            postNode.constraints = [billboardConstraints]

        }




        if postNode.position.y == screenNode.position.y { // add the x axis later

            print("everything lined up ")



//            postNode.constraints = [billboardConstraints] // add the bill board constrains every time the memory lines up

        } else {

            print("did not line up Y axis")

        }





//        postNode.constraints = [billboardConstraints]




    }






}

