//
//  NasaApiStructure.swift
//  Proj12NASAapp
//
//  Created by Vernon G Martin on 5/16/17.
//  Copyright © 2017 Vernon G Martin. All rights reserved.
//

import Foundation

//Different Rover Names
enum Rovers: String {
    case Curiosity = "Curiosity"
    case Opportunity = "Opportunity"
    case Spirit = "Spirit"
}

//Different Camera Names
enum CameraNames: String {
    case FHAZ = "fhaz"
    case RHAZ = "rhaz"
    case MAST = "mast"
    case CHEMCAM = "chemcam"
    case MAHLI = "mahli"
    case MARDI = "mardi"
    case NAVCAM = "navcam"
    case PANCAM = "pancam"
    case MINITES = "minites"
}

protocol APIClient {
    var session: URLSession { get }
    var configuration: URLSessionConfiguration { get }
}

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var apiKey: String { get }
    var fullRequest: URLRequest { get }
}

//MarsRoverPostCard API Call Details
enum MarsRover: Endpoint {
    
    case Rovers(roverName: String)
    
    var baseURL: URL{
            return URL(string: "https://api.nasa.gov/mars-photos/api/v1/rovers/")!
    }
    
    var apiKey: String{
        return "cHE99pnRwez9V6O6Aj7G8iQfipLALVQFGCmO0r4M"
    }
    
    var path: String{
        switch self {
        case .Rovers(let roverName):
            return "\(roverName)/photos?sol=1000&api_key=\(apiKey)"
        }
    }
    
    var fullRequest: URLRequest{
        let url = URL(string: path, relativeTo: baseURL)
        return URLRequest(url: url!)
    }
}

//Earth Satellite Image API Call details
enum EarthImagery: Endpoint {
    
    case Earth(latitude: Double, longitude: Double)
    
    var baseURL: URL{
        return URL(string: "https://api.nasa.gov/planetary/earth/")!
    }
    
    var apiKey: String{
        return "cHE99pnRwez9V6O6Aj7G8iQfipLALVQFGCmO0r4M"
    }
    
    var path: String{
        switch self{
            case .Earth(let latitude, let longitude):
            return "imagery?lon=\(longitude)&lat=\(latitude)&date=2017-02-01&cloud_score=False&api_key=\(apiKey)"
        }
    }
    
    var fullRequest: URLRequest{
        let url = URL(string: path, relativeTo: baseURL)
        return URLRequest(url: url!)
    }
}
