//
//  ARPhotoCapture.swift
//  logRegTest
//
//  Created by jed on 9/21/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import SceneKit





extension MemoryViewController {


    @IBAction func DEV(_sender: UILongPressGestureRecognizer) {
        sceneView.DEVELOPMENT ? sceneView.DevelopmentMode() : nil
        sceneView.DEVELOPMENT = !sceneView.DEVELOPMENT
    }


    @IBAction func newTextMemory(_ sender: Any) {

        imagePreview = nil
        self.performSegue(withIdentifier: "toPreview", sender: self)

    }

    func hideAR() {

        nodePhotos.forEach { node in
            node?.opacity = 0.0
        }

    }

    func showAR() {

        nodePhotos.forEach { node in
            node?.opacity = 1.0
        }

    }


    public func ARPhoto() {
        guard sceneView.session.currentFrame != nil else { return }

        let image = photo()
//        imagePreview = image

        addImageNode(image: image)

//        _isRecording ? nil : cameraControlsView.show()
    }


    func photo() -> UIImage {
        let currentFrame = sceneView.session.currentFrame,
            image = currentFrame!.capturedImage,

        photo = pixelBufferToUIImage(pixelBuffer: image)

        imagePreviews.insert(photo, at: imagePreviews.count)

        return photo
    }


    func addImageNode(image: UIImage) {

        let imageNode = FloatingPhoto( image: image)
        var translation = imageNode.simdTransform
        translation.columns.3.z = -0.75
        imageNode.simdTransform = matrix_multiply( (sceneView.session.currentFrame?.camera.transform)! , translation)

        sceneView.scene.rootNode.addChildNode(imageNode)

        nodePhotos.insert(imageNode, at: nodePhotos.count)

    }


    func pixelBufferToUIImage(pixelBuffer: CVPixelBuffer) -> UIImage {

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer),
            context = CIContext(options: nil),
            cgImage = context.createCGImage(ciImage, from: ciImage.extent),
            uiImage = UIImage(cgImage: cgImage!, scale: 1, orientation: .right)

        return uiImage

    }


    func singlePhoto() { // make this have an option to stay on the camera view

        guard sceneView.session.currentFrame != nil else { return } // show an alert ! temporarily
        guard let currentFrame = sceneView.session.currentFrame else { return }
        let image = currentFrame.capturedImage
        imagePreview = pixelBufferToUIImage(pixelBuffer: image)

        self.performSegue(withIdentifier: "toPreview", sender: self)

    }

    func finalARPhoto() {
        guard sceneView.session.currentFrame != nil else { return } // show an alert ! temporarily

        imagePreview = sceneView.snapshot()

        self.performSegue(withIdentifier: "toPreview", sender: self)


    }


    @IBAction func reset(_ sender: Any) {
        resetScreen()
    }


    func resetScreen() {

        print("resetting")

        nodePhotos.forEach { node in
            node?.removeFromParentNode()
        }

        nodePhotos = []
        imagePreviews = []


    }









}
