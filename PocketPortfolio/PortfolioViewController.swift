//
//  SecondViewController.swift
//  TradableExampleApp
//
//  Created by Tradable ApS on 05/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class PortfolioViewController: UIViewController, PortfolioViewDelegate {
    @IBOutlet weak var portfolioView: PortfolioView!
    @IBOutlet weak var emptyPortfolioLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        
    var waiting = true {
        didSet {
            if waiting == true {
                portfolioView?.hidden = true
                emptyPortfolioLabel?.hidden = true
                activityIndicator?.hidden = false
                activityIndicator?.startAnimating()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        portfolioView.portfolioDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func clearPortfolio() {
        portfolioView?.clear()
    }
    
    func showPositionDetail(position: TradablePosition) {
        tradable.presentPositionDetail(currentAccount!, position: position, delegate: self.navigationController as! PortfolioNavController, presentingViewController: self.navigationController!, presentationStyle: UIModalPresentationStyle.OverCurrentContext)
    }
    
    func showEditOrder(order: TradableOrder) {
        tradable.presentEditOrder(currentAccount!, order: order, delegate: self.navigationController as! PortfolioNavController, presentingViewController: self.navigationController!, presentationStyle: UIModalPresentationStyle.OverCurrentContext)
    }
    
    func isPortfolioEmpty(empty: Bool) {
        if waiting {
            portfolioView.hidden = true
            emptyPortfolioLabel.hidden = true
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
        } else {
            if empty {
                portfolioView.hidden = true
                emptyPortfolioLabel.hidden = false
                activityIndicator.stopAnimating()
            } else {
                portfolioView.hidden = false
                emptyPortfolioLabel.hidden = true
                activityIndicator.stopAnimating()
            }
        }
    }
}