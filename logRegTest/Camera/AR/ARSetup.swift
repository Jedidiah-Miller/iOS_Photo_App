//
//  ARSetup.swift
//  logRegTest
//
//  Created by jed on 9/20/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import ARKit
import SceneKit


extension MemoryViewController {



    @IBAction func flash(_ sender: Any) { toggleTorch(on: flash) }

    func toggleTorch(on: Bool) {

        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {return}
        //        var light: Bool { return device.isTorchActive }

        if device.hasTorch && !frontCamera {

            do {
                try device.lockForConfiguration()

                if on == false {
                    try device.setTorchModeOn(level: 0.01 ) // dim
                    //                    device.torchMode = .on
                    flash = true
                } else {
                    device.torchMode = .off
                    flash = false
                }

                device.unlockForConfiguration()

            } catch {

                print("Torch could not be used")

            }

        } else {

            print("Torch is not available")

        }

    }



}
