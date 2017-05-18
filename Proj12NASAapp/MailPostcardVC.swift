//
//  MailPostcardVC.swift
//  Proj12NASAapp
//
//  Created by Vernon G Martin on 5/17/17.
//  Copyright © 2017 Vernon G Martin. All rights reserved.
//

import UIKit

class MailPostcardVC: UIViewController {

    @IBOutlet weak var postCardView: UIImageView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var mailMessageTextView: UITextView!
    @IBOutlet weak var postCardRoverImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mailMessageTextView.isHidden = true
        sendMessageButton.isEnabled = false
        postCardRoverImage.isUserInteractionEnabled = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func roverImageTapped(_ sender: Any) {
        sendMessageButton.isEnabled = true
        mailMessageTextView.isHidden = false
        
    }
    @IBAction func sendMessageButtonTapped(_ sender: Any) {
        let imageToMail:UIImage = postCardView.screenShot()
        let mailClient: MailClient = MailClient()
        mailClient.imageData = UIImagePNGRepresentation(imageToMail)
        mailClient.checkMailSendCapability()
    }
}

extension UIView {
    func screenShot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, UIScreen.main.scale)
        let contextRef = UIGraphicsGetCurrentContext()
        contextRef!.translateBy(x: 0, y: 0)
        layer.render(in: contextRef!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
