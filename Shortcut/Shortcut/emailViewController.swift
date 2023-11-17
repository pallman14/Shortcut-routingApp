//  Price Allman
//  emailViewController.swift
//  Shortcut


import UIKit
import SafariServices
import MessageUI

///This Swift code defines a view controller (emailViewController) that includes a button. When the button is tapped, it checks if the device can send emails. If it can, it presents an email composer with a pre-filled subject and body. If not, it opens a Safari view controller with a specific URL. The code includes comments explaining each part of the implementation.

class emailViewController: UIViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a button with a specific frame
        let emailBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 220, height: 50))
        
        // Add the button to the view
        view.addSubview(emailBtn)
        
        // Set the title, background color, and text color for the button
        emailBtn.setTitle("Email Client",
                        for: .normal)
        emailBtn.backgroundColor = .systemBlue
        emailBtn.setTitleColor(.white, for: .normal)
        
        // Center the button within the view
        emailBtn.center = view.center
        
        // Add a target for the button tap event
        emailBtn.addTarget(self,
                         action: #selector(didTapButton),
                         for: .touchUpInside)
    }

    // Function called when the button is tapped
    @objc private func didTapButton() {
        
        // Check if the device can send emails
        if MFMailComposeViewController.canSendMail() {
            
            // Create an instance of MFMailComposeViewController
            let vc = MFMailComposeViewController()
            
            // Set the delegate to handle the email composition result
            vc.mailComposeDelegate = self
            
            // Set the subject and body of the email
            vc.setSubject("[Invoice/Bill] for [Your Company Name]")
            vc.setMessageBody("Dear [Customer's Name/Company Name],I hope this email finds you well. We would like to thank you for your business and trust in [Your Company Name]. Attached, you will find the invoice for the [product/service] provided to you.", isHTML: false)
            
            // Present the mail composer view controller
            present(vc, animated: true)
        }
        else {
            // If the device cannot send emails, open a Safari view controller with a predefined URL
            guard let url = URL(string: "https://outlook.office365.com/owa/") else {
                return
            }
            
            // Create a Safari view controller
            let vc = SFSafariViewController(url: url)
            
            // Present the Safari view controller
            present(vc,animated: true)
        }
        
    }
    
    // Function called when the email composition is finished
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // Dismiss the mail composer view controller
        controller.dismiss(animated: true, completion: nil)
    }

}
