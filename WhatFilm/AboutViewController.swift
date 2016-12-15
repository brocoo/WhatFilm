//
//  AboutViewController.swift
//  WhatFilm
//
//  Created by Julien Ducret on 12/12/2016.
//  Copyright © 2016 Julien Ducret. All rights reserved.
//

import UIKit
import MessageUI

public final class AboutViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var githubButton: UIButton!
    @IBOutlet weak var linkedInButton: UIButton!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    // MARK: - UIViewController life cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.track(viewContent: "About", ofType: "View")
    }
    
    // MARK: - UI Setup
    
    fileprivate func setupUI() {
        self.title = "About"
        self.creditLabel.text = "App icon by Shmidt Sergey from the Noun Project."
        self.creditLabel.apply(style: TextStyle.bodyTiny)
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        self.versionLabel.apply(style: TextStyle.bodyDemiBold)
        self.versionLabel.text = "WhatMovie v\(versionNumber) build \(buildNumber)"
    }
    
    // MARK: - IBAction functions
    
    @IBAction func shareButtonTapped(sender: UIButton) {
        
        let shareText: String = "Check out WhatMovie!"
        let url: URL = URL(string: "https://itunes.apple.com/us/app/spores/id718495353?mt=8")!
        let items: [Any] = [shareText, url]
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func mailButtonTapped(sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            
            let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
            let mailComposerViewController = MFMailComposeViewController()
            mailComposerViewController.mailComposeDelegate = self
            mailComposerViewController.setToRecipients(["brocoo+whatfilm@gmail.com"])
            mailComposerViewController.setSubject("Hello!")
            mailComposerViewController.setMessageBody("\n\n\n\nSent from WhatMovie iOS - v\(versionNumber) build \(buildNumber)", isHTML: false)
            self.present(mailComposerViewController, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Can't send Email", message: "Your device can't send e-mail. Please check your email configuration and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Go to settings", style: .default) { _ in
                alert.dismiss(animated: true, completion: nil)
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                alert.dismiss(animated: true, completion: nil)
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func githubButtonTapped(sender: UIButton) {
        let url = URL(string: "https://github.com/brocoo")!
        self.open(url: url, withAlertMessage: "You will redirected to Github.")
    }
    
    @IBAction func linkedInButtonTapped(sender: UIButton) {
        let url = URL(string: "https://www.linkedin.com/in/julien-ducret")!
        self.open(url: url, withAlertMessage: "You will redirected to LinkedIn.")
    }
    
    // MARK: -
    
    fileprivate func open(url: URL, withAlertMessage message: String) {
        UserDefaults.performOnce(forKey: "", perform: { _ in
            let alert = UIAlertController(title: "Leave the app?", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
                alert.dismiss(animated: true, completion: nil)
                UIApplication.shared.openURL(url)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                alert.dismiss(animated: true, completion: nil)
            })
            self.present(alert, animated: true, completion: nil)
        }, elsePerform: { _ in
            UIApplication.shared.openURL(url)
        })
    }
}

// MARK: -

extension AboutViewController: MFMailComposeViewControllerDelegate {
    
    // MARK: -
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
