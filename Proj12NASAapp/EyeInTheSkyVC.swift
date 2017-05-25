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

//MARK: - Custom Protocol
protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

enum EyeInTheSkyErrors:Error{
    case UnableToCreateImage(String)
}

class EyeInTheSkyVC: UIViewController {
    
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    var apiCall: NASAClient = NASAClient(config: .default)
    var nasaData: [String:AnyObject]?
    var earthSatelliteImage: UIImage?

    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func infoPressed(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "Welcome!", message: "This is the Eye in the Sky feature. Search for a location > Tap on the pin > Tap on the satellite icon to see latest satellite image of your selected location from the Landsat 8 Satellite", preferredStyle: .alert)
        let okay = UIAlertAction(title: "Got It", style: .default, handler: nil)
        alert.addAction(okay)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //MARK: - ViewController Set Up
        //Instantiates Search View Controller
        LocationManager.sharedLocationInstance.determineMyCurrentLocation()
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! SearchController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable 
        
        //Adds search bar to the top navigation bar
        guard let searchBar = resultSearchController?.searchBar else {return}
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        self.navigationController?.isNavigationBarHidden = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        //Passes mapview value from Location Manager Class and to this class making it accessable
        locationSearchTable.mapView = mapView
        LocationManager.sharedLocationInstance.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    func prepareSatelliteImage(){
        //Fetches Landsat 8 satellite imagery using the api based on the location the user searched for
        apiCall.fetchData(url: EarthImagery.Earth(latitude: (selectedPin?.coordinate.latitude)!, longitude: (selectedPin?.coordinate.longitude)!).fullRequest) { (fetchSuccess, nasaData) in
            if fetchSuccess {
                self.nasaData = nasaData
                self.displayNasaImage(completion: {
                })
                DispatchQueue.main.async() {
                self.performSegue(withIdentifier: "ShowImage", sender: self)
                }
                
            } else {
               let message = DisplayErrorMessage(message: "Error fetching satellite image data", view: self)
                message.showMessage()
            }
        }
    }
    
    //Creates UIImage from the JSON array for selected key using custom Dictionary extension
    func displayNasaImage(completion:() -> Void){
        guard let data = nasaData else {
            print("no data found")
            return
        }
        do{
        earthSatelliteImage = try nasaData?.createImageFromJSONString(dataArray: data, key: "url")
        } catch {
            print("Unable to create image from JSON")
        }
    }
    
    //Segue to new VC to display image
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowImage"{
        let destinationVC = segue.destination as! SatelliteImageDisplayVC
        destinationVC.imageToDisplay = earthSatelliteImage
        }
    }
}

//MARK: - HandleMapSearch Protocol Implementation
extension EyeInTheSkyVC: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        //Cache the pin so we can use it throughout this class
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        
        //Sets Pin annotation with the city and name of selected place
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city), \(state)"
        }
        
        //Add pin to app and focus in on the location where the pin is
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

//MARK: - MKMapViewDelegate
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
        button.setBackgroundImage(UIImage(named: "SatelliteButtonIcon"), for: .normal)
        button.addTarget(self, action: #selector(EyeInTheSkyVC.prepareSatelliteImage), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}

//MARK: - Dictionary Class extension to convert dictionary object with key value to UIImage
extension Dictionary{
    func createImageFromJSONString(dataArray: [String:AnyObject], key: String) throws -> UIImage{
        do{
            let dictionaryParamter = dataArray[key]
            let imageString:String = dictionaryParamter as! String
            let imageURL = URL(string: imageString)
            let imageData = try Data(contentsOf: imageURL!)
            guard let image = UIImage(data: imageData) else {
                print("Could not create image")
                return UIImage()
            }
            return image
        }catch {
                throw EyeInTheSkyErrors.UnableToCreateImage("Unable to create image")
        }
    }
}
