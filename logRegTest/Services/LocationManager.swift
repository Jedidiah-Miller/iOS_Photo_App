//
//  LocationManager.swift
//  logRegTest
//
//  Created by jed on 10/21/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import CoreLocation


protocol LocationManagerDelegate: class {

    func locationManagerDidUpdateLocation(_ locationManager: LocationManager, location: CLLocation)

    func locationManagerDidUpdateHeading(_ locationManager: LocationManager, heading: CLLocationDirection, accuracy: CLLocationDirection)

}


public class LocationManager: NSObject, CLLocationManagerDelegate {

    weak var delegate: LocationManagerDelegate?
    var locationManager: CLLocationManager?

    var currentLocation: CLLocation?
    var userLocationArray: [CLLocation] = []

    private(set) public var heading: CLLocationDirection?
    private(set) public var headingAccuracy: CLLocationDegrees?

    var floor: CLFloor?

    var visit: CLVisit?

    override init() {
        super.init()

        print("LOCATIONMANAGER - init()")

        self.locationManager = CLLocationManager()
        self.locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager!.distanceFilter = kCLDistanceFilterNone
        self.locationManager!.headingFilter = kCLHeadingFilterNone
        self.locationManager!.pausesLocationUpdatesAutomatically = false
        self.locationManager!.delegate = self
        self.locationManager!.startUpdatingHeading()
        self.locationManager!.startUpdatingLocation()

        self.locationManager!.requestWhenInUseAuthorization()

        self.currentLocation = self.locationManager!.location
    }


    // this does nothing rn
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let currLocation = locations[0]

        for newLocation in locations {

            userLocationArray.append(newLocation)

        }

        self.currentLocation = manager.location

        print("ULM - current location", currLocation)
        print("ULM - manager location - should be the same as above", self.currentLocation as Any)


    }


    func checkLocationMangers() {

        if CLLocationManager.locationServicesEnabled() {

            checkLocationAuthorization()

        } else {

            // alert the user
            // do the tinder style popup that lets you change the setting from the app

        }

    }

    func checkLocationAuthorization() {

        switch CLLocationManager.authorizationStatus() {

        case .authorizedWhenInUse:
            break

        case .denied:
            break

        case .notDetermined:
            locationManager!.requestWhenInUseAuthorization()
            locationManager!.requestAlwaysAuthorization()

        case .restricted:
            break

        case .authorizedAlways:
            break

        }


    }






}
