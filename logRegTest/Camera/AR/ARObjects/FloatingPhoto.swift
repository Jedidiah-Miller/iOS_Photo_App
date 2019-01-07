//
//  FloatingPhoto.swift
//  logRegTest
//
//  Created by jed on 10/24/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import SceneKit

class FloatingPhoto: SCNNode {

    var id = UUID(),
    imagePlane = SCNPlane()


    init( image: UIImage) {
        super.init()

        imagePlane.width = CGFloat(image.cgImage!.width) / 3000
        imagePlane.height = CGFloat(image.cgImage!.height) / 3000
        imagePlane.firstMaterial?.diffuse.contents = image
        imagePlane.firstMaterial?.lightingModel = .constant
        imagePlane.firstMaterial?.isDoubleSided = true

        self.geometry = imagePlane

    }


    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }



}
