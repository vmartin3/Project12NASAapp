//
//  EyeInTheSkyVC.swift
//  Proj12NASAapp
//
//  Created by Vernon G Martin on 5/21/17.
//  Copyright © 2017 Vernon G Martin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class EyeInTheSkyVC: UIViewController {
    
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    var apiCall: NASAClient = NASAClient(config: .default)

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.sharedLocationInstance.determineMyCurrentLocation()
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! SearchController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable 
        
        guard let searchBar = resultSearchController?.searchBar else {return}
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    func displayNasaImage(){
        apiCall.fetchData { (fetchSuccess, nasaData) in
            if fetchSuccess {
                
            } else {
                
            }
        }
    }

}

extension EyeInTheSkyVC: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city), \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

extension EyeInTheSkyVC : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGRect(x: 0, y: 0, width: 30, height: 30)
        let button = UIButton(frame: smallSquare)
        button.setBackgroundImage(UIImage(named: "Satellite"), for: .normal)
        button.addTarget(self, action: Selector("displayNasaImage"), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}
