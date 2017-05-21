//
//  Location Manager.swift
//  Proj12NASAapp
//
//  Created by Vernon G Martin on 5/21/17.
//  Copyright © 2017 Vernon G Martin. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationManager: CLLocationManager {
    static let sharedLocationInstance = LocationManager()
    var locationManager: CLLocationManager!
    
    
    func determineMyCurrentLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
    }
}

extension LocationManager : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: (location?.coordinate)!, span: span)
            var eyeInTheSky: EyeInTheSkyVC = EyeInTheSkyVC()
            eyeInTheSky.mapView?.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}
