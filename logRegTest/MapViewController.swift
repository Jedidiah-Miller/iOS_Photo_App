//
//  homeViewController.swift
//  logRegTest
//
//  Created by jed on 7/5/18.
//  Copyright © 2018 jed. All rights reserved.


import Foundation
import UIKit
import MapKit
import Firebase
import CoreLocation


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var postMapView: MKMapView!

    @IBAction func recenterTapped(_ sender: UIButton) { recenterMap = true }

    @IBAction func closeMap(_ sender: Any) { self.dismiss(animated: true, completion: nil) }

    let postLocation = MKPointAnnotation()

    var memoryList = [Memory] ()

    var // map booleans
        initialMap: Bool = true,
        recenterMap: Bool = false,
        userDragMap: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()

        

    }



    //   map function -- location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let location = locations.last else { print("no location"); return }

        print("location updated")

        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

        if initialMap {

            initialMap = false

            setInitialMap( center: center )

        } else if recenterMap {

            recenterMap = false

            print(location.coordinate)

            self.postMapView.setCenter(center, animated: true)

        }

    }

    func setInitialMap(center: CLLocationCoordinate2D ) {

        print("setting initial map scale")

        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 1609.34 , longitudinalMeters: 1609.34 ) // one mile radius

        self.postMapView.setRegion(region, animated: false)

    }


    func annotationView(viewFor annotation: MKAnnotation ) -> MKAnnotationView? {
        var annotationView = postMapView.dequeueReusableAnnotationView(withIdentifier: "postDisplay")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "postDisplay")
            annotationView?.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        annotationView!.image = UIImage(named: "IMG_0164.jpg")
        return annotationView
    }




    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)


    }



}
