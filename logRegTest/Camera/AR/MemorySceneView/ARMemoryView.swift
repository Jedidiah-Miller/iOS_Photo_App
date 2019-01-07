//
//  ARMemoryView.swift
//  logRegTest
//
//  Created by jed on 10/21/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import ARKit
import UIKit


@available(iOS 11.3, *)

public protocol MemorySceneViewDelegate: class {

    func MemorySceneViewDidSetupSceneNode(MemorySceneView: MemorySceneView, sceneNode: SCNNode)

}


@available(iOS 11.3, *)
public class MemorySceneView: ARSCNView, ARSCNViewDelegate {

    public let metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()

    let objectConfig = ARObjectScanningConfiguration()
    let orientationConfig = AROrientationTrackingConfiguration()
    let worldConfig = ARWorldTrackingConfiguration()
    private let faceConfig = ARFaceTrackingConfiguration()

    public var DEVELOPMENT: Bool = true

    private var updateEstimatesTimer: Timer?

    public convenience init() {
        self.init(frame: CGRect.zero, options: nil)
    }

    public override init(frame: CGRect, options: [String: Any]? = nil) {
        super.init(frame: frame, options: options)
        finishInitialization()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        finishInitialization()
    }


    public func DevelopmentMode() { // dev options

        self.debugOptions = [

            .showFeaturePoints,
            .showWorldOrigin,
            .showCameras,
            .showWireframe, // relative geometrey around a surface or object
            .showBoundingBoxes, // box around plane or object

            .showPhysicsShapes,
//            .showConstraints,
//            .renderAsWireframe,
//            .showSkeletons,

        ]

    }

    private func finishInitialization() {

        delegate = self
        showsStatistics = false

        DEVELOPMENT = false

        if DEVELOPMENT { DevelopmentMode() }

        if let camera = self.pointOfView?.camera {

//            camera.wantsHDR = true
            camera.wantsDepthOfField = true
            camera.apertureBladeCount = 10

//            camera.colorFringeStrength = 10.0 // cool rainbow
//            camera.colorFringeIntensity = 0.5

//            camera.bloomBlurRadius = 20
//            camera.bloomThreshold = 1.0
//            camera.bloomIntensity = 1.0

//            camera.zFar
//            camera.zNear

            camera.automaticallyAdjustsZRange = true

//            camera.wantsExposureAdaptation = true
//            camera.whitePoint = 0.5
            camera.exposureOffset = -1
            camera.minimumExposure = -1
            camera.maximumExposure = -1

//            camera.exposureAdaptationDarkeningSpeedFactor
//            camera.exposureAdaptationBrighteningSpeedFactor

        }

        //        worldConfig.detectionImages = ARReferenceImage.referenceImages(inGroupNamed: "ARTracking", bundle: Bundle.main)
        //        worldConfig.maximumNumberOfTrackedImages = 10

        worldConfig.planeDetection = [.horizontal, .vertical]
        worldConfig.worldAlignment = .gravityAndHeading
        worldConfig.isLightEstimationEnabled = true
        worldConfig.isAutoFocusEnabled = true

//        self.automaticallyUpdatesLighting = true
//        self.autoenablesDefaultLighting = true


        // find out what this is

        //        faceConfig.provideImageData(<#T##data: UnsafeMutableRawPointer##UnsafeMutableRawPointer#>, bytesPerRow: <#T##Int#>, origin: <#T##Int#>, <#T##y: Int##Int#>, size: <#T##Int#>, <#T##height: Int##Int#>, userInfo: <#T##Any?#>)

        faceConfig.isLightEstimationEnabled = true

    }


    override public func layoutSubviews() {
        super.layoutSubviews()

    }

    public func runWorldTracking() {

//        print("MEMORYSCENEVIEW - world session run - DEVELOPMENT", DEVELOPMENT )

        session.run(worldConfig, options: [
            .resetTracking,
            .removeExistingAnchors
            ] )

        updateEstimatesTimer?.invalidate()

    }

    public func pauseSession() {

//        print("MEMORYSCENEVIEW - session Pause")

        session.pause()

        updateEstimatesTimer?.invalidate()
        updateEstimatesTimer = nil

    }


    func runFaceTracking(){

//        print("MEMORYSCENEVIEW - face session run - DEVELOPMENT", DEVELOPMENT)

        guard ARFaceTrackingConfiguration.isSupported else {print("need iPhone X or newer"); return}

        // this will only work for iphone X or newer - do an @available( iphone X * or newer )

        // use the regular front camera if if returns


        session.run(faceConfig, options: [
            .resetTracking,
            .removeExistingAnchors
            ] )

    }


    /* SESSION VARIABLES */

    public var currPlaneId: Int = 0
    public let planeIdenifiers = [UUID]()

    var state: Int = 1
    var planeGeometry:SCNPlane!

    var anchors = [ARAnchor]()


    /* RENDERER VARIABLES */

    public var renderer: SCNRenderer!
    var faceState: Int = 1



}

