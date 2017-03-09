//
//  PortfolioViewController.swift
//  PocketPortfolio
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
                portfolioView?.isHidden = true
                emptyPortfolioLabel?.isHidden = true
                activityIndicator?.isHidden = false
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

    func showPositionDetails(_ position: TradablePosition) {
        self.navigationController?.tradablePresentPositionDetail(for: currentAccount!, with: position, delegate: nil, presentationStyle: UIModalPresentationStyle.overCurrentContext)
    }

    func showEditOrder(_ order: TradableOrder) {
        self.navigationController?.tradablePresentEditOrder(for: currentAccount!, with: order, delegate: nil, presentationStyle: UIModalPresentationStyle.overCurrentContext)
    }

    func isPortfolioEmpty(_ empty: Bool) {
        if waiting {
            portfolioView.isHidden = true
            emptyPortfolioLabel.isHidden = true
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            if empty {
                portfolioView.isHidden = true
                emptyPortfolioLabel.isHidden = false
                activityIndicator.stopAnimating()
            } else {
                portfolioView.isHidden = false
                emptyPortfolioLabel.isHidden = true
                activityIndicator.stopAnimating()
            }
        }
    }
}
