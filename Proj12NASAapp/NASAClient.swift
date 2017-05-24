//
//  NasaNetworking.swift
//  Proj12NASAapp
//
//  Created by Vernon G Martin on 5/16/17.
//  Copyright © 2017 Vernon G Martin. All rights reserved.
//

import Foundation

typealias JSONDataObject = [String:AnyObject]
let apiKey = "cHE99pnRwez9V6O6Aj7G8iQfipLALVQFGCmO0r4M"

//MARK: - Error Messages
enum NetworkingErrors: Error{
    case couldNotConnect
    case noDataRecieved(String)
    case couldNotConvertDataToJson(String)
}

class NASAClient: APIClient {
    lazy var session: URLSession = {
        return URLSession(configuration: self.configuration)
    }()
    var configuration: URLSessionConfiguration
    var nasaDataDictionary:JSONDataObject?
    
    init(config: URLSessionConfiguration){
        self.configuration = config
    }
    
    func fetchData(url: URLRequest, completion: @escaping (Bool, JSONDataObject)-> Void) {
        let requestURL = url
        let session = URLSession.shared
        let task = session.dataTask(with: requestURL) { (data, response, error) in
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
        task.resume()
    }
}
