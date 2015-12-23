//
//  PortfolioView.swift
//  TradableExampleApp
//
//  Created by Tradable ApS on 08/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class PortfolioView: UIScrollView {
    var positions:[String:PositionView] = [:]
    var orders:[String:OrderView] = [:]
    var closedPositions:[String:ClosedPositionView] = [:]
    
    weak var portfolioDelegate:PortfolioViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var empty = true
        var fromTop:CGFloat = 10.0
        for positionView in positions.values {
            positionView.frame.origin = CGPoint(x: 10.0, y: fromTop)
            positionView.frame.size.width = bounds.width - 20.0
            fromTop += (positionView.frame.height + 10.0)
            empty = false
        }
        for orderView in orders.values {
            orderView.frame.origin = CGPoint(x: 10.0, y: fromTop)
            orderView.frame.size.width = bounds.width - 20.0
            fromTop += (orderView.frame.height + 10.0)
            empty = false
        }
        for closedPositionView in closedPositions.values {
            closedPositionView.frame.origin = CGPoint(x: 10.0, y: fromTop)
            closedPositionView.frame.size.width = bounds.width - 20.0
            fromTop += (closedPositionView.frame.height + 10.0)
            empty = false
        }
        
        contentSize = CGSize(width: self.frame.width, height: fromTop)
        
        portfolioEmpty(empty)
    }
    
    func addOrUpdatePosition(position: TradablePosition) {
        if positions[position.id] == nil {
            let pv = PositionView.loadFromNibNamed("PositionView") as! PositionView
            pv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "showPositionDetail:"))
            positions[position.id] = pv
            addSubview(pv)
        }
        positions[position.id]?.updatePosition(position)
    }
    
    func removePosition(id: String) {
        if let position = positions[id] {
            position.removeFromSuperview()
            positions[id] = nil
        }
    }
    
    func addOrUpdateOrder(order: TradableOrder) {
        if orders[order.id] == nil {
            let ov = OrderView.loadFromNibNamed("OrderView") as! OrderView
            ov.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "showEditOrder:"))
            orders[order.id] = ov
            addSubview(ov)
        }
        orders[order.id]?.updateOrder(order)
    }
    
    func removeOrder(id: String) {
        if let order = orders[id] {
            order.removeFromSuperview()
            orders[id] = nil
        }
    }
    
    func addClosedPosition(position: TradablePosition) {
        if closedPositions[position.id] == nil {
            let cpv = ClosedPositionView.loadFromNibNamed("ClosedPositionView") as! ClosedPositionView
            cpv.setPositionDetail(position)
            closedPositions[position.id] = cpv
            addSubview(cpv)
        }
    }
    
    func showPositionDetail(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            portfolioDelegate?.showPositionDetail((sender.view as! PositionView).position!)
        }
    }
    
    func showEditOrder(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            portfolioDelegate?.showEditOrder((sender.view as! OrderView).order!)
        }
    }
    
    func portfolioEmpty(empty: Bool) {
        portfolioDelegate?.isPortfolioEmpty(empty)
    }
    
    func clear() {
        closedPositions = [:]
        positions = [:]
        orders = [:]
        self.subviews.forEach({ $0.removeFromSuperview() })
        layoutSubviews()
    }
}