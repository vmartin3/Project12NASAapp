//
//  DisplayMessage.swift
//  Proj12NASAapp
//
//  Created by Vernon G Martin on 5/22/17.
//  Copyright © 2017 Vernon G Martin. All rights reserved.
//

import Foundation
import UIKit

class DisplayErrorMessage{
    let message: String
    let viewController: UIViewController
    
    init(message:String, view: UIViewController){
        self.message = message
        self.viewController = view
    }
    
    func showMessage(){
        let alert = UIAlertController(title: "Oops!", message: self.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
        self.viewController.present(alert, animated: true, completion: nil)
    }
}
