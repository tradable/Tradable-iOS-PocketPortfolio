//
//  ViewController.swift
//  PocketPortfolio
//
//  Created by Tradable ApS on 07/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit
import SafariServices

import TradableAPI

class ViewController: UIViewController, TradableAuthDelegate, SFSafariViewControllerDelegate {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!

    @IBOutlet weak var topLogoConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingLogoConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.leadingLogoConstraint.constant = (UIScreen.main.bounds.width - logoWidthConstraint.constant)/2.0
        self.topLogoConstraint.constant = UIScreen.main.bounds.height/2.0 - logoHeightConstraint.constant - 50.0
        self.view.layoutIfNeeded()

        UIView.animate(withDuration: 0.4, delay: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.logoHeightConstraint.constant = 65.0
            self.logoWidthConstraint.constant = 65.0
            self.topLogoConstraint.constant = UIScreen.main.bounds.height/3.0
            self.leadingLogoConstraint.constant = (UIScreen.main.bounds.width - 256.0)/2.0
            self.view.layoutIfNeeded()
            }) { (_) -> Void in
                self.titleLabel.transform = self.titleLabel.transform.scaledBy(x: 0.25, y: 0.25)
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.titleLabel.transform = self.titleLabel.transform.scaledBy(x: 4.0, y: 4.0)
                    self.titleLabel.isHidden = false
                    self.view.layoutIfNeeded()
                    }, completion: { (_) -> Void in
                        let color = self.signInButton.backgroundColor
                        self.signInButton.backgroundColor = UIColor(red: 16.0/255.0, green: 137.0/255.0, blue: 147.0/255.0, alpha: 1.0)
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            self.signInButton.isHidden = false
                            self.signInButton.backgroundColor = color
                            }, completion: nil)
                })
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func signIn(_ sender: UIButton) {
        tradable.authenticateWith(appId: appID, uri: customURI, viewController: self)
    }
}
