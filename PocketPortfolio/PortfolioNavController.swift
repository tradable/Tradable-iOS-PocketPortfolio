//
//  PortfolioNavController.swift
//  TradableExampleApp
//
//  Created by Tradable ApS on 13/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class PortfolioNavController: UINavigationController, TradableEventsDelegate, TradablePositionDetailDelegate, TradableEditOrderDelegate, TradableOrderEntryDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountChanged()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PortfolioNavController.accountChanged), name: accountDidChangeNotificationKey, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func tradablePositionsUpdated(positions: TradablePositions) {
        let portfolioVC = self.viewControllers[0] as! PortfolioViewController
        
        if portfolioVC.waiting {
            portfolioVC.waiting = false
        }
        
        //a list of identifiers of open positions
        var positionIdList:[String] = []
        
        for position in positions.open {
            portfolioVC.portfolioView?.addOrUpdatePosition(position)
            positionIdList.append(position.id)
        }
        
        //if there is a position in view whose ID is not on the list, we need to remove it
        if let pvPositions = portfolioVC.portfolioView?.positions {
            for (positionId, _) in pvPositions {
                if !positionIdList.contains(positionId) {
                    portfolioVC.portfolioView?.removePosition(positionId)
                }
            }
        }
        
        for position in positions.recentlyClosed {
            portfolioVC.portfolioView?.addClosedPosition(position)
        }
        
        portfolioVC.portfolioView?.setNeedsLayout()
    }
    
    func tradableOrdersUpdated(orders: TradableOrders) {
        let portfolioVC = self.viewControllers[0] as! PortfolioViewController
        
        if portfolioVC.waiting {
            portfolioVC.waiting = false
        }
        
        //a list of identifiers of pending orders
        var orderIdList:[String] = []
        
        for order in orders.pending {
            portfolioVC.portfolioView?.addOrUpdateOrder(order)
            orderIdList.append(order.id)
        }
        
        //if there is an order in view whose ID is not on the list, we need to remove it
        if let pvOrders = portfolioVC.portfolioView?.orders {
            for (orderId, _) in pvOrders {
                if !orderIdList.contains(orderId) {
                    portfolioVC.portfolioView?.removeOrder(orderId)
                }
            }
        }
                
        portfolioVC.portfolioView?.setNeedsLayout()
    }
    
    func accountChanged() {
        if let currentAccount = currentAccount {
            let portfolioVC = self.viewControllers[0] as! PortfolioViewController
            portfolioVC.waiting = true
            portfolioVC.clearPortfolio()
            self.navigationBar.topItem?.title = "My \(currentAccount.displayName) Account"
        }
    }

    func tradableOrderEntryDismissed(order: TradableOrder?) {
        tradable.delegate = self
        (tabBarController as! TabBarController).deselectMiddleButton()
        if order != nil {
            tabBarController?.selectedViewController = tabBarController?.viewControllers?[1]
            tradable.delegate = tabBarController?.viewControllers?[1] as? TradableEventsDelegate
        }
    }

    func tradablePositionDetailDismissed() {
        tradable.delegate = self
    }
    
    func tradableEditOrderDismissed() {
        tradable.delegate = self
    }
    
}