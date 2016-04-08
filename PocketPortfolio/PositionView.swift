//
//  PositionView.swift
//  TradableExampleApp
//
//  Created by Tradable ApS on 08/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class PositionView: UIView {
    let greenColorTransparent = UIColor(red: 38.0/255.0, green: 209.0/255.0, blue: 193.0/255.0, alpha: 0.1).CGColor
    let pinkColorTransparent = UIColor(red: 255.0/255.0, green: 150.0/255.0, blue: 191.0/255.0, alpha: 0.1).CGColor
    
    let greenColorSemiTransparent = UIColor(red: 38.0/255.0, green: 209.0/255.0, blue: 193.0/255.0, alpha: 0.5)
    let pinkColorSemiTransparent = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 100.0/255.0, alpha: 0.5)
    
    @IBOutlet weak var symbolLabel: UILabel!
    
    @IBOutlet weak var pipsLabel: UILabel!
    
    @IBOutlet weak var pnlLabel: UILabel!
    
    @IBOutlet weak var directionLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var atLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var tpLabel: UILabel!
    
    @IBOutlet weak var tpAmountLabel: UILabel!
    
    @IBOutlet weak var tpPipsLabel: UILabel!
    
    @IBOutlet weak var slLabel: UILabel!
    
    @IBOutlet weak var slAmountLabel: UILabel!
    
    @IBOutlet weak var slPipsLabel: UILabel!

    @IBOutlet weak var secondLine: UIImageView!
    
    @IBOutlet weak var firstLine: UIImageView!
    
    @IBOutlet weak var innerView: UIView!
    
    let gradient = CAGradientLayer()
    
    let amountFormatter = NSNumberFormatter()
    let priceFormatter = NSNumberFormatter()
    let pnlFormatter = NSNumberFormatter()
    
    var position:TradablePosition?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        amountFormatter.numberStyle = NSNumberFormatterStyle.NoStyle
        amountFormatter.minimumIntegerDigits = 1
        amountFormatter.minimumFractionDigits = 0
        amountFormatter.maximumFractionDigits = 1
        amountFormatter.usesGroupingSeparator = true
        
        priceFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        pnlFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        pnlFormatter.minimumFractionDigits = 2
        pnlFormatter.maximumFractionDigits = 2
        pnlFormatter.positivePrefix = pnlFormatter.plusSign
        pnlFormatter.negativePrefix = pnlFormatter.minusSign
        
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.locations = [0.67, 1.0]
        
        layer.insertSublayer(gradient, atIndex: 0)
        
        firstLine.image = drawLine()
        secondLine.image = drawLine()
        
        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 81.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradient.frame = self.bounds
        CATransaction.commit()
    }

    func updatePosition(position: TradablePosition) {
        self.position = position
        
        if let instrument = findInstrumentForSymbol(position.symbol) {
            var hasProtections = false
            
            if let tp = position.takeProfit {
                tpAmountLabel.text = "\(abs(getPipDistance(position.openPrice, to: tp, instrument: instrument)))"
                hasProtections = true
            } else if position.stopLoss != nil {
                tpAmountLabel.text = "-"
            }
            
            if let sl = position.stopLoss {
                slAmountLabel.text = "\(abs(getPipDistance(position.openPrice, to: sl, instrument: instrument)))"
                hasProtections = true
            } else if position.takeProfit != nil {
                slAmountLabel.text = "-"
            }
            
            if hasProtections {
                showProtections()
            } else {
                hideProtections()
            }
            
            symbolLabel.text = findBrokerageAccountSymbolForSymbol(position.symbol)
            
            if position.side == .BUY {
                directionLabel.text = "\u{25B2} Long"
                directionLabel.textColor = greenColor
            } else if position.side == .SELL {
                directionLabel.text = "\u{25BC} Short"
                directionLabel.textColor = darkPinkColor
            }
            
            amountLabel.text = amountFormatter.stringFromNumber(position.amount)
            
            let precision = instrument.pipPrecision
            
            priceFormatter.minimumFractionDigits = precision == nil ? instrument.decimals : precision! + 1
            var length = 2
            var toLast = 1
            if precision == 0 {
                toLast = 3
            } else if precision == 1 {
                length = 3
            }
            
            let priceStr = priceFormatter.stringFromNumber(position.openPrice)!
            
            let priceString = NSMutableAttributedString(string: priceStr)
            if precision != nil {
                priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 1.0), range: NSRange(location: 0, length: priceString.length))
                priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: priceString.length - length - toLast, length: length + toLast))
            } else {
                priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: 0, length: priceString.length))
            }
            priceLabel.attributedText = priceString
            
            if !(instrument.type == .FOREX || instrument.type == .CFD) {
                pipsLabel.hidden = true
            }
            
            if let openPnL = position.openProfit, currentPrice = position.lastPrice {
                let positive = openPnL >= 0
                if positive {
                    gradient.colors = [UIColor.clearColor().CGColor, greenColorTransparent]
                    pipsLabel.textColor = greenColorSemiTransparent
                    pnlLabel.textColor = greenColor
                } else {
                    gradient.colors = [UIColor.clearColor().CGColor, pinkColorTransparent]
                    pipsLabel.textColor = pinkColorSemiTransparent
                    pnlLabel.textColor = darkPinkColor
                }
                pnlLabel.text = pnlFormatter.stringFromNumber(openPnL)
                
                if let pipsPnL = getProfitLossInPips(position.openPrice, currentPrice: currentPrice, symbol: position.symbol) {
                    pipsLabel.text = "(" + (positive ? "+" : "-") + "\(pipsPnL) pips)"
                }
            } else {
                gradient.colors = []
            }
        }
    }
    
    func hideProtections() {
        secondLine.hidden = true
        tpLabel.hidden = true
        tpAmountLabel.hidden = true
        tpPipsLabel.hidden = true
        slLabel.hidden = true
        slAmountLabel.hidden = true
        slPipsLabel.hidden = true
        
        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 81.0)
    }
    
    func showProtections() {
        secondLine.hidden = false
        tpLabel.hidden = false
        tpAmountLabel.hidden = false
        tpPipsLabel.hidden = false
        slLabel.hidden = false
        slAmountLabel.hidden = false
        slPipsLabel.hidden = false
        
        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 122.0)
    }
}