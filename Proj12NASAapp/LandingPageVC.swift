//
//  LandingPage.swift
//  Proj12NASAapp
//
//  Created by Vernon G Martin on 5/22/17.
//  Copyright © 2017 Vernon G Martin. All rights reserved.
//

import UIKit

class LandingPage: UIViewController {
    
    //Simpy hides navigation bar for the homescreen view controller
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
