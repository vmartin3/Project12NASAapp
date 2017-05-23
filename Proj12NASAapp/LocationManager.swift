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

enum LocationManagerErrors: Error{
    case ErrorUpdatingLocation(String)
}

class LocationManager: CLLocationManager {
    static let sharedLocationInstance = LocationManager()
    var locationManager: CLLocationManager!
    var mapView: MKMapView? = nil
    
    //Determine Users Current Location
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


//MARK: - Extension CLLocationManager Delegate
extension LocationManager : CLLocationManagerDelegate {
    
    //If user changes their authorization status
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    //Sets the region of the users current location and sets the view on the app to focus on that location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            guard let coordinates = location?.coordinate else {
                print("Could not find coordinates")
                return
            }
            let region = MKCoordinateRegion(center: coordinates, span: span)
            mapView?.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       let message = DisplayErrorMessage(message: "There has been an error updating Location", view: EyeInTheSkyVC())
        message.showMessage()
        print("Error updating location: \(error)")
    }
}
