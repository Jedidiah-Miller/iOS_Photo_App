//
//  CoreMLFunctions.swift
//  logRegTest
//
//  Created by jed on 12/13/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import AVKit
import CoreML
import Vision


extension CameraVC { // coreML

    func coreMLOutput(_ buffer:CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer),
            let model = try? VNCoreMLModel(for: MobileNet().model) else { return }
        let request = VNCoreMLRequest(model: model) { (completedReq, error) in
            guard let results = completedReq.results as? [VNClassificationObservation],
                let first = results.first else { return }

            let confidence = "\(first.confidence)".split(separator: ".")
            DispatchQueue.main.async {
                self.objectLabel.text = first.identifier
                self.confidenceLabel.text = " % " + confidence[1].prefix(2)
            }
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

}
