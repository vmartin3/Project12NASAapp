//
//  MailClient.swift
//  Proj12NASAapp
//
//  Created by Vernon G Martin on 5/18/17.
//  Copyright © 2017 Vernon G Martin. All rights reserved.
//

import Foundation
import MessageUI
import UIKit

class MailClient: UIViewController,MFMailComposeViewControllerDelegate{
    
    var imageData: Data?
    
    func checkMailSendCapability(){
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        sendEmail()
    }
    
    func sendEmail() {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients(["vernonmartin11@gmail.com"])
        composeVC.setSubject("A Message From Space!")
        composeVC.setMessageBody("I hope all is well, check out this image from space!", isHTML: false)
        composeVC.addAttachmentData(imageData!, mimeType:  "image/png", fileName: "roverImage.png")
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
}

}
    

