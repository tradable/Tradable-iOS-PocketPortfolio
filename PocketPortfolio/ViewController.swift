//
//  ViewController.swift
//  TradableExampleApp
//
//  Created by Tradable ApS on 07/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class ViewController: UIViewController, TradableAuthDelegate {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var topLogoConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingLogoConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.leadingLogoConstraint.constant = (UIScreen.mainScreen().applicationFrame.width - logoWidthConstraint.constant)/2.0
        self.topLogoConstraint.constant = UIScreen.mainScreen().applicationFrame.height/2.0 - logoHeightConstraint.constant - 50.0
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(0.4, delay: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.logoHeightConstraint.constant = 65.0
            self.logoWidthConstraint.constant = 65.0
            self.topLogoConstraint.constant = UIScreen.mainScreen().applicationFrame.height/3.0
            self.leadingLogoConstraint.constant = (UIScreen.mainScreen().applicationFrame.width - 256.0)/2.0
            self.view.layoutIfNeeded()
            }) { (finished) -> Void in
                self.titleLabel.transform = CGAffineTransformScale(self.titleLabel.transform, 0.25, 0.25)
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.titleLabel.transform = CGAffineTransformScale(self.titleLabel.transform, 4.0, 4.0)
                    self.titleLabel.hidden = false
                    self.view.layoutIfNeeded()
                    }, completion: { (finished) -> Void in
                        let color = self.signInButton.backgroundColor
                        self.signInButton.backgroundColor = UIColor(red: 16.0/255.0, green: 137.0/255.0, blue: 147.0/255.0, alpha: 1.0)
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.signInButton.hidden = false
                            self.signInButton.backgroundColor = color
                            }, completion: nil)
                })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signIn(sender: UIButton) {
        //Activate Tradable with last known tokens or ask a user to log in to his/her account
        tradable.activateOrAuthenticate(appID, uri: customURI, webView: nil)
    }
}