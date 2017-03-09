//
//  WatchlistNavController.swift
//  PocketPortfolio
//
//  Created by Tradable ApS on 09/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class WatchlistNavController: UINavigationController, TradableEventsDelegate, TradableOrderEntryDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tradablePricesUpdated(prices: TradablePrices) {
        let watchlistVC = (self.viewControllers[0] as! WatchlistViewController)
        watchlistVC.pricesForInstrumentIds = prices.prices
        if !watchlistVC.isEditing {
            watchlistVC.updateData()
        }
    }

    func tradableOrderEntryDismissed(order: TradableOrder?) {
        (tabBarController as! TabBarController).deselectMiddleButton()
    }
}
