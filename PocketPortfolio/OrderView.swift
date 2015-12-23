//
//  OrderView.swift
//  TradableExampleApp
//
//  Created by Tradable ApS on 08/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class OrderView: UIView {
    @IBOutlet weak var line: UIImageView!
    
    @IBOutlet weak var symbolLabel: UILabel!
    
    @IBOutlet weak var orderTypeLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!

    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var orderSideLabel: UILabel!
    
    let amountFormatter = NSNumberFormatter()
    let priceFormattter = NSNumberFormatter()
    
    var order:TradableOrder?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        amountFormatter.numberStyle = NSNumberFormatterStyle.NoStyle
        amountFormatter.minimumIntegerDigits = 1
        amountFormatter.minimumFractionDigits = 0
        amountFormatter.maximumFractionDigits = 1
        amountFormatter.usesGroupingSeparator = true
        
        priceFormattter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        line.image = drawLine()
        
        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 81.0)
    }
    
    func updateOrder(order: TradableOrder) {
        self.order = order
        symbolLabel.text = findBrokerageAccountSymbolForSymbol(order.symbol)
        
        let instrument = findInstrumentForSymbol(order.symbol)!
        
        if order.type == .LIMIT {
            orderTypeLabel.text = "Limit Order"
        } else if order.type == .STOP {
            orderTypeLabel.text = "Stop Order"
        } else {
            orderTypeLabel.text = "Pending Trade"
        }
        if order.side == .BUY {
            orderSideLabel.text = "Buy"
            orderSideLabel.textColor = greenColor
        } else if order.side == .SELL {
            orderSideLabel.text = "Sell"
            orderSideLabel.textColor = darkPinkColor
        }
        amountLabel.text = amountFormatter.stringFromNumber(order.amount)
        
        if order.price == 0 {
            priceLabel.attributedText = NSMutableAttributedString(string: "Market")
        } else {
            let precision = instrument.pipPrecision
            
            priceFormattter.minimumFractionDigits = precision + 1
            var length = 2
            var toLast = 1
            if precision == 0 {
                toLast = 3
            } else if precision == 1 {
                length = 3
            }
            
            let priceStr = priceFormattter.stringFromNumber(order.price)!
            
            let priceString = NSMutableAttributedString(string: priceStr)
            priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 1.0), range: NSRange(location: 0, length: priceString.length))
            priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: priceString.length - length - toLast, length: length + toLast))
            
            priceLabel.attributedText = priceString
        }
    }
}