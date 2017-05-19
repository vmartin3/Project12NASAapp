//
//  RoverPhoto.swift
//  Proj12NASAapp
//
//  Created by Vernon G Martin on 5/16/17.
//  Copyright © 2017 Vernon G Martin. All rights reserved.
//

import Foundation
import UIKit

class RoverPhoto{
    //MARK: - Properties
    var roverName: String
    var thumbnailImage: UIImage
    var date: String
    
    init(name: String, date: String, image: UIImage) {
        self.roverName = name
        self.date = date
        self.thumbnailImage = image
    }
}
