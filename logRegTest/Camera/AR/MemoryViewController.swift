//
//  MemoryViewController.swift
//  logRegTest
//
//  Created by jed on 9/17/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

class MemoryViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {


    @IBOutlet var sceneView:  MemorySceneView!

    @IBOutlet weak var cameraControlsView: CameraControlsView!
    
    @IBOutlet var doubleTapGesture: UITapGestureRecognizer!

    @IBAction func unwindToMemoryView(_ unwindSegue: UIStoryboardSegue) { }

    public var _captureType: CaptureType = .Photo
//    public var touchAction: TouchAction = .None

    override var prefersStatusBarHidden: Bool { return true }
    override var prefersHomeIndicatorAutoHidden: Bool { return true }

    var dev: Bool = false
    var renderer: SCNRenderer!
    private let metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()

    let configuration = ARWorldTrackingConfiguration()

    private var currPlaneId: Int = 0
    private var state: Int = 1
    var temp: Int = 1 // temporary for drawing

    var hideARObjects: Bool = true
    public var frontCamera: Bool = false
    var final: Bool = false

    var nodePhotos: [SCNNode?] = []

    var imagePreview: UIImage!
    var imagePreviews: [UIImage?] = []

    var videoPreview: AVCaptureInput!

    var flash: Bool = false

    let captureSession = AVCaptureSession()
    var previewLayer: CALayer!

    var captureDevice: AVCaptureDevice!

    var drawingColor: UIColor = .white

    override func viewDidLoad() {
        super.viewDidLoad()

         checkCameraPermissions()

        self.view.accessibilityIgnoresInvertColors = true

    }



    @IBAction func swapCamerasAction(_ sender: Any ) { SwapCameras() }

    func SwapCameras() {
        frontCamera ? sceneView.runWorldTracking() : sceneView.runFaceTracking()
        frontCamera = !frontCamera
    }









    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

//        print("AR - view will dissapear")

        // when this view is not visble - if they leave the app or if they switch screens

        // save the World tracking data for when the camera switches back, wont re-scan the enironment

        // if possible - run the World tracking in the background, and only display the Face tracking on the screen


//        sceneView.pauseSession() ;

    }


}
