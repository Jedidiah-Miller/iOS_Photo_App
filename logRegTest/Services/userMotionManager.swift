//
//  userMotionManager.swift
//  logRegTest
//
//  Created by jed on 7/11/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import CoreMotion

let Fps60 = 0.016

class userMotionManager {
    
    let motionManager: CMMotionManager
    let updateInterval: Double = Fps60
    var gyroObservers = [(Double, Double, Double) -> Void]()
    var accelerometerObservers = [(Double, Double, Double) -> Void]()
    
    //  public interface
    
    init() {
        motionManager = CMMotionManager()
        initMotionEvents()
    }
    
    func addGyroObserver(observer: @escaping (Double, Double, Double) -> Void) {
        gyroObservers.append(observer)
    }
    
    func addAccelerometerObserver(observer: @escaping (Double, Double, Double) -> Void) {
        accelerometerObservers.append(observer)
    }
    
    func clearObservers() {
        gyroObservers.removeAll()
        accelerometerObservers.removeAll()
    }
    
//  internal methods
    
    private func notifyGyroObservers(x: Double, y: Double, z: Double) {
        for observer in gyroObservers {
            observer(x, y, z)
        }
    }
    
    private func notifyAccelerometerObservers(x: Double, y: Double, z: Double) {
        for observer in accelerometerObservers {
            observer(x, y, z)
        }
    }
    
    private func roundDouble(value: Double) -> Double {
        return round(1000 * value)/100
    }
    
    private func initMotionEvents() {
        if motionManager.isGyroAvailable || motionManager.isAccelerometerAvailable {
            motionManager.deviceMotionUpdateInterval = updateInterval;
            motionManager.startDeviceMotionUpdates()
        }
        
// gyroscope analytics
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = updateInterval
            motionManager.startGyroUpdates(to: OperationQueue.current!, withHandler: { (gyroData: CMGyroData?, NSError) -> Void in
                let rotation = gyroData!.rotationRate
                let x = self.roundDouble(value: rotation.x)
                let y = self.roundDouble(value: rotation.y)
                let z = self.roundDouble(value: rotation.z)
                self.notifyGyroObservers(x: x, y: y, z: z)
                
                if (NSError != nil){
                    print("\(String(describing: NSError))")
                }
            })
        } else {
            print("gyroscope NOT available")
        }
        
// accelerometer analytics
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = updateInterval
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (accelerometerData: CMAccelerometerData?, NSError) -> Void in
                
                if let acceleration = accelerometerData?.acceleration {
                    let x = self.roundDouble(value: acceleration.x)
                    let y = self.roundDouble(value: acceleration.y)
                    let z = self.roundDouble(value: acceleration.z)
                    self.notifyAccelerometerObservers(x: x, y: y, z: z)
                }
                if(NSError != nil) {
                    print("\(String(describing: NSError))")
                }
            }
        } else {
            print("accelerometer NOT available")
        }
    }
}


//func initAccelGyro() {
//    motionManager.addGyroObserver(observer: {(x: Double, y: Double, z: Double) -> Void in
//        let summary = Int(abs(x) + abs(y) + abs(z))
//        print("Gyro: \(summary)")
//    })
//}
