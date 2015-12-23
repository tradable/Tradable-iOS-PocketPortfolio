//
//  AccountNavController.swift
//  TradableExampleApp
//
//  Created by Tradable ApS on 14/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class AccountNavController: UINavigationController, TradableAPIDelegate, TradableOrderEntryDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tradableMetricsUpdated(metrics: TradableAccountMetrics) {        
        let accountVC = self.viewControllers[0] as! AccountViewController
        accountVC.balance = metrics.balance
        accountVC.equity = metrics.equity
        accountVC.openPnL = metrics.openProfit
        accountVC.marginUse = metrics.marginUsed
        accountVC.updateData()
    }
    
    func tradableOrderEntryDismissed(order: TradableOrder?) {
        tradable.delegate = self
        (tabBarController as! TabBarController).deselectMiddleButton()
    }
    
    func tradableReady() {
        tradable.getAvailableAccounts { (accounts, error) -> Void in
            if let accounts = accounts {
                accountList = accounts
            }
        }
    }
}