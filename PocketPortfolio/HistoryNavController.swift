//
//  HistoryNavController.swift
//  TradableExampleApp
//
//  Created by Tradable ApS on 16/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class HistoryNavController: UINavigationController, TradableAPIDelegate, TradableOrderEntryDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tradableOrderEntryDismissed(order: TradableOrder?) {
        tradable.delegate = self
        (tabBarController as! TabBarController).deselectMiddleButton()
    }
}