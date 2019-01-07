//
//  VRContent.swift
//  logRegTest
//
//  Created by jed on 9/20/18.
//  Copyright © 2018 jed. All rights reserved.
//

import ARKit
import SceneKit

protocol VRContent { func update(withFaceAnchor: ARFaceAnchor) }

typealias VirtualFaceNode = VRContent & SCNNode

// MARK: Loading Content

func loadedContentForAsset(named resourceName: String) -> SCNNode {
    let url = Bundle.main.url(forResource: resourceName, withExtension: "scn", subdirectory: "Models.scnassets")!
    let node = SCNReferenceNode(url: url)!
    node.load()

    return node
}
