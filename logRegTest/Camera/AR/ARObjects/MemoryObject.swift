//
//  Post.swift
//  logRegTest
//
//  Created by jed on 10/4/18.
//  Copyright © 2018 jed. All rights reserved.
//

import SceneKit

class PostNode: SCNNode {


    var mainNode: SCNNode!

    var imagePlane = SCNPlane()
    var imageNode = SCNNode()

    let size: Float = 0.0004

    // make the dimensions of the memories only ever be the  of the photo


    init( postText: String?, postImage: UIImage?, postTimestamp: Any? ) {
        super.init()

        if postImage != nil { // or if the video isnt nil


            imagePlane = SCNPlane(width: (postImage?.size.width)!, height: (postImage?.size.height)! )

                imagePlane.firstMaterial?.diffuse.contents = postImage
                imagePlane.firstMaterial?.lightingModel = .constant
                imagePlane.firstMaterial?.isDoubleSided = true

            imageNode.geometry = imagePlane

            imageNode.scale = SCNVector3Make(size, size, size)


            self.addChildNode(imageNode)


        }


        if postText != nil {

            let textFrame = SCNNode(geometry: SCNBox(width: 0.5, height: 0.6, length: 0.025, chamferRadius: 0.03) )
                textFrame.geometry?.firstMaterial?.diffuse.contents = UIColor.white
                textFrame.geometry?.firstMaterial?.specular.contents = UIColor.init(red: 20, green: 0, blue: 0, alpha: 0)
                textFrame.geometry?.firstMaterial?.transparency = 0.8

            if postImage != nil {

                textFrame.position = SCNVector3( 0.0, -0.9 , 0.1 )

//                textFrame.scale = SCNVector3Make(size, size, size)

            }

            self.addChildNode(textFrame)


            let text = SCNText(string: postText, extrusionDepth: 0.2)
                text.flatness = 0.05
                text.font = UIFont.systemFont( ofSize: 3.0 )
                text.containerFrame = CGRect(origin: .zero , size: CGSize(width: 44 , height: 100 ))
                text.isWrapped = true
            let textNode = SCNNode(geometry: text)
                textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
                textNode.position = SCNVector3(-0.2 , -0.75, 0.025)
//                textNode.position = SCNVector3( 0.0 , 0.0, 0.025 )
            let fontSize: Float = 0.01
                textNode.scale = SCNVector3Make(fontSize, fontSize, fontSize)


            textFrame.addChildNode(textNode)


            let timestamp = SCNText(string: postTimestamp, extrusionDepth: 0.1 )
                timestamp.font = UIFont.systemFont(ofSize: 12)
                timestamp.flatness = 0.005


            let timestampNode = SCNNode(geometry: timestamp)
                timestampNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
                timestampNode.position = SCNVector3(-0.2275, -0.225, 0.02)
                let timeSize: Float = 0.003
                timestampNode.scale = SCNVector3( timeSize, timeSize, timeSize )

            textFrame.addChildNode(timestampNode)

        }



//        self.geometry = mainNode.geometry

    }















    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

}

