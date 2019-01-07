//
//  CameraPermissions.swift
//  logRegTest
//
//  Created by jed on 12/13/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UIKit
import AVKit


extension CameraVC {


    public func checkCameraPermissions() {

        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video )

        switch cameraAuthorizationStatus {
        case .notDetermined: requestCameraPermission()
        case .authorized: initCamera()
        case .restricted, .denied: alertCameraAccessNeeded()
        }

    }

    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            guard accessGranted == true else { return }
            self.initCamera()
        })
    }


    func alertCameraAccessNeeded() {

        let errorView = MessageBlurView(effect: UIBlurEffect(style: .regular))
        errorView.messageBoxSize = CGSize(width: view.frame.width*0.7, height: view.frame.width*0.5)

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


}
