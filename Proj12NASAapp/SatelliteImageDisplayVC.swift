//
//  SatelliteImageDisplayVC.swift
//  Proj12NASAapp
//
//  Created by Vernon G Martin on 5/21/17.
//  Copyright © 2017 Vernon G Martin. All rights reserved.
//

import UIKit

class SatelliteImageDisplayVC: UIViewController {
    @IBOutlet weak var imageGrabbedFromAPI: UIImageView!
    var imageToDisplay: UIImage?
    
    //Sets look and feel for view controller 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        imageGrabbedFromAPI.image = imageToDisplay
    }
}
