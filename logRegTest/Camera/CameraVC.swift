//
//  CameraVC.swift
//  logRegTest
//
//  Created by jed on 12/4/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

enum CaptureType {

    case Photo
    case StartVideo
    case EndVideo

}

class CameraVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    let captureSession: AVCaptureSession! = {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        return session
    }()

    var captureDevice: AVCaptureDevice!

//    var captureSettings: AVCapturePhotoSettings!

    lazy var backDevice: AVCaptureDevice? = {
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        let device = availableDevices.devices.first
        return device
    }()

    lazy var frontDevice: AVCaptureDevice? = {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        let device = session.devices.first
        return device
    }()

    lazy var dataOutput: AVCaptureVideoDataOutput! = {
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)] as [String : Any]
        output.alwaysDiscardsLateVideoFrames = true
        let queue = DispatchQueue(label: "change this label")
        output.setSampleBufferDelegate(self, queue: queue)
        return output
    }()

    let previewLayer: AVCaptureVideoPreviewLayer! = {
        let layer = AVCaptureVideoPreviewLayer()
        layer.videoGravity = .resizeAspectFill
        return layer
    }()

    var audioSession = AVAudioSession()
    let volumeButtonID: String = "outputVolume"

    var photoOutput: AVCapturePhotoOutput! = {
        let output = AVCapturePhotoOutput()
        return output
    }()

    enum FlashMode {
        case on
        case off
        case auto
    }

    var flashMode: FlashMode = .off

//    var takePhoto: Bool = false // lol

    lazy var swapCameraTapGesture: UITapGestureRecognizer! = {
        let gesture = UITapGestureRecognizer()
        gesture.numberOfTapsRequired = 2
        gesture.addTarget(self, action: #selector(swapCameras))
        gesture.delegate = view as? UIGestureRecognizerDelegate
        return gesture
    }()

    lazy var focusTapGesture: UITapGestureRecognizer! = {
        let gesture = UITapGestureRecognizer()
        gesture.numberOfTapsRequired = 1
        gesture.addTarget(self, action: #selector(focus))
        gesture.delegate = view as? UIGestureRecognizerDelegate
        return gesture
    }()

    lazy var flashButton: UXButton! = {
        let button = UXButton()
        button.setImage(#imageLiteral(resourceName: "flashOff"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "flashOn"), for: .selected)
        button.tintColor = .white
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = .zero
        button.layer.shadowOpacity = 0.8
        button.layer.shadowRadius = 0.5
        button.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        return button
    }()

    var objectLabel = UILabel(), confidenceLabel = UILabel()


    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermissions()
        setupUI()

        // this is to use the volume button as the camera button - rn due to the navigation controller it will take a picture anywhere even if the
//        try! audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//        audioSession.addObserver(self, forKeyPath: volumeButtonID, options: .new, context: nil)

    }


    func removeFocusCircleIfNeeded() {
        if let i = view.subviews.firstIndex(where: { $0 is FocusCircle }) {
            let oldFocusCircle = view.subviews[i] as! FocusCircle
            oldFocusCircle.hide()
        }
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        removeFocusCircleIfNeeded()

    }


    @objc func focus(_ tap: UITapGestureRecognizer) {

        let location = tap.location(in: self.view)
        let focusPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: location)

        let focusCircle = FocusCircle()

        DispatchQueue.main.async {
            self.view.addSubview(focusCircle)
            focusCircle.center = location
        }

        guard let captureDevice = captureDevice else { return } // honestly this is just to run app in the simulator

        do {
            try captureDevice.lockForConfiguration()

            if captureDevice.isFocusPointOfInterestSupported {
                captureDevice.focusPointOfInterest = focusPoint
                captureDevice.focusMode = .continuousAutoFocus
            }

            captureDevice.exposurePointOfInterest = focusPoint
            captureDevice.exposureMode = .continuousAutoExposure

            captureDevice.unlockForConfiguration()
        } catch {
            print("not great")
        }

    }


    @objc func swapCameras(_ tap: UITapGestureRecognizer) {
        // do other things eventually

        guard captureDevice != nil else { return } // honestly this is just to run app in the simulator

        runSession()
    }

    @objc func toggleFlash() {

        flashButton.isSelected = !flashButton.isSelected

        flashMode = flashMode == .on ? .off : .on

    }



    func startRecording() {

        print("started recording")

    }

    func stopRecording() {

        print("stop Recording")

    }



    func toggleTorch(_ on: Bool) { // i might not need this at all for video // but if i do it is only for video

        guard captureDevice?.hasTorch ?? false else { return }

        do {

            try captureDevice.lockForConfiguration()
            captureDevice.torchMode = on ? .on : .off
            captureDevice.unlockForConfiguration()

        } catch {
            print(error.localizedDescription)
        }

    }



    func getDeviceSettings() -> AVCapturePhotoSettings {

        let settings = AVCapturePhotoSettings()

        settings.isAutoStillImageStabilizationEnabled = photoOutput.isStillImageStabilizationSupported

        guard let captureDevice = captureDevice else { return settings }

        if captureDevice.hasFlash {

            switch flashMode {

            case .off: settings.flashMode = .off

            case .on: settings.flashMode = .on

            case .auto: settings.flashMode = .auto

            }

        }

        return settings
    }



//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) { // old
//        if takePhoto {
//            takePhoto = false
//            sampleBufferToUIImage(sampleBuffer)
//        }
//    }


//    func sampleBufferToUIImage(_ buffer: CMSampleBuffer) { // old // video capture output
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else { return }
//        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//        let context = CIContext()
//        let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
//        if let image = context.createCGImage(ciImage, from: imageRect) {
//            let scaledImage = UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
//            presentPreview(scaledImage)
//        }
//    }



//    MARK ! - photo previewing

    func presentPreview(_ image: UIImage) {

        let previewVC = PreviewVC()
        previewVC.modalPresentationStyle = .overCurrentContext

        previewVC.imageView.image = captureDevice.position == .back ? image : image.flipForFrontCamera()

        DispatchQueue.main.async {

            self.present(previewVC, animated: false, completion: nil)
            
        }

    }

    
    // MARK ! - camera setup
    // runSession also swaps cameras

    // REALLY IMPORTANT !!!!!
    // the start running function cant be called before the commitconfiguration

    func initCamera() {
        previewLayer.frame = view.layer.frame
        view.layer.addSublayer(previewLayer)

        runSession()
    }


    func runSession() {

        captureSession.isRunning ? captureSession.stopRunning() : nil

        if let device = captureDevice {
            captureDevice = device.position == .front ? backDevice : frontDevice
        } else {
            captureDevice = backDevice
        }

        guard captureDevice != nil else { return } // honestly this is just to run app in the simulator

        captureSession.inputs.forEach { input in
            self.captureSession.removeInput(input)
        }

        do {
            if captureSession.canAddInput(try AVCaptureDeviceInput(device: captureDevice)) {
                captureSession.addInput(try AVCaptureDeviceInput(device: captureDevice))
            }
        } catch {
            print(error.localizedDescription)
        }

        previewLayer.session = captureSession

//        DispatchQueue.main.async {
//
//            self.captureSession.startRunning()
//
//        }


        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }


        captureSession.commitConfiguration()

        DispatchQueue.main.async {

            self.captureSession.startRunning()

        }

    }

}

extension CameraVC: AVCapturePhotoCaptureDelegate {


    func capture(_ sender: MindButton) {

        sender.photoAnimation()

        guard captureDevice != nil else { return }

        let settings = getDeviceSettings()

        photoOutput.capturePhoto(with: settings, delegate: self)

    }


    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        guard let imageData = photo.fileDataRepresentation() else {
            print(error!.localizedDescription)
            return
        }

        if let image = UIImage(data: imageData) {

            presentPreview(image)

        }


    }



}


extension UIImage {

    func flipForFrontCamera() -> UIImage {

        return UIImage(cgImage: cgImage!, scale: scale, orientation: .leftMirrored)

    }

}
