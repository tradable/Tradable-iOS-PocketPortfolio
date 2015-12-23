//
//  PortfolioViewDelegate.swift
//  TradableExampleApp
//
//  Created by Tradable ApS on 15/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import Foundation

import TradableAPI

protocol PortfolioViewDelegate: class {
    func showPositionDetail(position: TradablePosition)
    func showEditOrder(order: TradableOrder)
    func isPortfolioEmpty(empty: Bool)
}