//
//  HistoryNavController.swift
//  PocketPortfolio
//
//  Created by Tradable ApS on 16/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class HistoryNavController: UINavigationController, TradableEventsDelegate, TradableOrderEntryDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tradableOrderEntryDismissed(order: TradableOrder?) {
        (tabBarController as! TabBarController).deselectMiddleButton()
    }

    func tradableCandlesUpdated(candles: TradableCandleResponse) {
        let historyVC = viewControllers[0] as! HistoryViewController
        historyVC.candlesUpdated(candles: candles)
    }

    func tradableOrdersUpdated(orders: TradableOrders) {
        let historyVC = viewControllers[0] as! HistoryViewController
        historyVC.ordersUpdated(orders: orders)
    }

    func tradablePositionsUpdated(positions: TradablePositions) {
        let historyVC = viewControllers[0] as! HistoryViewController
        historyVC.positionsUpdated(positions: positions)
    }

    func tradableEventsError(error: TradableError) {
        print(error)
        let historyVC = viewControllers[0] as! HistoryViewController
        historyVC.eventsError(error: error)
    }
}
