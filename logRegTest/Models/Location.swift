//
//  Location.swift
//  logRegTest
//
//  Created by jed on 7/8/18.
//  Copyright © 2018 jed. All rights reserved.
//

import Foundation
import MapKit

class Location: NSObject, MKAnnotation {

//    var id: String
    var coordinate: CLLocationCoordinate2D,
        altitude: Double
    
    init( lat: CLLocationDegrees, long: CLLocationDegrees, alt: Double) {

//        self.id = id

        coordinate = CLLocationCoordinate2DMake(lat, long)

        altitude = alt

    }



}

