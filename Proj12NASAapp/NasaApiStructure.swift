//
//  NasaApiStructure.swift
//  Proj12NASAapp
//
//  Created by Vernon G Martin on 5/16/17.
//  Copyright © 2017 Vernon G Martin. All rights reserved.
//

import Foundation

enum Rovers: String {
    case Curiosity = "Curiosity"
    case Opportunity = "Opportunity"
    case Spirit = "Spirit"
}

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

enum MarsRover: Endpoint {
    
    case Rovers(roverName: String)
    case Earth
    
    var baseURL: URL{
        switch self {
            case .Rover
            return URL(string: "https://api.nasa.gov/mars-photos/api/v1/rovers/")!
        }
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
