//
//  MailPostcardVC.swift
//  Proj12NASAapp
//
//  Created by Vernon G Martin on 5/17/17.
//  Copyright © 2017 Vernon G Martin. All rights reserved.
//

import UIKit

class MailPostcardVC: UIViewController{

    @IBOutlet weak var postCardView: UIView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var mailMessageTextView: UITextView!
    @IBOutlet weak var postCardRoverImage: UIImageView!
    @IBOutlet weak var addTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Sets look and feel of view controller
        self.navigationController?.isNavigationBarHidden = true
        mailMessageTextView.isHidden = true
        sendMessageButton.isEnabled = false
        postCardRoverImage.isUserInteractionEnabled = true
        
        //Adds tap gesture to dismiss keyboard if user tapps off of the keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MailPostcardVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = true
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

    //Navigates back to the screen with the post card images to choose from
    @IBAction func homeButtonPressed(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func roverImageTapped(_ sender: Any) {
        sendMessageButton.isEnabled = true
        mailMessageTextView.isHidden = false
        addTextLabel.isHidden = true
    }
    
    //Displays Mail View
    @IBAction func sendMessageButtonTapped(_ sender: Any) {
        let imageToMail:UIImage = self.postCardView.screenShot()
        let mailClient: MailClient = MailClient()
        mailClient.imageData = UIImagePNGRepresentation(imageToMail)
        mailClient.checkMailSendCapability()
        present(mailClient, animated: true, completion: nil)
    }
}

//MARK: - Extension: Custome screenshot extension to take a screenshot of the postcare image displayed on the view
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
