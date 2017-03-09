//
//  PortfolioViewDelegate.swift
//  PocketPortfolio
//
//  Created by Tradable ApS on 15/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import Foundation

import TradableAPI

protocol PortfolioViewDelegate: class {
    func showPositionDetails(_ position: TradablePosition)
    func showEditOrder(_ order: TradableOrder)
    func isPortfolioEmpty(_ empty: Bool)
}
