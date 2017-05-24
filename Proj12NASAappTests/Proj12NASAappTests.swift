//
//  Proj12NASAappTests.swift
//  Proj12NASAappTests
//
//  Created by Vernon G Martin on 5/16/17.
//  Copyright © 2017 Vernon G Martin. All rights reserved.
//

import XCTest
import CoreLocation
import UIKit
import MapKit

@testable import Proj12NASAapp

class Proj12NASAappTests: XCTestCase {
    
    var nasaDataDictionary:JSONDataObject?
    var session: URLSession?
    var locationError: String?
    
    override func setUp() {
        super.setUp()
        session = URLSession(configuration: .default)
    }
    
    override func tearDown() {
        super.tearDown()
        session = nil
    }
    
    
    //Create Image from JSON Data
    func createImageFromJSONString(dataArray: [String:AnyObject], key: String) -> UIImage {
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
            print("Unable to create image")
        }
        return UIImage()
    }
    
    //Create Address from MKPlacemark
    func getAddress(selectedItem:MKPlacemark) -> String {
        guard let city = selectedItem.addressDictionary?["locality"],
        let state = selectedItem.addressDictionary?["administrativeArea"] else {return ""}
        let address = "\(city), \(state)"
    
        return address
    }
    
    //Create Rover Image object which includes a Rover name, date and image
    func createRover(name:String, date: String, image:[String:AnyObject])->RoverPhoto {
        var roverName: String
        var roverDate: String
        var roverImage: UIImage = UIImage()
        
        do{
            roverName = name
            roverDate = date 
            roverImage = try image.createImageFromJSONString(dataArray: image, key: "img_src")
        }catch{
            print("could not create image from JSON")
        }
        
        let rover  = RoverPhoto(name: roverName, date: roverDate, image: roverImage)
        return rover
    }
    
    //Testing Data Parsing
    func fetchData(longitude:String?, latitude: String?, completion: @escaping (Bool, [String:AnyObject]) -> Void){
        
    
        guard let url = URL(string: "https://api.nasa.gov/planetary/earth/imagery?lon=\(longitude!)&lat=\(latitude!)&date=2017-02-01&cloud_score=False&api_key=cHE99pnRwez9V6O6Aj7G8iQfipLALVQFGCmO0r4M") else {
            locationError = "There was an error obtaining your location please try again"
            self.nasaDataDictionary = [:] as JSONDataObject
            completion(false, self.nasaDataDictionary!)
            return
        }
        let requestURL = URLRequest(url: url)
        let task = session?.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("Error making the call to get data")
                return
            }
            
            guard let responseData = data else {
                print("Error did not recieve data")
                return
            }
            DispatchQueue.global(qos: .background).async {
                do{
                    self.nasaDataDictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? JSONDataObject
                    completion(true, self.nasaDataDictionary!)
                }catch {
                    print("Error converting to JSON")
                    self.nasaDataDictionary = nil
                    completion(false, self.nasaDataDictionary!)
                    return
                }
            }
        }
        task?.resume()
}
    
    func testDataParsing() {
        let expectedResult = expectation(description: "Calls NASA Rover API and returns some data")
        fetchData(longitude: "100.75", latitude: "1.5") { (success, resultData) in
            XCTAssertTrue(success)
            expectedResult.fulfill()
        }
        
        waitForExpectations(timeout: 15) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testMissingCoordinates(){
        let expectedResult = expectation(description: "Calls NASA Rover API with no coordinates - handles nil gracefully and returns friendly error letting user no no data was found")
        fetchData(longitude: " ", latitude: " ") { (success, resultData) in
            XCTAssertFalse(success)
            XCTAssert(self.locationError == "There was an error obtaining your location please try again")
            expectedResult.fulfill()
        }
        
        waitForExpectations(timeout: 15) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testCreateImage(){
       let testImage: UIImage = createImageFromJSONString(dataArray: ["imageStub" : "https://earthengine.googleapis.com/api/thumb?thumbid=71bb1e2e1458c0aed6bf2f689c5d38da&token=51cd71f2c669542cc48effd7572aa10e" as AnyObject], key: "imageStub")
        XCTAssertNotNil(testImage, "Failed to create image from the string URL provided")
    }
    
    func testCreateRover(){
        let testRover:RoverPhoto = createRover(name: "TestRover", date: "3-23-2015", image: ["img_src":"http://mars.jpl.nasa.gov/msl-raw-images/proj/msl/redops/ods/surface/sol/01000/opgs/edr/fcam/FLB_486265257EDR_F0481570FHAZ00323M_.JPG" as AnyObject])
        XCTAssertNotNil(testRover, "No Rover Created")
        XCTAssert(testRover.roverName == "TestRover", "Name was not create succesfully")
    }
    
    func testGettingAddress(){
        let testCoordinates = CLLocationCoordinate2D(latitude: 200.1, longitude: 300.1)
        let addressDictionary = ["thoroughfare": "Webster",
                                 "locality": "TestCity",
                                 "administrativeArea": "NY",
                                 "postalCode": "10801"]
       let address = getAddress(selectedItem: MKPlacemark(coordinate: testCoordinates, addressDictionary: addressDictionary))
        XCTAssert(address == "TestCity, NY", "Incorrect City/State Combination")
    }
}
