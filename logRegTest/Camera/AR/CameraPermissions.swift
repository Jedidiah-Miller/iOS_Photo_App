//
//  HDCamera.swift
//  logRegTest
//
//  Created by jed on 10/6/18.
//  Copyright © 2018 jed. All rights reserved.
//

import AVFoundation

import UIKit

extension MemoryViewController {


    public func checkCameraPermissions() {

        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video )

        switch cameraAuthorizationStatus {

        case .notDetermined: requestCameraPermission()

        case .authorized: sceneView.runWorldTracking()

        case .restricted, .denied: alertCameraAccessNeeded()

        }

    }


    func requestCameraPermission() {

        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            guard accessGranted == true else { return }

            self.sceneView.runWorldTracking()

        })

    }


    func alertCameraAccessNeeded() {

        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!

        let alert = UIAlertController(
            title: "Need Camera Access",
            message: "Camera access is required to capture photos and videos.",
            preferredStyle: UIAlertController.Style.alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))

        present(alert, animated: true, completion: nil)

    }




    func show() {

        print("show")

        let photoPicker = UIImagePickerController()
        photoPicker.sourceType = .camera
        photoPicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate

        self.present(photoPicker, animated: true, completion: nil)


    }



    func runHDCamera() {

        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices

        do {

            if let captureDevice = availableDevices.first {

                captureSession.addInput(try AVCaptureDeviceInput(device: captureDevice))

            }

        } catch {

            print(error.localizedDescription)

        }


        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        self.previewLayer = previewLayer
        self.view.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.view.layer.frame

        captureSession.startRunning()

        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)] as [String : Any]

        dataOutput.alwaysDiscardsLateVideoFrames = true

        if captureSession.canAddOutput(dataOutput) {

            captureSession.addOutput(dataOutput)

        }

        captureSession.commitConfiguration()


        let queue = DispatchQueue(label: "change this label")
        dataOutput.setSampleBufferDelegate(self as? AVCaptureVideoDataOutputSampleBufferDelegate, queue: queue)

    }




}
