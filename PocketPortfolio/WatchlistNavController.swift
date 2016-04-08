//
//  WatchlistNavController.swift
//  TradableExampleApp
//
//  Created by Tradable ApS on 09/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class WatchlistNavController: UINavigationController, TradableEventsDelegate, TradableOrderEntryDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tradablePricesUpdated(prices: TradablePrices) {
        let watchlistVC = (self.viewControllers[0] as! WatchlistViewController)
        for price in prices.getPrices() {
            watchlistVC.pricesForSymbols[price.symbol] = (ask: price.ask, bid: price.bid, spread: price.spread)
        }
        if !watchlistVC.editing {
            watchlistVC.updateData()
        }
    }
    
    func tradableOrderEntryDismissed(order: TradableOrder?) {
        tradable.delegate = self
        (tabBarController as! TabBarController).deselectMiddleButton()
    }
}