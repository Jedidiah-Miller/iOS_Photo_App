//
//  FrontCameraViewController.swift
//  logRegTest
//
//  Created by jed on 10/12/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit
import ARKit
import SceneKit


class FaceViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    
    @IBOutlet var faceView: ARSCNView!

    let faceConfig = ARFaceTrackingConfiguration()
    var faceSession: ARSession { return faceView.session }
    
    var renderer: SCNRenderer!


    override func viewDidLoad() {
        super.viewDidLoad()

        faceView.showsStatistics = false

        faceView.delegate = self
        faceSession.delegate = self

        print("face view did load")

        setupFaceTracking()


    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("face view will appear")

//        setupFaceTracking()

    }



    func setupFaceTracking() {

        guard ARFaceTrackingConfiguration.isSupported else {print("need iPhone X or newer"); return }

        // this will only work for iphone X or newer - do an @available( iphone X * or newer )

        // find out what this is

        //        faceConfig.provideImageData(T##data: UnsafeMutableRawPointer##UnsafeMutableRawPointer, bytesPerRow: T##Int, origin: T##Int, T##y: Int##Int, size: T##Int, T##height: Int##Int, userInfo: T##Any?)


        faceConfig.isLightEstimationEnabled = true

        faceSession.run(faceConfig, options: [
//            .resetTracking,
//            .removeExistingAnchors

            ] )

    }



    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        print("Face View will disapear")

//        faceView.pause(self)

        print("face view paused")

        faceSession.pause()

    }




}
