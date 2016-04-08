//
//  AccountNavController.swift
//  TradableExampleApp
//
//  Created by Tradable ApS on 14/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class AccountNavController: UINavigationController, TradableEventsDelegate, TradableOrderEntryDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tradableAccountMetricsUpdated(accountMetrics: TradableAccountMetrics) {
        let accountVC = self.viewControllers[0] as! AccountViewController
        accountVC.balance = accountMetrics.balance
        accountVC.equity = accountMetrics.equity
        accountVC.openPnL = accountMetrics.openProfit
        accountVC.marginAmountUsed = accountMetrics.marginAmountUsed
        accountVC.updateData()
    }
    
    func tradableOrderEntryDismissed(order: TradableOrder?) {
        tradable.delegate = self
        (tabBarController as! TabBarController).deselectMiddleButton()
    }
}